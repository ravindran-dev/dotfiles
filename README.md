<p align="center">
  <img src="iron2.png" width="130" height="130" alt="Arch Linux Setup" style="border-radius: 50%;" />
</p>

<h1 align="center">⚡ Arch Linux Dotfiles & Workstation Environment</h1>

<p align="center">
  <em>A high-performance, minimalist workstation configuration featuring Hyprland, Waybar, Zsh, Kitty, and automated cross-distro provisioning.</em>
</p>

<p align="center">
  <a href="https://archlinux.org"><img src="https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white" alt="Arch Linux" /></a>
  <a href="https://hyprland.org"><img src="https://img.shields.io/badge/Hyprland-00AAEE?style=for-the-badge&logo=wayland&logoColor=white" alt="Hyprland" /></a>
  <a href="https://github.com/Alexays/Waybar"><img src="https://img.shields.io/badge/Waybar-2E3440?style=for-the-badge&logo=linux&logoColor=white" alt="Waybar" /></a>
  <a href="https://www.zsh.org"><img src="https://img.shields.io/badge/Zsh-F15A24?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Zsh" /></a>
  <a href="https://sw.kovidgoyal.net/kitty/"><img src="https://img.shields.io/badge/Kitty-111111?style=for-the-badge&logo=kitty&logoColor=white" alt="Kitty" /></a>
  <a href="https://www.python.org"><img src="https://img.shields.io/badge/Python_3.12+-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-22C55E?style=for-the-badge" alt="License" /></a>
