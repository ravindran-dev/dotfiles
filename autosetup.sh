
#!/bin/zsh
# =========================================
#    Arch Linux Essentials Setup Script
#   Use this after resetting your Arch PC
#   Author: Ravindran S
# =========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
RESET='\033[0m'
BOLD='\033[1m'

line() {
  printf "${BLUE}%*s${RESET}\n" "$(tput cols)" "" | tr ' ' '-'
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

section "Shell Setup (Zsh)"

sudo pacman -S --noconfirm zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    info "Changing default shell to zsh..."
    chsh -s "$(which zsh)"
fi
success "Zsh installed & configured"

section "System Update"

info "Updating system..."
sudo pacman -Syu --noconfirm
success "System up to date"

section "Mirrorlist"

info "Installing mirrorlist..."
sudo pacman -Syu
success "Mirrorlist synced"

section "Timezone Configuration"

info "Setting timezone to Asia/Kolkata..."
sudo timedatectl set-timezone Asia/Kolkata
success "Timezone set"

section "Installing Arch Essentials"

sudo pacman -S --noconfirm \
    base-devel git wget curl neovim tmux zsh htop btop \
    kdeconnect fastfetch unzip zip zlib xz tk kcalc \
    firefox discord power-profiles-daemon

success "Core packages installed"

section "Installing paru (AUR Helper)"

if [ ! -d ~/paru ]; then
    git clone https://aur.archlinux.org/paru.git ~/paru
    cd ~/paru && makepkg -si --noconfirm && cd ~
fi
success "paru ready"

section "Installing yay (AUR Helper)"

if [ ! -d ~/yay ]; then
    git clone https://aur.archlinux.org/yay.git ~/yay
    cd ~/yay && makepkg -si --noconfirm && cd ~
fi
success "yay ready"

section "Installing Browsers"

export PATH="$HOME/.local/bin:$PATH"
if ! command -v paru &> /dev/null; then
    echo -e "${RED}paru not found. Restart shell or source ~/.zshrc${RESET}"
    exit 1
fi

info "Installing Brave..."
paru -S brave-bin

info "Installing Google Chrome..."
yay -S google-chrome

success "Browsers installed"

section "Installing Spotify"

yay -S spotify
success "Spotify installed"

section "Zsh Theme & Plugins"

mkdir -p ~/.zsh

git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.zsh/powerlevel10k

success "Powerlevel10k & plugins cloned"

section "Tmux Plugin Manager"

if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
success "TPM installed"

section "GitHub CLI"

sudo pacman -S github-cli
gh auth login
success "GitHub authenticated"

echo
line
echo -e "${MAGENTA}${BOLD}  Setup Complete! ${RESET}"
line

echo -e "${GREEN}✔ Run:${RESET} chsh -s $(which zsh)"
echo -e "${GREEN}✔ Tmux:${RESET} prefix + I to install plugins"
echo
echo -e "${CYAN}Post Setup Tips:${RESET}"
echo " • Activate custom mirrorlist if needed"
echo " • Sync Neovim plugins (:Lazy sync)"
echo " • Configure fastfetch & tmux"

line
echo -e "${BOLD}${GREEN}Done! Enjoy your Arch setup ${RESET}"
line


# echo
# echo " Setup complete!"
# echo "--------------------------------------------------"
# echo "✔ Run: chsh -s $(which zsh) to set zsh as default shell."
# echo "✔ Open tmux and press prefix + I to install plugins."
# echo
# echo " After setup, consider:"
# echo "   - cd into each repo & install dependencies"
# echo "   - Download the mirrorlist from the github repo and save it in Downloads and use the below commands to activate"
# echo "   - sudo cp -rf /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak"
# echo "   - sudo cp -rf ~/Downloads/mirrorlist /etc/pacman.d/mirrorlist"
# echo "--------------------------------------------------"
# echo " Done! Enjoy your Arch setup :)"
# =========================================================================================================

# Instructions:
# - Save this as autosetups.sh
# - Make executable: chmod +x ~/dotfiles/autosetup.sh
# - Run: cd ~/dotfiles && ./autosetup.sh

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
# 1. Install the chat.py file in the home directory
# 2. create a python environment like python -m venv chatgpt-env
# 3. source it using source /home/ravi/chatgpt-env/bin/activate and install openai using pip install openai
# 4. Make the chat.py executable using chmod +x chat.py
# 5. Now the chat.py to use gpt in terminal using ./chat.py
# 6. Change the API_KEY value when cloning zshrc config
# 7. Add alias for the chat.py to execute using "alias chatgpt = 'chmod +x chat.py && ./chat.py'"

# ===========================================================================================================

# fastfetch configuration:
# 1. Clone the fastfetch configuration repo
#     cd ~/.local/share
#     git clone https://github.com/LierB/fastfetch
# 2. Download the iron2.png image from the git repo
# 3. place the image in /home/user/.local/share/images/
# 4. Open /home/user/.config/fastfetch/config.jsonc
# 5. Paste the fastfetch config in there

# ===========================================================================================================
# Tmux configuration:
# 1. Follow the instructions given in the readme file of the tmux github repository
# 2. open the github repository https://github.com/ravindran-dev/tmux.git
