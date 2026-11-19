#!/usr/bin/env python3
import html
import json
import ipaddress
import secrets
import sqlite3
import time
from datetime import datetime, timezone
import subprocess
import sys
from pathlib import Path

PROFILE = 'Waybar-Hotspot'
DATA_DIR = Path.home() / '.local/share/waybar-hotspot'
DB_FILE = DATA_DIR / 'devices.sqlite3'
BLOCK_FILE = DATA_DIR / 'blacklist.json'

def nm(*args, check=True):
    p = subprocess.run(['nmcli', '--wait', '20', *args], text=True, capture_output=True)
    if check and p.returncode:
        raise RuntimeError(p.stderr.strip() or p.stdout.strip())
    return p.stdout.strip()

def notify(message):
    subprocess.run(['notify-send', 'Hotspot', message])

def prompt(title, options=None, password=False, message=None, initial=None):
    args = ['rofi', '-no-config', '-theme', str(Path.home() / '.config/rofi/hotspot.rasi'),
            '-dmenu', '-i', '-markup-rows', '-kb-cancel', 'Escape,Super+f', '-p', title]
    if options:
        args += ['-no-custom']
    else:
        args += ['-theme-str', 'mainbox { children: [ inputbar, message ]; }']
    if message:
        args += ['-mesg', message]
    if initial:
        args += ['-filter', initial]
    if password:
        return password_prompt(title, message)
    p = subprocess.run(args, input='\n'.join(options or []), text=True, capture_output=True)
    if p.returncode not in (0, 1) and p.stderr:
        notify(p.stderr.strip())
    if p.returncode == 1:
        raise SystemExit(0)
    return p.stdout.strip() if p.returncode == 0 else None

def password_prompt(title, message):
    visible, value = False, ''
    while True:
        args = ['rofi', '-no-config', '-theme', str(Path.home() / '.config/rofi/hotspot.rasi'),
                '-dmenu', '-kb-cancel', 'Escape,Super+f', '-p', title, '-kb-custom-1', 'Alt+s', '-filter', value,
                '-theme-str', 'mainbox { children: [ inputbar, message ]; }',
                '-theme-str', 'inputbar { children: [ prompt, entry ]; }',
                '-mesg', (message or '') + '\nAlt+S: ' + ('hide' if visible else 'show') + ' password']
        if not visible:
            args.append('-password')
        p = subprocess.run(args, input='', text=True, capture_output=True)
        value = p.stdout.rstrip('\n')
        if p.returncode == 10:
            visible = not visible
            continue
        if p.returncode == 1:
            raise SystemExit(0)
        return value if p.returncode == 0 else None

