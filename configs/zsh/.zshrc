# ZSHRC created and maintained by Ravindran S

[[ $- != *i* ]] && return

export PATH="$PATH:/home/ravi/.local/bin"
export OPENAI_KEY="API_KEY_HERE"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

autoload -Uz compinit colors add-zsh-hook
compinit
colors

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
alias rustbook='firefox ~/book/book/index.html'

NEON_BLUE="%{%F{39}%}"
NEON_CYAN="%{%F{51}%}"
NEON_GREEN="%{%F{82}%}"
NEON_PINK="%{%F{213}%}"
NEON_PURPLE="%{%F{141}%}"
NEON_YELLOW="%{%F{226}%}"
NEON_RED="%{%F{196}%}"
RESET="%{%f%}"

ICON=""
setopt prompt_subst

git_prompt() {
  command git rev-parse --is-inside-work-tree &>/dev/null || return
  local branch staged unstaged out
  branch=$(command git symbolic-ref --short HEAD 2>/dev/null || command git describe --tags --exact-match 2>/dev/null)
  staged=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
  unstaged=$({ git diff --name-only 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null; } | sort -u | wc -l | tr -d ' ')
  out="%F{213}  ${branch}%f"
  (( staged > 0 )) && out+=" %F{82} ${staged}%f"
  (( unstaged > 0 )) && out+=" %F{226} ${unstaged}%f"
  print -P "$out"
}

venv_prompt() {
  [[ -n "$VIRTUAL_ENV" ]] || return
  echo "${NEON_GREEN} ${VIRTUAL_ENV:t}${RESET}"
}

path_prompt() {
  echo "${NEON_BLUE} %~${RESET}"
}
distro_prompt() {
  local name
  name=$(awk -F= '/^NAME=/{gsub(/"/,""); print $2}' /etc/os-release 2>/dev/null)
  [[ -n "$name" ]] || return
  echo "${NEON_CYAN}${name}${RESET}"
}

precmd() {
  local distro="$(distro_prompt)"

  local time=" %D{%H:%M}"
  local user=" %n@%m"
  local git="$(git_prompt)"
  local venv="$(venv_prompt)"
  local path="$(path_prompt)"
  PROMPT="${NEON_CYAN}${ICON}${RESET} ${distro} ${NEON_YELLOW}${time}${RESET} ${NEON_PURPLE}${user}${RESET} ${path} ${git} ${venv}
${NEON_CYAN}󱞩${RESET} "
}

setopt APPEND_HISTORY SHARE_HISTORY HIST_EXPIRE_DUPS_FIRST INC_APPEND_HISTORY
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000

autoload -U up-line-or-beginning-search down-line-or-beginning-search
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
bindkey "${terminfo[kcuu1]}" backward-history
bindkey "${terminfo[kcud1]}" forward-history

setopt correct_all auto_cd auto_pushd autoparamslash

sys() {
  if [ -f "/home/ravi/sys/bin/activate" ]; then
    source /home/ravi/sys/bin/activate
    sysdash
    deactivate
  else
    echo "Error: venv not found"
  fi
}

autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic
zle-line-init() { zle -R }
zle -N zle-line-init

FASTFETCH_SHOWN=0



hyprland_is_single_window() {
  command -v hyprctl >/dev/null || return 1

  local ws windows json

  json=$(hyprctl activeworkspace -j 2>/dev/null)
  [[ -z "$json" ]] && return 1

  ws=$(echo "$json" | jq -r '.id // empty' 2>/dev/null)
  [[ -z "$ws" || ! "$ws" =~ '^[0-9]+$' ]] && return 1

  json=$(hyprctl clients -j 2>/dev/null)
  [[ -z "$json" ]] && return 1

  windows=$(echo "$json" \
    | jq --argjson ws "$ws" '[.[] | select(.workspace.id == $ws)] | length' 2>/dev/null)

  [[ "$windows" =~ '^[0-9]+$' && "$windows" -eq 1 ]]
}
show_fastfetch_once() {
  [[ $FASTFETCH_SHOWN -eq 1 ]] && return
  hyprland_is_single_window || return
  FASTFETCH_SHOWN=1
  sleep 0.12
  print -Pn "\e[2J\e[H"
  fastfetch
}

add-zsh-hook precmd show_fastfetch_once

preexec() { SECONDS=0 }

notify_long_command() {
  (( SECONDS > 10 )) || return
  if [[ $? -eq 0 ]]; then
    notify-send "Command completed in $SECONDS s" "$(fc -ln -1)"
    canberra-gtk-play -i complete >/dev/null 2>&1 &!
  else
    notify-send "Command failed after $SECONDS s" "$(fc -ln -1)"
    canberra-gtk-play -i message-new-email >/dev/null 2>&1 &!
  fi
}

add-zsh-hook precmd notify_long_command

weekly_system_update() {
  local stamp="$HOME/.cache/.weekly_update_stamp"
  local log="$HOME/.cache/weekly_update.log"
  local now=$(date +%s)
  local limit=$((7*24*60*60))
  [[ -f "$stamp" ]] && (( now - $(cat "$stamp") < limit )) && return
  if command -v upower >/dev/null; then
    local battery=$(upower -e | grep BAT | head -n1)
    [[ -n "$battery" ]] || return
    local state=$(upower -i "$battery" | awk '/state/ {print $2}')
    [[ "$state" != "charging" && "$state" != "fully-charged" ]] && return
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

add-zsh-hook precmd weekly_system_update

draw_separator() {
  local cols=${COLUMNS:-120}
  local line="${(l:${cols}::─:)}"
  print -P "%F{240}${line}%f"
}

add-zsh-hook precmd draw_separator
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
