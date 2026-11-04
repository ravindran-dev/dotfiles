#!/usr/bin/env python3
import html
import json
import secrets
import subprocess
import sys
from pathlib import Path

PROFILE = 'Waybar-Hotspot'

def nm(*args, check=True):
    p = subprocess.run(['nmcli', '--wait', '20', *args], text=True, capture_output=True)
    if check and p.returncode:
        raise RuntimeError(p.stderr.strip() or p.stdout.strip())
    return p.stdout.strip()

def notify(message):
    subprocess.run(['notify-send', 'Hotspot', message])

def prompt(title, options=None, password=False, message=None, initial=None):
    args = ['rofi', '-no-config', '-theme', str(Path(__file__).with_name('hotspot.rasi')),
            '-dmenu', '-i', '-p', title]
    if options:
        args += ['-only-match', '-no-custom']
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
    return p.stdout.strip() if p.returncode == 0 else None

def password_prompt(title, message):
    visible, value = False, ''
    while True:
        args = ['rofi', '-no-config', '-theme', str(Path(__file__).with_name('hotspot.rasi')),
                '-dmenu', '-p', title, '-kb-custom-1', 'Alt+s', '-filter', value,
                '-theme-str', 'mainbox { children: [ inputbar, message ]; }',
                '-mesg', (message or '') + '\nAlt+S: ' + ('hide' if visible else 'show') + ' password']
        if not visible:
            args.append('-password')
        p = subprocess.run(args, input='', text=True, capture_output=True)
        value = p.stdout.rstrip('\n')
        if p.returncode == 10:
            visible = not visible
            continue
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
       '802-11-wireless.band', 'bg', 'wifi-sec.key-mgmt', 'wpa-psk',
       'wifi-sec.psk', secrets.token_urlsafe(12), 'ipv4.method', 'shared',
       'ipv6.method', 'disabled', 'connection.autoconnect', 'no')

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
        choices = [('󰐥  Stop hotspot' if on else '󰐥  Start hotspot'),
                   '󰌾  Show connection details', '󰏫  Change network name', '󰌆  Change password']
        action = prompt('󰀂  Wi-Fi Hotspot', choices,
                        message=html.escape(ssid) + ('  •  Online' if on else '  •  Offline') +
                        '\nEnter to select  ·  Esc to close')
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

        else:
            password = action == choices[3]
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
