#!/usr/bin/env zsh
# =========================================
#    Cross-Distro Essentials Setup Script
#   Arch Linux / Ubuntu / Debian
#   Author: Ravindran S
# =========================================

set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
RESET='\033[0m'
BOLD='\033[1m'

line() {
  printf "${BLUE}%*s${RESET}\n" "$(tput cols 2>/dev/null || echo 100)" "" | tr ' ' '='
}

section() {
  echo
  line
  echo -e "${BOLD}${CYAN}⚙  $1${RESET}"
  line
}

success() {
  echo -e "${GREEN}✔ $1${RESET}"
}

info() {
  echo -e "${YELLOW}➜ $1${RESET}"
}

warning() {
  echo -e "${YELLOW}⚠ $1${RESET}"
}

error() {
  echo -e "${RED}✘ $1${RESET}"
}

# =========================================================================================================

section "Detecting Linux Distribution"

if [[ ! -f /etc/os-release ]]; then
    error "Cannot detect Linux distribution"
    exit 1
fi

source /etc/os-release

case "$ID" in

    arch)
        DISTRO="arch"
        NATIVE_PM="pacman"
        ;;

    ubuntu)
        DISTRO="ubuntu"
        NATIVE_PM="apt"
        ;;

    debian)
        DISTRO="debian"
        NATIVE_PM="apt"
        ;;

    *)
        error "Unsupported distribution: $ID"
        exit 1
        ;;

esac

success "Detected: $PRETTY_NAME"
info "Native package manager: $NATIVE_PM"

# =========================================================================================================

section "Installing Build Dependencies"

if [[ "$DISTRO" == "arch" ]]; then

    sudo pacman -S --needed --noconfirm \
        git \
        base-devel \
        curl

