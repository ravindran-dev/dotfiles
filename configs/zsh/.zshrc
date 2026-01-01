fastfetch
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ $- != *i* ]] && return

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' rehash true

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#888888'

alias cls='clear'
alias sdn='shutdown now'
alias ex='exit'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias showimg='display_image'
alias update='sudo pacman -Syu'
alias la='ls -a'
alias ll='ls -alh'
alias cat='bat'
alias chatgpt='source /home/ravi/chatgpt-env/bin/activate && chmod +x chat.py && ./chat.py'
alias metrics='sys'
alias todo='cd todo-tui && cargo run'
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gb='git branch'
alias gd='git diff'

autoload -Uz vcs_info
autoload -U colors && colors

zstyle ':vcs_info:git:*' formats "%F{magenta}   %b%f"
zstyle ':vcs_info:git:*' actionformats "%F{red}   %b|%a%f"
zstyle ':vcs_info:*' enable git

typeset -ga symbols=( "󱞩" "󱞩" "󱞩" "󱞩" "󱞩" "󱞩" )
typeset -gi idx=1

precmd() {
  vcs_info
  PROMPT="
%F{yellow}%D{%H:%M}%f %F{cyan}%n@%m %F{blue}%~%f ${vcs_info_msg_0_}
%F{magenta}${symbols[$idx]}%f "
  (( idx = (idx % ${#symbols[@]}) + 1 ))
}

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt INC_APPEND_HISTORY
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search

bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
bindkey "${terminfo[kcuu1]}" backward-history
bindkey "${terminfo[kcud1]}" forward-history

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%F{red}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}no matches for: %d%f'
zstyle ':completion:*:corrections' format '%F{green}[%d]%f'

setopt correct_all
setopt auto_cd
setopt auto_pushd
setopt autoparamslash

sys() {
  echo "Activating virtual environment..."
  if [ -f "/home/ravi/sys/bin/activate" ]; then
    source /home/ravi/sys/bin/activate
    sysdash
    deactivate
  else
    echo "Error: venv not found"
  fi
}

display_image() {
  if command -v chafa &> /dev/null; then
    chafa "$1"
  elif command -v img2sixel &> /dev/null; then
    img2sixel "$1"
  else
    echo "Image viewer not found"
  fi
}

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export PATH="$PATH:/home/ravi/.local/bin"
export OPENAI_KEY="API_KEY_HERE"

source ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

notify_long_command() {
  if (( SECONDS > 10 )); then
    if [[ $? -eq 0 ]]; then
      notify-send "Command completed in $SECONDS s" "$(fc -ln -1)"
      canberra-gtk-play -i complete >/dev/null 2>&1 &!
    else
      notify-send "Command failed after $SECONDS s" "$(fc -ln -1)"
      canberra-gtk-play -i message-new-email >/dev/null 2>&1 &!
    fi
  fi
}

preexec() { SECONDS=0 }
precmd_functions+=(notify_long_command)

weekly_system_update() {
  local stamp="$HOME/.cache/.weekly_update_stamp"
  local log="$HOME/.cache/weekly_update.log"
  local now=$(date +%s)
  local limit=$((7*24*60*60))

  if [[ -f "$stamp" ]] && (( now - $(cat "$stamp") < limit )); then
    return
  fi

  if command -v upower >/dev/null; then
    local battery=$(upower -e | grep BAT | head -n1)
    if [[ -n "$battery" ]]; then
      local state=$(upower -i "$battery" | awk '/state/ {print $2}')
      [[ "$state" != "charging" && "$state" != "fully-charged" ]] && return
    fi
  fi

  notify-send "Weekly system update started"
  echo "Update started at $(date)" >> "$log"

  sudo pacman -Syu --noconfirm >> "$log" 2>&1

  if command -v paru >/dev/null; then
    paru -Syu --noconfirm >> "$log" 2>&1
  elif command -v yay >/dev/null; then
    yay -Syu --noconfirm >> "$log" 2>&1
  fi

  date +%s >| "$stamp"
  notify-send "Weekly system update completed"
  canberra-gtk-play -i complete >/dev/null 2>&1 &!
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd weekly_system_update

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
