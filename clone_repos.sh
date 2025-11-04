#!/bin/zsh
# =========================================
#   🚀 Arch Linux Essentials Setup Script
#   Use this after resetting your Arch PC
#   Author: Ravindran S
# =========================================

# ----------- 🐚 CHANGE DEFAULT SHELL TO ZSH -----------
sudo pacman -S --noconfirm zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    echo ">>> Changing default shell to zsh..."
    chsh -s "$(which zsh)"
fi

# ----------- 🔄 SYSTEM UPDATE -----------
echo ">>> Updating system..."
sudo pacman -Syu --noconfirm

# ----------- 🌐 MIRRORLIST SETUP -----------
echo ">>> Installing mirrorlist..."
sudo cp -rf /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
sudo cp -rf ~/Downloads/mirrorlist /etc/pacman.d/mirrorlist
sudo pacman -Syu

# ----------- 🕒 TIMEZONE CONFIGURATION -----------
echo ">>> Setting timezone to Asia/Kolkata..."
sudo timedatectl set-timezone Asia/Kolkata

# ----------- ⚙️ ESSENTIAL PACKAGES -----------
echo ">>> Installing Arch essentials..."
sudo pacman -S --noconfirm \
    base-devel git wget curl neovim tmux zsh htop btop \
    kdeconnect fastfetch unzip zip zlib xz tk kcalc \
    firefox discord

# ----------- 🧰 AUR HELPERS -----------
## Paru
echo ">>> Installing paru (AUR helper)..."
if [ ! -d ~/paru ]; then
    git clone https://aur.archlinux.org/paru.git ~/paru
    cd ~/paru && makepkg -si --noconfirm && cd ~
fi

## Yay
echo ">>> Installing yay (AUR helper)..."
if [ ! -d ~/yay ]; then
    git clone https://aur.archlinux.org/yay.git ~/yay
    cd ~/yay && makepkg -si --noconfirm && cd ~
fi

# ----------- 🌍 BROWSERS & APPS -----------
echo ">>> Installing Brave browser..."
export PATH="$HOME/.local/bin:$PATH"
if ! command -v paru &> /dev/null; then
    echo "paru not found. Please restart your shell or source ~/.zshrc before running this script."
    exit 1
fi
paru -S brave-bin

echo ">>> Installing Visual Studio Code..."
yay -S visual-studio-code-bin

echo ">>> Installing Google Chrome..."
yay -S google-chrome

echo ">>> Installing Spotify..."
yay -S spotify

# ----------- 🧩 SNAP SUPPORT -----------
echo ">>> Installing snapd..."
yay -S --noconfirm snapd
sudo systemctl enable --now snapd.socket

if [ ! -e /snap ]; then
    sudo ln -s /var/lib/snapd/snap /snap
fi

snap version
sudo snap install hello-world

# ----------- 🎨 SHELL CONFIG (ZSH + POWERLEVEL10K) -----------
echo ">>> Cloning Powerlevel10k and Zsh plugins..."
mkdir -p ~/.zsh

git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.zsh/powerlevel10k

# ----------- 🧱 TMUX CONFIG -----------
echo ">>> Cloning Tmux Plugin Manager..."
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# ----------- 🧾 GITHUB CLI -----------
echo ">>> Installing GitHub CLI and authenticating..."
sudo pacman -S github-cli
gh auth login

# ----------- ✅ FINAL MESSAGE -----------
echo
echo "🎉 Setup complete!"
echo "--------------------------------------------------"
echo "✔ Run: chsh -s $(which zsh) to set zsh as default shell."
echo "✔ Open tmux and press prefix + I to install plugins."
echo
echo "💡 After setup, consider:"
echo "   - cd into each repo & install dependencies"
echo "   - For React: npm install"
echo "   - For Flask: pip install -r requirements.txt"
echo "--------------------------------------------------"
echo ">>> Done! Enjoy your Arch setup :)"
# =========================================
# NOTES:
# - Save this as clone_repos.sh
# - Make executable: chmod +x ~/dotfiles/clone_repos.sh
# - Run: cd ~/dotfiles && ./clone_repos.sh
# =========================================
# EXTRAS:
# git clone https://github.com/Fawz-Haaroon/nvim ~/.config/nvim
# cd ~/.config/nvim && chmod +x install.sh && bash ./install.sh
# =========================================
# OPTIONAL:
# To enable pacman candy progress bar:
#   sudo nano /etc/pacman.conf
#   Add under [options]:
#       ILoveCandy
# =========================================
