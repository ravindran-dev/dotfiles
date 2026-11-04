# Arch Linux hotspot controls

Compact Rofi hotspot settings for NetworkManager, Waybar and Hyprland.

## Dependencies and installation

```sh
sudo pacman -S --needed networkmanager dnsmasq rofi python libnotify
python3 install.py
hyprctl reload
pkill -SIGUSR2 -x waybar
```

Requires NetworkManager running, an adapter supporting AP mode, and permission
for your desktop user to manage network connections. Do not enable the standalone
dnsmasq service: NetworkManager launches its own instance for shared connections.
Ethernet is the recommended upstream; starting AP mode on your sole Wi-Fi adapter
can disconnect its existing Wi-Fi connection.

The installer copies scripts/theme to `~/.config/waybar/scripts`, creates
`~/.config/waybar/HotspotModule`, and adds Super+F to existing JaKooLit user
keybind files (both classic conf and Lua). Existing files are backed up first.
Review any pre-existing Super+F binding before installation.

For a new Waybar setup, add `$HOME/.config/waybar/HotspotModule` to its `include`
array and `custom/hotspot` to `modules-right`. If `custom/hotspot` is already
configured in `UserModules`, retain it without including the duplicate module.
On this machine the existing UserModules configuration is already installed.

## Controls

- Super+F: open settings; press again to close any hotspot dialog.
- Left-click the Waybar hotspot module: open settings.
- Right-click: toggle hotspot.
- Connection details: Show password / Hide password.
- Change password: Alt+S toggles visibility while preserving typed text.
- Enter saves/selects; Esc closes any hotspot dialog.
- Name/password updates apply the next time the hotspot is started.

The first menu launch creates `Waybar-Hotspot` with a random password and
`Ravi-Hotspot` as its default network name. Autoconnect is disabled. The password
is stored by NetworkManager and is never written into this repository.

## Troubleshooting

If activation reports that IP configuration could not be reserved, inspect:

```sh
journalctl -b -u NetworkManager --no-pager -n 80
command -v dnsmasq
nmcli -f GENERAL,IP4 device show
```

On the original machine the precise cause was `Could not find "dnsmasq" binary`.
Install dnsmasq, then start the hotspot again. AP mode alone is insufficient:
NetworkManager also needs its DHCP/DNS helper for IPv4 shared mode.

## Maintenance

Edit `hotspot.py` and `hotspot.rasi` here, rerun `python3 install.py`, and reload
Waybar. Never commit NetworkManager connection files, saved passwords or exported
secrets. The installer does not export or replace existing network profiles.

## Rounded corners

The installer adds a Rofi layer rule with `ignore_alpha = 0.5` (Lua) or
`ignore_alpha 0.5` (conf). This prevents Hyprland blur from drawing a rectangular
backdrop through the transparent corners. The rule applies to all Rofi menus.
