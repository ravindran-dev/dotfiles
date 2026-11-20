# OpenWhispr Hyprland & Waybar Integration

Custom configurations and fixes for running [OpenWhispr](https://openwhispr.com) smoothly on Arch Linux with Hyprland and Waybar.

## 🎯 Problems Solved

1. **Transparent Box & Focus Stealing**:
   - The default floating `Voice Recorder` pill window creates a 208×120 px transparent Electron canvas. On Hyprland with `follow_mouse = 1`, moving the mouse near the bottom-right corner caused Hyprland to focus the transparent box, dimming and defocusing active applications.
   - Hyprland default rules drew borders and resize grips (`⤡`) around the transparent rectangle.
   - **Fix**: Window rules remove borders (`border_size = 0`, `rounding = 0`), shadows, blur, and initial focus stealing (`no_initial_focus = true`), while ensuring the circular button retains full clickability.

2. **Navbar Icon & Background Window Suppression**:
   - By default, OpenWhispr's background overlay created broken question marks (`?`) or generic microphone icons in Waybar.
   - **Fix**: Mapped OpenWhispr's GUI (`Control Panel`) to the official 3-bar waveform icon (`󰖁 `) and suppressed all background recorder windows from appearing on the navbar.

3. **Keybinding Integration**:
   - Added D-Bus method call keybinds in Hyprland (`SUPER + \`` for dictation toggle, `CTRL + SHIFT + SPACE` for voice agent toggle) via `com.openwhispr.App`.

---

## 📁 Structure

```
openwhispr/
├── hypr/
│   ├── WindowRules.conf         # Hyprlang window rules
│   ├── WindowRules.lua          # Lua window rules for Hyprland 0.57+
│   └── openwhispr-binds.lua     # D-Bus keybindings for Hyprland
├── waybar/
│   ├── Modules.jsonc            # Window title rewrite snippet
│   └── ModulesWorkspaces.jsonc  # Workspace format-icon mapping snippet
├── install.sh                   # Automated deployment script
├── open-whispr.env              # Environment config (~/.config/open-whispr/.env)
└── README.md                    # Documentation
```

---

## 🚀 Installation

Run the automated installer:

```bash
chmod +x install.sh
./install.sh
```

Or manually copy:
- `open-whispr.env` to `~/.config/open-whispr/.env`
- `hypr/openwhispr-binds.lua` to `~/.config/hypr/openwhispr-binds.lua`
- Append `hypr/WindowRules.lua` to `~/.config/hypr/UserConfigs/WindowRules.lua`
- Add the Waybar icon rules from `waybar/` into your Waybar config.

---

## ⌨️ Shortcuts

| Shortcut | Action | Method |
| :--- | :--- | :--- |
| `SUPER + \`` | Toggle Dictation | D-Bus: `com.openwhispr.App.Toggle` |
| `CTRL + SHIFT + SPACE` | Toggle Voice Agent | D-Bus: `com.openwhispr.App.ToggleVoiceAgent` |
