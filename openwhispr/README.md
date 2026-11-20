# OpenWhispr Hyprland & Waybar Integration

Custom configurations and fixes for running [OpenWhispr](https://openwhispr.com) smoothly on Arch Linux with Hyprland and Waybar.

## 🎯 Problems Solved

1. **Transparent Box & Focus Stealing**:
   - The default floating `Voice Recorder` pill window creates a 208×120 px transparent Electron canvas. On Hyprland with `follow_mouse = 1`, moving the mouse near the bottom-right corner caused Hyprland to focus the transparent box, dimming and defocusing active applications.
   - Hyprland default rules drew borders and resize grips (`⤡`) around the transparent rectangle.
   - **Fix**: Window rules remove borders (`border_size = 0`, `rounding = 0`), shadows, blur, and initial focus stealing (`no_initial_focus = true`), while ensuring the circular button retains full clickability.

2. **Official OpenWhispr Logo in Waybar**:
   - Embedded the official OpenWhispr application SVG logo directly from the official repo (`src/assets/logo.svg`).
   - Integrated as a clean `image#openwhispr` Waybar module with native D-Bus click actions (`Toggle` on left click, Control Panel on right click).
   - Suppressed all background recorder windows and incorrect glyph representations from cluttering workspace tags.

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
│   ├── icons/
│   │   ├── openwhispr.svg       # Official SVG logo asset
│   │   └── openwhispr.png       # High-quality PNG raster asset
│   ├── UserModules.jsonc        # Waybar image module definition
│   ├── Modules.jsonc            # Window title rewrite snippet
│   └── ModulesWorkspaces.jsonc  # Workspace suppression snippet
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

---

## ⌨️ Shortcuts

| Shortcut | Action | Method |
| :--- | :--- | :--- |
| `SUPER + \`` | Toggle Dictation | D-Bus: `com.openwhispr.App.Toggle` |
| `CTRL + SHIFT + SPACE` | Toggle Voice Agent | D-Bus: `com.openwhispr.App.ToggleVoiceAgent` |