</p>

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Repository Structure](#-repository-structure)
- [Key Modules & Features](#-key-modules--features)
  - [1. Hyprland & Waybar Wi-Fi Hotspot Suite](#1--hyprland--waybar-wi-fi-hotspot-suite-hotspot)
  - [2. Zsh Shell Environment](#2--zsh-shell-environment-zsh)
  - [3. Kitty Terminal & Fastfetch](#3--kitty-terminal--fastfetch-configs)
  - [4. Automated Setup Script](#4--automated-setup-script-autosetupsh)
  - [5. ChatGPT in Terminal](#5--chatgpt-in-terminal-chatpy)
- [Quick Start & Installation](#-quick-start--installation)
- [Keybindings Reference](#-keybindings-reference)
- [Author & Socials](#-author)

---

## 🔍 Overview

This repository contains my personal, battle-tested system dotfiles for Arch Linux. Designed for speed, developer ergonomics, and visual elegance, it provides:

- **Automated Provisioning**: One script (`autosetup.sh`) to restore your complete developer workstation from a fresh installation.
- **Rofi + Waybar Hotspot Manager**: Native Linux hotspot suite with hardened WPA2-AES security, Protected Management Frames (802.11w), client management, and real-time Waybar status.
- **Optimized Shell Experience**: Low-latency Zsh environment with autosuggestions, syntax highlighting, customized GNU dircolors, and smart completions.
- **Modern CLI Stack**: Integrated `bat`, `fzf`, `zoxide`, `fastfetch`, and custom AI terminal tooling.

---

## 📂 Repository Structure

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

## 🚀 Key Modules & Features

### 1. 󰤨 Hyprland & Waybar Wi-Fi Hotspot Suite (`hotspot/`)

A native, interactive Wi-Fi hotspot management system tailored for Waybar and Hyprland desktops:

- **Hardened Security**: Pre-configured with **WPA2-AES (CCMP)** and **PMF (802.11w)** to eliminate iOS / Apple *"Weak Security"* warnings and ensure instant connection.
- **Matte Rofi Menu (`Super + F`)**: Clean dialog for starting/stopping the AP, viewing or generating credentials, and monitoring clients.
- **Live Status Indicator**: Waybar module displaying active connection state with one-click toggling.
- **Device Management**: SQLite session logging, real-time client traffic stats, and firewall-level device blacklisting.
- **Zero Secrets in Git**: Random passwords handled securely via NetworkManager with no credentials committed.

---

### 2. ⚡ Zsh Shell Environment (`zsh/`)

Crafted for immediate responsiveness and developer ergonomics:

- **Instant Startup**: Lightweight configuration without bloated framework overhead.
- **Intelligent Autocompletion**: Case-insensitive matcher, cached completion engine, and arrow-key history search.
- **Syntax Highlighting & Autosuggestions**: Real-time feedback with fish-like command history autosuggestions.
- **Clean Dircolors**: Custom highlight mechanism eliminating unreadable bright green backgrounds on `other-writable` directories.
- **Dynamic Git Prompt**: Minimal prompt displaying current branch, dirty state, staged changes, and execution status.
- **Smart Aliases**: Pre-mapped shortcuts for Git, system maintenance, image previewing, and modern CLI tools (`bat`, `cls`, `update`).

---

### 3. 🐱 Kitty Terminal & Fastfetch (`configs/`)

- **GPU Acceleration**: Fluid scrolling, minimal latency, and full 24-bit truecolor rendering.
- **Custom Typography**: Configured with `FantasqueSansM Nerd Font Mono` with smooth cursor trails and subtle background opacity (0.9).
- **Fastfetch Dual Modes**: Includes both full hardware readout and a compact mode for quick shell startup.

---

### 4. ⚙️ Automated Setup Script (`autosetup.sh`)

A robust, idempotent shell script that provisions a complete development workstation:

- **Multi-Distro Support**: Autodetects **Arch Linux**, **Ubuntu**, and **Debian**.
- **Toolchain Bootstrap**: Builds Rust/Cargo, Git, base development packages, and AUR helpers (`paru`, `yay`).
- **Core CLI Stack**: Installs `neovim`, `zsh`, `bat`, `fzf`, `zoxide`, `fastfetch`, and `eza`.
- **Desktop & Browsers**: Sets up VS Code, Brave, Google Chrome, Spotify, and font packages (`ttf-meslo-nerd-font-powerlevel10k`).
- **GitHub Integration**: Preconfigures GitHub CLI (`gh`) and prompts authentication.

---

### 5. 🤖 ChatGPT in Terminal (`chat.py`)

A clean Python terminal client for OpenAI's GPT models:

- Context-aware conversation threads in your terminal.
- Simple setup using your own OpenAI API key via `OPENAI_KEY` environment variable.

---

## 🛠️ Quick Start & Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/ravindran-dev/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### Step 2: Run Full Automated Setup (Recommended for fresh systems)

```bash
chmod +x autosetup.sh
./autosetup.sh
```

### Step 3: Install Hotspot Suite (Standalone)

```bash
cd ~/dotfiles/hotspot
sudo pacman -S --needed networkmanager dnsmasq rofi python libnotify
python3 install.py
hyprctl reload
pkill -SIGUSR2 -x waybar
```

### Step 4: Deploy Zsh Configuration

```bash
# Backup existing config
[ -f ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.bak

# Link dotfiles zsh config
cp ~/dotfiles/zsh/.zshrc ~/.zshrc
source ~/.zshrc
```

---

## ⌨️ Keybindings Reference

| Shortcut | Context | Action |
| :--- | :--- | :--- |
| `Super + F` | Global (Hyprland) | Open Hotspot Settings Menu / Toggle Dialog |
| `Right Click` | Waybar Hotspot Icon | Instantly toggle Hotspot ON / OFF |
| `Left Click` | Waybar Hotspot Icon | Open Hotspot GUI Menu |
| `Alt + S` | Hotspot Password Dialog | Toggle Password Visibility (Show/Hide) |
| `Ctrl + R` | Zsh | Fuzzy History Search (`fzf`) |
| `Up / Down` | Zsh | History Prefix Navigation |

---

## 👨‍💻 Author

<p align="center">
  <img src="me.png" width="120" height="180" alt="Ravindran S" style="border-radius: 12px; object-fit: cover;" />
</p>

<p align="center">
  <strong>Ravindran S</strong><br />
  <em>Software Development Engineer • Full-Stack Developer • Systems & ML Enthusiast</em>
</p>

<p align="center">
  <a href="https://www.linkedin.com/in/ravindran-s-982702327" target="_blank">
    <img src="https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn" />
  </a>
  <a href="https://github.com/ravindran-dev" target="_blank">
    <img src="https://img.shields.io/badge/GitHub-111111?style=for-the-badge&logo=github&logoColor=white" alt="GitHub" />
  </a>
  <a href="https://ravindran-dev.github.io" target="_blank">
    <img src="https://img.shields.io/badge/Portfolio-2563EB?style=for-the-badge&logo=google-chrome&logoColor=white" alt="Portfolio" />
  </a>
  <a href="mailto:ravindrans.dev@gmail.com">
    <img src="https://img.shields.io/badge/Gmail-D14836?style=for-the-badge&logo=gmail&logoColor=white" alt="Gmail" />
  </a>
</p>

---

## 📄 License

This repository is licensed under the [MIT License](LICENSE). Feel free to fork, adapt, and customize it to suit your workflow.
