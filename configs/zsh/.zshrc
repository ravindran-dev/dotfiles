
fastfetch

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
alias todo='cd todo-tui && cargo run && cd'
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gb='git branch'
alias gd='git diff'
alias health='linux-health && go run ./cmd/linux-health && cd'
alias jarvis='cd Jarvis && cargo run && cd'




autoload -Uz colors && colors
setopt prompt_subst


NEON_BLUE="%F{39}"
NEON_CYAN="%F{51}"
NEON_GREEN="%F{82}"
NEON_PINK="%F{213}"
NEON_PURPLE="%F{141}"
NEON_YELLOW="%F{226}"
NEON_RED="%F{196}"
RESET="%f"

ICON=""





git_prompt() {
  command git rev-parse --is-inside-work-tree &>/dev/null || return

  local branch staged unstaged out

  branch=$(command git symbolic-ref --short HEAD 2>/dev/null \
        || command git describe --tags --exact-match 2>/dev/null)

  # Count staged files
  staged=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')

  # Count unstaged + untracked files
  unstaged=$(
    { git diff --name-only 2>/dev/null
      git ls-files --others --exclude-standard 2>/dev/null; } | sort -u | wc -l | tr -d ' '
  )

  out="%F{213} ${branch}%f"

  # Show staged count
  (( staged > 0 )) && out+=" %F{82}${staged}%f"

  # Show unstaged / untracked count
  (( unstaged > 0 )) && out+=" %F{226}${unstaged}%f"

  print -P "$out"
}


venv_prompt() {
  [[ -n "$VIRTUAL_ENV" ]] || return
  local venv_name="${VIRTUAL_ENV:t}"
  echo "${NEON_GREEN} ${venv_name}${RESET}"
}


path_prompt() {
  echo "${NEON_BLUE}  %~${RESET}"
}


precmd() {
  local time=" %D{%H:%M}"
  local user="  %n@%m"
  local git="$(git_prompt)"
  local venv="$(venv_prompt)"
  local path="$(path_prompt)"

  PROMPT="
${NEON_CYAN}${ICON}${RESET}  ${NEON_YELLOW}${time}${RESET}  ${NEON_PURPLE}${user}${RESET}  ${path}  ${git}  ${venv}
${NEON_CYAN}󱞩${RESET} "
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


source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export PATH="$PATH:/home/ravi/.local/bin"
export OPENAI_KEY="API_KEY_HERE"


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