def exists():
    return subprocess.run(['nmcli', 'connection', 'show', PROFILE], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0

def active():
    return PROFILE in nm('-g', 'NAME', 'connection', 'show', '--active').splitlines()

def ensure():
    if exists():
        return
    devices = nm('-t', '-f', 'DEVICE,TYPE', 'device', 'status').splitlines()
    wifi = next((r.split(':')[0] for r in devices if r.endswith(':wifi')), None)
    if not wifi:
        raise RuntimeError('No Wi-Fi adapter found.')
    nm('connection', 'add', 'type', 'wifi', 'ifname', wifi, 'con-name', PROFILE,
       'ssid', 'Ravi-Hotspot', '802-11-wireless.mode', 'ap',
       '802-11-wireless.band', 'bg', '802-11-wireless.channel', '6',
       'wifi-sec.key-mgmt', 'wpa-psk', 'wifi-sec.proto', 'rsn',
       'wifi-sec.pairwise', 'ccmp', 'wifi-sec.group', 'ccmp',
       'wifi-sec.pmf', 'optional',
       'wifi-sec.psk', secrets.token_urlsafe(12), 'ipv4.method', 'shared',
       'ipv6.method', 'disabled', 'connection.autoconnect', 'no')

def hotspot_interface():
    out = subprocess.run(['iw', 'dev'], text=True, capture_output=True).stdout
    current = None
    for line in out.splitlines():
        if line.startswith('Interface '): current = line.split()[1]
        elif line.strip() == 'type AP' and current: return current
    return 'wlo1'

def db():
    DATA_DIR.mkdir(parents=True, exist_ok=True, mode=0o700)
    con = sqlite3.connect(DB_FILE, timeout=5)
    con.execute('PRAGMA journal_mode=WAL')
    con.execute('''CREATE TABLE IF NOT EXISTS devices(mac TEXT PRIMARY KEY, hostname TEXT, alias TEXT,
                 first_seen TEXT NOT NULL, last_seen TEXT NOT NULL, last_tx INTEGER DEFAULT 0,
                 last_rx INTEGER DEFAULT 0, tx_total INTEGER DEFAULT 0, rx_total INTEGER DEFAULT 0)''')
    con.execute('''CREATE TABLE IF NOT EXISTS sessions(id INTEGER PRIMARY KEY, mac TEXT NOT NULL,
                 connected_at TEXT NOT NULL, disconnected_at TEXT)''')
    con.commit()
    return con

def persist_devices(clients):
    now = datetime.now(timezone.utc).isoformat(timespec='seconds')
    with db() as con:
        present = {d['mac'] for d in clients}
        previous = {r[0] for r in con.execute('SELECT mac FROM devices WHERE mac IN (SELECT mac FROM sessions WHERE disconnected_at IS NULL)')}
        for d in clients:
            row = con.execute('SELECT last_tx,last_rx,hostname,alias FROM devices WHERE mac=?', (d['mac'],)).fetchone()
            tx, rx = d.get('tx_bytes',0), d.get('rx_bytes',0)
            con.execute('''INSERT INTO devices(mac,hostname,first_seen,last_seen,last_tx,last_rx,tx_total,rx_total)
              VALUES(?,?,?,?,?,?,?,?) ON CONFLICT(mac) DO UPDATE SET hostname=COALESCE(NULLIF(excluded.hostname,''),devices.hostname),last_seen=excluded.last_seen,
              tx_total=devices.tx_total+MAX(0,excluded.last_tx-devices.last_tx),rx_total=devices.rx_total+MAX(0,excluded.last_rx-devices.last_rx),last_tx=excluded.last_tx,last_rx=excluded.last_rx''',
              (d['mac'],d.get('name',''),now,now,tx,rx,tx,rx))
            if d['mac'] not in previous:
                con.execute('INSERT INTO sessions(mac,connected_at) VALUES(?,?)',(d['mac'],now))
        gone = previous-present
        for mac in gone:
            con.execute('UPDATE sessions SET disconnected_at=? WHERE mac=? AND disconnected_at IS NULL',(now,mac))

def friendly_name(mac, hostname):
    with db() as con:
        row=con.execute('SELECT alias,hostname FROM devices WHERE mac=?',(mac,)).fetchone()
    return (row[0] or row[1] or hostname) if row else hostname

def leases():
    """Read associated AP stations, enriched with DHCP and neighbor metadata."""
    clients = {}
    interface = hotspot_interface()
    try:
        dump = subprocess.run(['iw', 'dev', interface, 'station', 'dump'], text=True, capture_output=True, check=True).stdout
        current = None
        for line in dump.splitlines():
            line = line.strip()
            if line.startswith('Station '):
                mac = line.split()[1].lower()
                current = {'mac': mac, 'ip': '', 'name': 'Wi-Fi device', 'source': 'AP', 'status': 'Connected'}
                clients[mac] = current
            elif current and line.startswith('signal:'):
                current['signal'] = line.split(':', 1)[1].strip().split()[0] + ' dBm'
            elif current and line.startswith('connected time:'):
                current['duration'] = line.split(':', 1)[1].strip()
            elif current and line.startswith('rx bytes:'):
                current['rx_bytes'] = int(line.split(':', 1)[1].strip())
            elif current and line.startswith('rx packets:'):
                current['rx_packets'] = int(line.split(':', 1)[1].strip())
            elif current and line.startswith('tx packets:'):
                current['tx_packets'] = int(line.split(':', 1)[1].strip())
            elif current and line.startswith('tx bytes:'):
                current['tx_bytes'] = int(line.split(':', 1)[1].strip())
    except (OSError, subprocess.CalledProcessError):
        pass
    # Discover and read the exact lease file used by the running dnsmasq via a minimal read-only privileged helper.
    try:
        args = subprocess.run(['ps', '-eo', 'args'], text=True, capture_output=True, check=True).stdout
        import re
        leasefile = None
        for proc in args.splitlines():
            if 'dnsmasq' in proc and f'dnsmasq-{interface}.leases' in proc:
                match = re.search(r'--dhcp-leasefile=([^\s]+)', proc)
                if match:
                    candidate = Path(match.group(1))
                    if candidate.parent == Path('/var/lib/NetworkManager') and candidate.name == f'dnsmasq-{interface}.leases':
                        leasefile = str(candidate); break
        raw_leases = subprocess.run(['pkexec', '/usr/bin/cat', leasefile], text=True, capture_output=True, timeout=15) if leasefile else None
        lease_lines = raw_leases.stdout.splitlines() if raw_leases and raw_leases.returncode == 0 else []
    except (OSError, subprocess.TimeoutExpired, subprocess.CalledProcessError):
        lease_lines = []
    for line in lease_lines:
        try:
            parts = line.split()
            if len(parts) < 4: continue
            _expiry, mac, ip, hostname = parts[:4]
            ipaddress.ip_address(ip); mac = mac.lower()
            clients.setdefault(mac, {'mac': mac, 'ip': ip, 'name': 'Wi-Fi device', 'source': 'DHCP', 'status': 'Disconnected'})
            clients[mac]['ip'] = ip
            if hostname != '*': clients[mac]['name'] = hostname
        except ValueError: pass

    try:
        neighbors = subprocess.run(['ip', '-4', 'neigh', 'show', 'dev', interface],
                                   text=True, capture_output=True, check=True).stdout
        for line in neighbors.splitlines():
            parts = line.split()
            if 'lladdr' not in parts or any(state in parts for state in ('FAILED', 'INCOMPLETE')):
                continue
            ip, mac = parts[0], parts[parts.index('lladdr') + 1].lower()
            try:
                address = ipaddress.ip_address(ip)
            except ValueError:
                continue
            if address not in ipaddress.ip_network('10.42.0.0/24'):
                continue
            name = 'Wi-Fi device'
            try:
                resolved = subprocess.run(['getent', 'hosts', ip], text=True, capture_output=True, timeout=2).stdout.split()
                if len(resolved) > 1:
                    name = resolved[1].split('.')[0]
                if name == 'Wi-Fi device':
                    mdns = subprocess.run(['avahi-resolve-address', ip], text=True, capture_output=True, timeout=2).stdout.split()
                    if len(mdns) > 1:
                        name = mdns[1].split('.')[0]
            except (OSError, subprocess.TimeoutExpired):
                pass
            clients.setdefault(mac, {'mac': mac, 'ip': ip, 'name': name, 'source': 'Network', 'status': 'Disconnected'})
            clients[mac]['ip'] = ip
    except (OSError, subprocess.CalledProcessError):
        pass
    for d in clients.values(): d['name'] = friendly_name(d['mac'], d['name'])
    persist_devices(list(clients.values()))
    # Keep previously seen clients visible after a temporary disconnect.
    with db() as con:
        for mac, hostname, alias, first_seen, last_seen in con.execute(
                'SELECT mac,hostname,alias,first_seen,last_seen FROM devices'):
            if mac not in clients:
                clients[mac] = {'mac': mac, 'ip': '', 'name': alias or hostname or 'Unknown device',
                                'source': 'History', 'status': 'Disconnected',
                                'last_seen': last_seen, 'first_seen': first_seen}
    return sorted(clients.values(), key=lambda device: (device['name'].lower(), device.get('ip', '')))

def blocked_macs():
    try:
        return set(json.loads(BLOCK_FILE.read_text()))
    except (OSError, ValueError, TypeError):
        return set()

def set_firewall_block(mac, block):
    # nftables enforcement requires administrator authentication via polkit.
    rule = ['nft', 'add', 'rule', 'inet', 'filter', 'forward', 'iifname', 'wlo1', 'ether', 'saddr', mac, 'drop']
    if block:
        check = subprocess.run(['nft', 'list', 'chain', 'inet', 'filter', 'forward'], capture_output=True)
        if check.returncode:
            raise RuntimeError('No existing inet/filter/forward chain is available. Blocking was not applied; configure a managed firewall backend first.')
        result = subprocess.run(['pkexec', *rule], text=True, capture_output=True)
        if result.returncode:
            raise RuntimeError(result.stderr.strip() or 'Could not install firewall block.')
    else:
        # Remove matching rules by listing handles and deleting exact MAC rules.
        listed = subprocess.run(['nft', '-a', 'list', 'chain', 'inet', 'filter', 'forward'], text=True, capture_output=True)
        if listed.returncode:
            raise RuntimeError('Cannot inspect nftables forward chain.')
        import re
        handles = [m.group(1) for line in listed.stdout.splitlines()
                   if mac.lower() in line.lower() and (m := re.search(r'# handle (\d+)', line))]
        for handle in handles:
            result = subprocess.run(['pkexec', 'nft', 'delete', 'rule', 'inet', 'filter', 'forward', 'handle', handle], text=True, capture_output=True)
            if result.returncode:
                raise RuntimeError(result.stderr.strip() or 'Could not remove firewall block.')

def device_menu():
    while True:
        clients = leases()
        blocked = blocked_macs()
        if not clients:
            prompt('Connected devices', ['󰁍  Back'], message='No active clients found on the hotspot yet. Reconnect the device or open a page on it, then refresh this list.')
            return
        labels = [f"{'⛔' if d['mac'] in blocked else ('●' if d.get('status') != 'Disconnected' else '○')} {d['name']} · {d.get('ip') or 'Offline'} · {d['mac']}" for d in clients]
        labels.append('󰁍  Back')
        selected = prompt('Connected devices', labels, message=f'{sum(d.get("status") != "Disconnected" for d in clients)} connected · {sum(d.get("status") == "Disconnected" for d in clients)} offline · live AP/DHCP data')
        if not selected or selected == '󰁍  Back':
            return
        index = labels.index(selected)
        device = clients[index]
        is_blocked = device['mac'] in blocked
        connected = device.get('status') != 'Disconnected'
        primary = 'Disconnect now (temporary)' if connected else 'Connect'
        details = f"IP  {device.get('ip') or 'Not currently assigned'}\nMAC  {device['mac']}\nStatus  {device.get('status', 'Disconnected')}"
        if not connected: details += '\n\nSelect Connect to allow it; then join this hotspot from the device.'
        action = prompt(device['name'], [primary, 'Pause internet (firewall)', 'Block device (permanent)', 'Rename device', '󰜺  ' + ('Unblock device' if is_blocked else 'Blacklist device'), '󰁍  Back'], message=details)
        if action == 'Connect' and not connected:
            notify('Hotspot is available. Start Wi-Fi and select this hotspot on the device; a hotspot cannot force a client to associate.')
        elif action == 'Disconnect now (temporary)':
            interface = hotspot_interface()
            result = subprocess.run(['pkexec','iw','dev',interface,'station','del',device['mac']],text=True,capture_output=True)
            if result.returncode: raise RuntimeError(result.stderr.strip() or 'Station disconnect failed.')
            with db() as con: con.execute('UPDATE sessions SET disconnected_at=? WHERE mac=? AND disconnected_at IS NULL',(datetime.now(timezone.utc).isoformat(timespec='seconds'),device['mac']))
            notify('Device disconnected; it may reconnect. Use Connect for instructions to rejoin.')
        elif action == 'Rename device':
            alias=prompt('Rename device',message='Enter a friendly name')
            if alias:
                with db() as con: con.execute('UPDATE devices SET alias=? WHERE mac=?',(alias[:64],device['mac']))
                notify('Device name saved.')
        elif action == 'Pause internet (firewall)':
            set_firewall_block(device['mac'], True)
            notify('Internet paused. Wi-Fi association remains active.')
        elif action == 'Block device (permanent)':
            raise RuntimeError('Persistent Wi-Fi association blocking is unsupported by this verified NetworkManager backend; firewall policy is not association blocking.')
        elif action == '󰐥  Release device':
            set_firewall_block(device['mac'], True)
            blocked.add(device['mac'])
            BLOCK_FILE.parent.mkdir(parents=True, exist_ok=True)
            BLOCK_FILE.write_text(json.dumps(sorted(blocked), indent=2) + '\n')
            notify(f"Blocked network access for {device['name']}.")
        elif action and action.startswith('󰜺'):
            set_firewall_block(device['mac'], not is_blocked)
            if is_blocked:
                blocked.remove(device['mac'])
            else:
                blocked.add(device['mac'])
            BLOCK_FILE.parent.mkdir(parents=True, exist_ok=True)
            BLOCK_FILE.write_text(json.dumps(sorted(blocked), indent=2) + '\n')
            notify('Device unblocked.' if is_blocked else 'Device blacklisted.')

def toggle():
    ensure()
    if active():
        nm('connection', 'down', PROFILE)
        notify('Hotspot stopped.')
    else:
        if not __import__('shutil').which('dnsmasq'):
            raise RuntimeError('Missing dnsmasq. Install it with: sudo pacman -S --needed dnsmasq')
        nm('connection', 'up', PROFILE)
        notify('Hotspot started. Open the hotspot menu to show its password.')

def menu():
    ensure()
    while True:
        on = active()
        ssid = nm('-g', '802-11-wireless.ssid', 'connection', 'show', PROFILE)
        choices = [('   Stop hotspot' if on else '   Start hotspot'),
                   '   Show connection details', '󰌢   Connected devices', '󰑕   Change network name', '󰌆   Change password']
        status = "<span foreground='#88b896'>● Active</span>" if on else "<span foreground='#c47c88'>○ Offline</span>"
        message = (f"<span foreground='#e2e4ec'>SSID: {html.escape(ssid)}</span>  {status}"
                   "\n<span foreground='#525666' size='small'>↵ Enter to select  •  Esc to close</span>")
        action = prompt('󰤨  Wi-Fi Hotspot', choices, message=message)
        if action is None:
            return
        if action == choices[0]:
            toggle()
        elif action == choices[1]:
            key = nm('--show-secrets', '-g', '802-11-wireless-security.psk', 'connection', 'show', PROFILE)
            visible = False
            while True:
                detail = prompt('󰌾  Connection details',
                                ['󰌾  Hide password' if visible else '󰌾  Show password', '󰁍  Back'],
                                message='Network   ' + html.escape(ssid) + '\nPassword  ' +
                                (html.escape(key) if visible else '••••••••') +
                                '\n\nSelect this network on your phone to connect.')
                if detail is None or detail == '󰁍  Back':
                    break
                visible = not visible

        elif action == choices[2]:
            device_menu()
        elif action in (choices[3], choices[4]):
            password = action == choices[4]
            value = prompt('󰌆  Password' if password else '󰏫  Network name', password=password,
                           message=('Use 8–63 ASCII characters.' if password else 'Choose a name for your hotspot (1–32 bytes).') +
                           '\nEnter to save  ·  Esc to cancel', initial=None if password else ssid)
            if value is None:
                continue
            if password and not (8 <= len(value) <= 63 and value.isascii()):
                prompt('Invalid password', ['󰁍  Back'], message='Use 8–63 ASCII characters.')
                continue
            if not password and not (1 <= len(value.encode()) <= 32):
                prompt('Invalid name', ['󰁍  Back'], message='Network name must be 1–32 bytes.')
                continue
            nm('connection', 'modify', PROFILE, 'wifi-sec.psk' if password else '802-11-wireless.ssid', value)
            notify('Settings saved. Restart the hotspot to apply them.' if active() else 'Settings saved.')

try:
    command = sys.argv[1] if len(sys.argv) > 1 else 'menu'
    if command == 'status':
        on = active()
        print(json.dumps({'text': '󰀂 ' + ('ON' if on else 'OFF'), 'class': 'active' if on else 'inactive', 'tooltip': 'Hotspot ' + ('active' if on else 'off') + '\nLeft click: settings\nRight click: toggle'}))
    elif command == 'setup':
        ensure()
    elif command == 'devices-json':
        print(json.dumps(leases()))
    elif command == 'toggle':
        toggle()
    else:
        menu()
except Exception as e:
    if len(sys.argv) > 1 and sys.argv[1] == 'status':
        print(json.dumps({'text': '󰀂 ?', 'tooltip': html.escape(str(e)), 'class': 'error'}))
    else:
        notify(str(e))
    sys.exit(1)
