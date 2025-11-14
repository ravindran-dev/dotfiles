# Arch Linux Setup

A fast, clean, and modern **Zsh configuration** built for Arch Linux users.  
This setup includes **Powerlevel10k**, **tmux**, **fastfetch**, **kitty** performance optimizations, system hooks, and developer productivity tools.

---



# 1. Zsh and other configurations
## Features

<a target="_blank" align="center">
  <img align="right" top="500" height="300" width="400" alt="GIF" src="https://camo.githubusercontent.com/5046cb083418fd1922b7f5990e594c3bb06f5d87e5516cd8839ae0aa48b3aec4/68747470733a2f2f696d616765732e73717561726573706163652d63646e2e636f6d2f636f6e74656e742f76312f3537363966633430316236333162616231616464623261622f313534313538303631313632342d5445363451474b524a4738535741495553374e532f6b6531375a77644742546f6464493870446d34386b506f73776c7a6a53564d4d2d53784f703743563539425a772d7a505067646e346a557756634a45315a7657515578776b6d794578676c4e714770304976544a5a616d574c49327a76595748384b332d735f3479737a63703272795449304871544f6161556f68724938504936465879386339505774426c7141566c555335697a7064634958445a71445976707252715a32395077306f2f636f64696e672d667265616b2e676966">
</a>

- **Powerlevel10k Theme** – Optimized for instant prompt and fast startup.
- **Autosuggestions & Syntax Highlighting** – Smarter command-line experience.
- **Fastfetch Integration** – Displays system info on shell startup.
- **Dynamic Prompt** – Git branch, directory, rotating icons, and time.
- **Long Command Notifications** – Desktop alert and sound when long tasks complete.
- **History Search** – Navigate command history using arrow keys.
- **Enhanced Completions** – Case-insensitive, colored, and cached autocompletions.
- **System Utilities Integration**:
  - `exa` for modern directory listing
  - `bat` as a colorized `cat`
  - `zoxide` for smart directory navigation
  - `fzf` for fuzzy search

- **Chatgpt in terminal** - you can use chatgpt in your zsh terminal using chat.py script and the embedding keys of openai. 

## Installation

### 1. Install Dependencies

```bash
sudo pacman -S zsh git libnotify libcanberra
paru -S exa bat fzf zoxide fastfetch ttf-meslo-nerd-font-powerlevel10k
python -m venv chatgpt-env
pip install openai
```

### 2. Clone repositories
```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.zsh/powerlevel10k
source ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

```
# System Setup

This repository contains many components:

1. `clone_repos.sh` – an automated Arch Linux setup script that installs essential system tools, development utilities, AUR helpers, browsers, themes, and configuration plugins.
2. `.zshrc` + supporting files – a fully customized Zsh configuration adapted for fast performance, developer productivity, and Powerlevel10k integration.

This repository helps you quickly restore your development environment after a system reset.

---

# 2. **clone_repos.sh** – Arch Linux Setup Script

##  Overview

`clone_repos.sh` automates the initial post-installation setup on Arch Linux.  
It includes:

- System update and mirrorlist refresh  
- Timezone configuration  
- Installation of common utilities and development tools  
- Installation of AUR helpers (paru, yay)  
- Browser installation (Brave, Chrome)  
- Editor installation (VS Code)  
- Multimedia tools (Spotify)  
- Snapd setup  
- Powerlevel10k, Zsh plugins, and Tmux Plugin Manager installation  
- GitHub CLI integration and login prompt  

This script is intended to automate and standardize your Arch environment setup.

## Usage

```bash
chmod +x clone_repos.sh
./clone_repos.sh
```

## Features

- Updates system packages (pacman -Syu)

- Adds and refreshes Arch mirrorlist

- Installs essential CLI tools (neovim, curl, wget, unzip, zlib, etc.)

- Installs desktop utilities (firefox, discord, kdeconnect)

- Installs AUR helpers (paru, yay)

- Installs code editors and browsers (visual-studio-code-bin, brave-bin, google-chrome)

- Enables Snap support

- Installs Zsh plugins

- Powerlevel10k

- zsh-autosuggestions

- zsh-syntax-highlighting

- Installs Tmux Plugin Manager (TPM)

- Installs GitHub CLI and prompts authentication

# License

This configuration is open-sourced under the MIT License.
Feel free to fork, modify, or reuse with credit.

# Author
<a target="_blank" align="center">
  <img align="right" top="500" right="50" height="200" width="200" alt="GIF" src="https://media.tenor.com/IieZUsqoYCwAAAAM/developer.gif">
</a>

- [Ravindran S](https://github.com/ravindran-dev)
-  SDE
-  FSD 
-  ML Developer
-  Arch Linux
