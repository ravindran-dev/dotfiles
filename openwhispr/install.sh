#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

echo "==> Deploying OpenWhispr dotfiles..."

# 1. OpenWhispr User Environment
mkdir -p "$CONFIG_DIR/open-whispr"
if [ -f "$CONFIG_DIR/open-whispr/.env" ]; then
    cp "$CONFIG_DIR/open-whispr/.env" "$CONFIG_DIR/open-whispr/.env.bak"
fi
cp "$SCRIPT_DIR/open-whispr.env" "$CONFIG_DIR/open-whispr/.env"
echo "  ✓ Installed ~/.config/open-whispr/.env"

# 2. Hyprland Keybinds
mkdir -p "$CONFIG_DIR/hypr/UserConfigs"
cp "$SCRIPT_DIR/hypr/openwhispr-binds.lua" "$CONFIG_DIR/hypr/openwhispr-binds.lua"

# Ensure hyprland.lua loads the keybinds file
if [ -f "$CONFIG_DIR/hypr/hyprland.lua" ]; then
    if ! grep -q "openwhispr-binds.lua" "$CONFIG_DIR/hypr/hyprland.lua"; then
        echo 'pcall(dofile, "/home/ravi/.config/hypr/openwhispr-binds.lua")' >> "$CONFIG_DIR/hypr/hyprland.lua"
    fi
fi
echo "  ✓ Installed ~/.config/hypr/openwhispr-binds.lua"

# 3. Hyprland Window Rules
if [ -f "$CONFIG_DIR/hypr/UserConfigs/WindowRules.lua" ]; then
    if ! grep -q "Voice Recorder" "$CONFIG_DIR/hypr/UserConfigs/WindowRules.lua"; then
        cat "$SCRIPT_DIR/hypr/WindowRules.lua" >> "$CONFIG_DIR/hypr/UserConfigs/WindowRules.lua"
    fi
fi

if [ -f "$CONFIG_DIR/hypr/UserConfigs/WindowRules.conf" ]; then
    if ! grep -q "Voice Recorder" "$CONFIG_DIR/hypr/UserConfigs/WindowRules.conf"; then
        cat "$SCRIPT_DIR/hypr/WindowRules.conf" >> "$CONFIG_DIR/hypr/UserConfigs/WindowRules.conf"
    fi
fi
echo "  ✓ Installed Hyprland Window Rules"

# 4. Reload Hyprland and Waybar if running
if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload || true
    echo "  ✓ Reloaded Hyprland"
fi

if pgrep -x waybar >/dev/null 2>&1; then
    killall -SIGUSR2 waybar || true
    echo "  ✓ Reloaded Waybar"
fi

echo "==> OpenWhispr integration installed successfully!"