elif [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then

    sudo apt update

    sudo apt install -y \
        git \
        build-essential \
        curl

fi

success "Build dependencies ready"

# =========================================================================================================

section "Installing Rust and Cargo"

export PATH="$HOME/.cargo/bin:$PATH"

if command -v cargo >/dev/null 2>&1 && command -v rustc >/dev/null 2>&1; then

    success "Rust and Cargo already installed"

else

    if [[ "$DISTRO" == "arch" ]]; then

        info "Installing rustup using pacman..."

        sudo pacman -S --needed --noconfirm rustup

        export PATH="$HOME/.cargo/bin:$PATH"

        if command -v rustup >/dev/null 2>&1; then
            rustup default stable
        fi

    elif [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then

        info "Installing Rust using rustup..."

        if ! command -v rustup >/dev/null 2>&1; then

            curl --proto '=https' \
                 --tlsv1.2 \
                 -sSf \
                 https://sh.rustup.rs \
                 | sh -s -- -y

        fi

        export PATH="$HOME/.cargo/bin:$PATH"

        rustup default stable

    fi

fi

export PATH="$HOME/.cargo/bin:$PATH"

if ! command -v cargo >/dev/null 2>&1; then
    error "Cargo installation failed"
    exit 1
fi

if ! command -v rustc >/dev/null 2>&1; then
    error "Rust installation failed"
    exit 1
fi

success "Rust: $(rustc --version)"
success "Cargo: $(cargo --version)"

# =========================================================================================================

section "Installing Archon CLI"

export PATH="$HOME/.cargo/bin:$PATH"

if command -v archon >/dev/null 2>&1; then

    success "Archon CLI already installed"

else

    info "Installing archon-cli using Cargo..."

    if ! cargo install archon-cli; then
        error "Failed to install archon-cli"
        exit 1
    fi

fi

export PATH="$HOME/.cargo/bin:$PATH"

if ! command -v archon >/dev/null 2>&1; then
    error "Archon CLI executable not found"
    exit 1
fi

success "Archon CLI ready"

# =========================================================================================================
# Distro-Specific Package Lists
# =========================================================================================================

section "Selecting Packages For $PRETTY_NAME"

NATIVE_QUEUE=()

if [[ "$DISTRO" == "arch" ]]; then

    info "Using Arch Linux package names"

    DISTRO_PACKAGES=(
        zsh
        git
        wget
        curl
        neovim
        tmux
        htop
        btop
        kdeconnect
        fastfetch
        unzip
        zip
        zlib
        xz
        tk
        kcalc
        firefox
        bat
        jq
        upower
        libnotify
        libcanberra
    )

elif [[ "$DISTRO" == "ubuntu" ]]; then

    info "Using Ubuntu package names"

    DISTRO_PACKAGES=(
        zsh
        git
        wget
        curl
        neovim
        tmux
        htop
        btop
        kdeconnect
        fastfetch
        unzip
        zip
        zlib1g
        xz-utils
        tk
        kcalc
        firefox
        bat
        jq
        upower
        libnotify-bin
        libcanberra-gtk3-module
    )

elif [[ "$DISTRO" == "debian" ]]; then

    info "Using Debian package names"

    DISTRO_PACKAGES=(
        zsh
        git
        wget
        curl
        neovim
        tmux
        htop
        btop
        kdeconnect
        fastfetch
        unzip
        zip
        zlib1g
        xz-utils
        tk
        kcalc
        firefox
        bat
        jq
        upower
        libnotify-bin
        libcanberra-gtk3-module
    )

fi

success "Selected ${#DISTRO_PACKAGES[@]} packages"

# =========================================================================================================

section "Installing Distro Packages Through Archon"

info "Archon will receive only packages valid for $DISTRO."

for package in "${DISTRO_PACKAGES[@]}"; do

    echo
    info "Archon → $package"

    if archon install "$package" --yes; then

        success "$package installed through Archon"

    else

        warning "$package failed through Archon"
        NATIVE_QUEUE+=("$package")

    fi

done

# =========================================================================================================

section "Installing Archon Fallback Queue"

if (( ${#NATIVE_QUEUE[@]} == 0 )); then

    success "No fallback packages required"

else

    warning "Archon failed for the following packages:"
    printf '  - %s\n' "${NATIVE_QUEUE[@]}"

    if [[ "$DISTRO" == "arch" ]]; then

        info "Installing fallback packages using pacman..."

        sudo pacman -S --needed --noconfirm \
            "${NATIVE_QUEUE[@]}"

    elif [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then

        info "Installing fallback packages using apt..."

        sudo apt update

        sudo apt install -y \
            "${NATIVE_QUEUE[@]}"

    fi

    success "Native fallback installation completed"

fi

# =========================================================================================================

section "Installing Zsh Plugins"

ZSH_DIR="$HOME/.zsh"

mkdir -p "$ZSH_DIR"

if [[ ! -d "$ZSH_DIR/zsh-autosuggestions/.git" ]]; then

    info "Installing zsh-autosuggestions..."

    rm -rf "$ZSH_DIR/zsh-autosuggestions"

    git clone \
        https://github.com/zsh-users/zsh-autosuggestions.git \
        "$ZSH_DIR/zsh-autosuggestions"

else

    info "zsh-autosuggestions already installed"

fi

if [[ ! -d "$ZSH_DIR/zsh-syntax-highlighting/.git" ]]; then

    info "Installing zsh-syntax-highlighting..."

    rm -rf "$ZSH_DIR/zsh-syntax-highlighting"

    git clone \
        https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$ZSH_DIR/zsh-syntax-highlighting"

else

    info "zsh-syntax-highlighting already installed"

fi

success "Zsh plugins installed"

# =========================================================================================================

section "Configure Rust"

export PATH="$HOME/.cargo/bin:$PATH"

if command -v rustup >/dev/null 2>&1; then

    rustup default stable

    success "Rust stable configured"

fi

# =========================================================================================================

section "Configure Zsh"

ZSH_BIN="$(command -v zsh || true)"

if [[ -n "$ZSH_BIN" ]]; then

    if [[ "$SHELL" != "$ZSH_BIN" ]]; then

        info "Setting Zsh as default shell..."

        chsh -s "$ZSH_BIN" "$USER" || true

    fi

    success "Zsh configured"

else

    warning "Zsh was not found"

fi

# =========================================================================================================

section "Installing Arch-Specific Tools"

if [[ "$DISTRO" == "arch" ]]; then

    section "Installing paru"

    if ! command -v paru >/dev/null 2>&1; then

        rm -rf "$HOME/paru"

        git clone \
            https://aur.archlinux.org/paru.git \
            "$HOME/paru"

        cd "$HOME/paru"

        makepkg -si --noconfirm

        cd "$HOME"

    else

        info "paru already installed"

    fi

    success "paru ready"

    section "Installing yay"

    if ! command -v yay >/dev/null 2>&1; then

        rm -rf "$HOME/yay"

        git clone \
            https://aur.archlinux.org/yay.git \
            "$HOME/yay"

        cd "$HOME/yay"

        makepkg -si --noconfirm

        cd "$HOME"

    else

        info "yay already installed"

    fi

    success "yay ready"

fi

# =========================================================================================================

section "Installing Arch Applications"

if [[ "$DISTRO" == "arch" ]]; then

    info "Installing Brave..."

    if ! archon install brave-bin --yes; then
        paru -S --needed --noconfirm brave-bin
    fi

    info "Installing Google Chrome..."

    if ! archon install google-chrome --yes; then
        yay -S --needed --noconfirm google-chrome
    fi

    info "Installing Spotify..."

    if ! archon install spotify --yes; then
        yay -S --needed --noconfirm spotify
    fi

else

    info "Skipping Arch/AUR applications"

fi

# =========================================================================================================

# Nvim configuration:
# cd ~/.config/nvim
# git clone https://github.com/ravindran-dev/nvim.git
# Open nvim (where it automatically installs the plugins)
# Now do :Lazy sync to sync the packages
# Also do :Mason for better language synchronisation

# =========================================================================================================

# Pacman progress bar:
# To enable pacman candy progress bar:
#   sudo nano /etc/pacman.conf
#   Add under [options]:
#       ILoveCandy

# ===========================================================================================================

# Chatgpt in terminal:
# 2. Install the chat.py file in the home directory
# 3. create a python environment like python -m venv chatgpt-env
# 4. source it using source /home/ravi/chatgpt-env/bin/activate and install openai using pip install openai
# 5. Make the chat.py executable using chmod +x chat.py
# 6. Now the chat.py to use gpt in terminal using ./chat.py
# 7. Change the API_KEY value when cloning zshrc config
# 8. Add alias for the chat.py to execute using "alias chatgpt = 'chmod +x chat.py && ./chat.py'"

# ===========================================================================================================

# fastfetch configuration:
# 2. Clone the fastfetch configuration repo
#     cd ~/.local/share
#     git clone https://github.com/LierB/fastfetch
# 3. Download the iron2.png image from the git repo
# 4. place the image in /home/user/.local/share/images/
# 5. Open /home/user/.config/fastfetch/config.jsonc
# 6. Paste the fastfetch config in there

# ===========================================================================================================
# Tmux configuration:
# 2. Follow the instructions given in the readme file of the tmux github repository
# 3. open the github repository https://github.com/ravindran-dev/tmux.git

# =========================================================================================================

section "Setup Complete"

line

echo -e "${GREEN}✔ Distribution:${RESET} $PRETTY_NAME"
echo -e "${GREEN}✔ Native package manager:${RESET} $NATIVE_PM"
echo -e "${GREEN}✔ Rust:${RESET} $(rustc --version 2>/dev/null || echo unavailable)"
echo -e "${GREEN}✔ Cargo:${RESET} $(cargo --version 2>/dev/null || echo unavailable)"
echo -e "${GREEN}✔ Archon:${RESET} installed"
echo -e "${GREEN}✔ Zsh:${RESET} installed"
echo -e "${GREEN}✔ Zsh plugins:${RESET} installed"

if (( ${#NATIVE_QUEUE[@]} > 0 )); then

    echo
    warning "Packages installed through native fallback:"
    printf '  - %s\n' "${NATIVE_QUEUE[@]}"

fi

line

echo -e "${BOLD}${GREEN}Done! Enjoy your setup ${RESET}"

line

echo
echo -e "${GREEN}✔ Run:${RESET} chsh -s $(which zsh)"
echo -e "${GREEN}✔ Tmux:${RESET} prefix + I to install plugins"

# =========================================================================================================

# Instructions:
# - Save this as autosetups.sh
# - Make executable: chmod +x ~/dotfiles/autosetup.sh
# - Run: cd ~/dotfiles && ./autosetup.sh

# =========================================================================================================

# Setup flow:
#
# 1. Detect Arch / Ubuntu / Debian
# 2. Install Rust and Cargo
# 3. Install archon-cli through Cargo
# 4. Select packages according to the detected distribution
# 5. Install distro-specific packages through Archon
# 6. Put failed Archon packages into the native fallback queue
# 7. Install fallback packages using pacman or apt
# 8. Install Zsh plugins
# 9. Configure Zsh
# 10. Install Arch-specific AUR helpers
# 11. Install distro-specific applications
#
# =========================================================================================================

echo
echo -e "${BOLD}${GREEN}Done! Enjoy your setup ${RESET}"
line
```
