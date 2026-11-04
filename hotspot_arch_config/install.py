#!/usr/bin/env python3
"""Install hotspot controls into an existing Waybar/Hyprland configuration."""
from pathlib import Path
from datetime import datetime
import json
import shutil

source = Path(__file__).resolve().parent
home = Path.home()
waybar = home / '.config/waybar'
scripts = waybar / 'scripts'
backup = waybar / 'backups' / ('hotspot-install-' + datetime.now().strftime('%Y%m%d-%H%M%S'))
backup.mkdir(parents=True)
scripts.mkdir(parents=True, exist_ok=True)
for name in ('hotspot.py', 'hotspot.rasi'):
    target = scripts / name
    if target.exists():
        shutil.copy2(target, backup / name)
    shutil.copy2(source / name, target)
(scripts / 'hotspot.py').chmod(0o755)
module = {
    'exec': '$HOME/.config/waybar/scripts/hotspot.py status',
    'return-type': 'json', 'interval': 5, 'format': '{}', 'tooltip': True,
    'on-click': '$HOME/.config/waybar/scripts/hotspot.py menu',
    'on-click-right': '$HOME/.config/waybar/scripts/hotspot.py toggle'
}
(waybar / 'HotspotModule').write_text(json.dumps({'custom/hotspot': module}, indent=2) + '\n')
for suffix, line in (
    ('conf', 'bindd = SUPER, F, Hotspot settings, exec, $HOME/.config/waybar/scripts/hotspot.py menu'),
    ('lua', 'hl.bind("SUPER + F", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/waybar/scripts/hotspot.py menu"), {description = "Hotspot settings"})'),
):
    target = home / ('.config/hypr/UserConfigs/UserKeybinds.' + suffix)
    if target.exists() and line not in target.read_text():
        shutil.copy2(target, backup / target.name)
        target.write_text(target.read_text() + '\n' + line + '\n')
print('Installed. Backups:', backup)
print('Waybar: include $HOME/.config/waybar/HotspotModule and add custom/hotspot to modules-right.')
print('If custom/hotspot already exists in UserModules, keep that existing definition instead.')
print('Reload Hyprland and Waybar. Open the menu to create the NetworkManager profile.')
