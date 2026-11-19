# Arch Linux Dotfiles & Workstation Environment

A minimalist, high-performance workstation configuration featuring Hyprland, Waybar, Zsh, Kitty, and automated provisioning.

[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)](https://archlinux.org)
[![Hyprland](https://img.shields.io/badge/Hyprland-00AAEE?style=for-the-badge&logo=wayland&logoColor=white)](https://hyprland.org)
[![Waybar](https://img.shields.io/badge/Waybar-2E3440?style=for-the-badge&logo=linux&logoColor=white)](https://github.com/Alexays/Waybar)
[![Zsh](https://img.shields.io/badge/Zsh-F15A24?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.zsh.org)
[![Kitty](https://img.shields.io/badge/Kitty-111111?style=for-the-badge&logo=kitty&logoColor=white)](https://sw.kovidgoyal.net/kitty/)
[![Python](https://img.shields.io/badge/Python_3.12+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-22C55E?style=for-the-badge)](LICENSE)

---

## Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Modules & Configuration](#modules--configuration)
  - [Wi-Fi Hotspot Suite (`hotspot/`)](#1-wi-fi-hotspot-suite-hotspot)
  - [Zsh Shell Environment (`zsh/`)](#2-zsh-shell-environment-zsh)
  - [Kitty Terminal & Fastfetch (`configs/`)](#3-kitty-terminal--fastfetch-configs)
  - [Automated System Setup (`autosetup.sh`)](#4-automated-system-setup-autosetupsh)
  - [Terminal ChatGPT Assistant (`chat.py`)](#5-terminal-chatgpt-assistant-chatpy)
- [Installation & Setup](#installation--setup)
- [Keybindings Reference](#keybindings-reference)
- [Author & Connect](#author--connect)
- [License](#license)

---

## Overview

This repository maintains a streamlined, production-grade Arch Linux development setup. It focuses on clean typography, keyboard-driven navigation, low latency, and deterministic system provisioning.

- **Automated Workstation Setup**: End-to-end bootstrapping script (`autosetup.sh`) for Arch Linux, Ubuntu, and Debian.
- **Integrated Hotspot Manager**: Standalone Rofi UI and NetworkManager automation with hardened WPA2-AES security, Protected Management Frames (802.11w), client tracking, and Waybar integration.
- **Productive Shell Architecture**: Optimized Zsh setup with autosuggestions, syntax highlighting, customized dircolors, and minimal git status prompt.
- **Modern CLI Stack**: Curated configuration for `bat`, `fzf`, `zoxide`, `fastfetch`, and AI-assisted terminal workflows.

---

## Repository Structure

```plaintext
dotfiles/
├── autosetup.sh          # Cross-distro automated installation script
├── chat.py               # Interactive CLI ChatGPT assistant with streaming
├── configs/
│   ├── fastfetch/        # Fastfetch system info configurations (full & compact)
│   ├── kitty/            # GPU-accelerated Kitty terminal config & color themes
│   └── zsh/              # Base Zsh configuration files
├── hotspot/              # Complete Wi-Fi Hotspot management suite
│   ├── hotspot.py        # Core NetworkManager, firewall & SQLite backend
│   ├── hotspot.rasi      # Matte translucent Rofi popup theme
│   ├── install.py        # Auto-installer for Hyprland/Waybar integration
│   └── README.md         # Hotspot module documentation
├── mirrorlist            # Curated, high-speed Arch Linux pacman mirrorlist
├── zsh/
│   └── .zshrc            # Production Zsh configuration with custom prompt & hooks
├── LICENSE               # MIT License
└── README.md             # Repository documentation
```

---

## Modules & Configuration

### 1. Wi-Fi Hotspot Suite (`hotspot/`)

An interactive hotspot controller designed for Waybar and Hyprland desktops:

- **Hardened Wireless Security**: Uses **WPA2-AES (CCMP)** with **PMF (802.11w)** and a fixed 2.4 GHz channel to prevent iOS *"Weak Security"* warnings and ensure instant discovery across Apple and Android devices.
- **Keyboard-Driven Menu (`Super + F`)**: Clean Rofi interface to start, stop, view credentials, and monitor connected devices.
- **Waybar Integration**: Live status icon with single-click toggle and menu actions.
- **Session & Device Auditing**: SQLite database logging client connections, live bandwidth usage, and firewall-level device blocking.
- **Security-First**: Passwords remain managed by NetworkManager and are never stored in version control.

### 2. Zsh Shell Environment (`zsh/`)

Engineered for instant shell load times and fluid command execution:

- **Minimal Latency**: Pure Zsh configuration without sluggish framework overhead.
- **Dircolors Tuning**: Eliminates jarring background highlight boxes on world-writable directories.
- **Dynamic Git Status**: Real-time git branch indicator showing staged, modified, and untracked file states.
- **Smart Completion & History**: Case-insensitive autocompletions and substring history search using arrow keys.
- **Developer Aliases**: Standardized shortcuts for Git workflows, package management (`update`), and file viewing (`bat`).

### 3. Kitty Terminal & Fastfetch (`configs/`)

- **GPU Acceleration**: High-frame-rate rendering, smooth cursor trail, and truecolor support.
- **Visual Polish**: 90% background opacity, clean padding, and `FantasqueSansM Nerd Font Mono` typography.
- **Fastfetch Layouts**: Modular configurations offering both full hardware diagnostics and compact shell banners.

### 4. Automated System Setup (`autosetup.sh`)

An idempotent shell script that provisions a complete development workstation:

- **Multi-Distro Engine**: Autodetects **Arch Linux**, **Ubuntu**, and **Debian**.
- **Toolchain Installation**: Installs Rust/Cargo, base development toolchains, and AUR helpers (`paru`, `yay`).
- **Development Tooling**: Provisions `neovim`, `zsh`, `bat`, `fzf`, `zoxide`, `fastfetch`, and modern CLI utilities.
- **Desktop Environments**: Installs VS Code, Brave, Google Chrome, Spotify, and required Nerd Fonts.

### 5. Terminal ChatGPT Assistant (`chat.py`)

A lightweight Python CLI client for OpenAI models:

- Interactive, context-aware command line chat.
- Reads API key directly from the `OPENAI_KEY` environment variable.

---

## Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/ravindran-dev/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Run Full System Bootstrap (Fresh Install)

```bash
chmod +x autosetup.sh
./autosetup.sh
```

### 3. Standalone Hotspot Module Setup

```bash
cd ~/dotfiles/hotspot
sudo pacman -S --needed networkmanager dnsmasq rofi python libnotify
python3 install.py
hyprctl reload
pkill -SIGUSR2 -x waybar
```

### 4. Deploy Zsh Configuration

```bash
# Backup existing configuration
[ -f ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.bak

# Deploy dotfiles configuration
cp ~/dotfiles/zsh/.zshrc ~/.zshrc
source ~/.zshrc
```

---

## Keybindings Reference

| Shortcut | Context | Action |
| :--- | :--- | :--- |
| `Super + F` | Hyprland | Open Hotspot Settings Menu / Close Dialog |
| `Right Click` | Waybar Hotspot | Toggle Hotspot ON / OFF |
| `Left Click` | Waybar Hotspot | Open Hotspot GUI Menu |
| `Alt + S` | Hotspot Password Dialog | Toggle Password Visibility |
| `Ctrl + R` | Zsh Terminal | Fuzzy Command History Search (`fzf`) |
| `Up / Down` | Zsh Terminal | History Prefix Search |

---

## Author & Connect

**Ravindran S**  
*Software Development Engineer • Systems & Full-Stack Developer*

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/ravindran-s-982702327)
[![GitHub](https://img.shields.io/badge/GitHub-111111?style=for-the-badge&logo=github&logoColor=white)](https://github.com/ravindran-dev)
[![Portfolio](https://img.shields.io/badge/Portfolio-2563EB?style=for-the-badge&logo=google-chrome&logoColor=white)](https://ravindran-dev.github.io)
[![Gmail](https://img.shields.io/badge/Gmail-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:ravindrans.dev@gmail.com)

---

## License

This repository is licensed under the [MIT License](LICENSE).
