#!/bin/zsh
# =========================================
#    Arch Linux Essentials Setup Script
#   Use this after resetting your Arch PC
#   Author: Ravindran S
# =========================================


sudo pacman -S --noconfirm zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    echo ">>> Changing default shell to zsh..."
    chsh -s "$(which zsh)"
fi


echo ">>> Updating system..."
sudo pacman -Syu --noconfirm


echo ">>> Installing mirrorlist..."
sudo cp -rf /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
sudo cp -rf ~/Downloads/mirrorlist /etc/pacman.d/mirrorlist
sudo pacman -Syu


echo ">>> Setting timezone to Asia/Kolkata..."
sudo timedatectl set-timezone Asia/Kolkata


echo ">>> Installing Arch essentials..."
sudo pacman -S --noconfirm \
    base-devel git wget curl neovim tmux zsh htop btop \
    kdeconnect fastfetch unzip zip zlib xz tk kcalc \
    firefox discord power-profiles-daemon



echo ">>> Installing paru (AUR helper)..."
if [ ! -d ~/paru ]; then
    git clone https://aur.archlinux.org/paru.git ~/paru
    cd ~/paru && makepkg -si --noconfirm && cd ~
fi


echo ">>> Installing yay (AUR helper)..."
if [ ! -d ~/yay ]; then
    git clone https://aur.archlinux.org/yay.git ~/yay
    cd ~/yay && makepkg -si --noconfirm && cd ~
fi


echo ">>> Installing Brave browser..."
export PATH="$HOME/.local/bin:$PATH"
if ! command -v paru &> /dev/null; then
    echo "paru not found. Please restart your shell or source ~/.zshrc before running this script."
    exit 1
fi
paru -S brave-bin


echo ">>> Installing Google Chrome..."
yay -S google-chrome

echo ">>> Installing Spotify..."
yay -S spotify


echo ">>> Cloning Powerlevel10k and Zsh plugins..."
mkdir -p ~/.zsh

git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.zsh/powerlevel10k

echo ">>> Cloning Tmux Plugin Manager..."
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi


echo ">>> Installing GitHub CLI and authenticating..."
sudo pacman -S github-cli
gh auth login


echo
echo " Setup complete!"
echo "--------------------------------------------------"
echo "✔ Run: chsh -s $(which zsh) to set zsh as default shell."
echo "✔ Open tmux and press prefix + I to install plugins."
echo
echo " After setup, consider:"
echo "   - cd into each repo & install dependencies"
echo "   - For React: npm install"
echo "   - For Flask: pip install -r requirements.txt"
echo "--------------------------------------------------"
echo ">>> Done! Enjoy your Arch setup :)"
# =========================================================================================================

# Instructions:
# - Save this as clone_repos.sh
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

# ===========================================================================================================

# fastfetch configuration:
# 1. Clone the fastfetch configuration repo
#     cd ~/.local/share
#     git clone https://github.com/LierB/fastfetch
# 2. Download the iron2.png image from the git repo
# 3. place the image in /home/user/.local/share/images/
# 4. Open /home/user/.config/fastfetch/config.jsonc
# 5. Paste the fastfetch config in there

# ============================================================================================================
