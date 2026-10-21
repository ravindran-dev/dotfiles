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

# Custom two-line prompt. Dynamic names are literal text, never shell code.
unsetopt prompt_subst

git_prompt() {
  local report branch line x y
  local -i staged=0 changed=0 untracked=0
  report=$(command git --no-optional-locks status --porcelain=v1 --branch 2>/dev/null) || return
  local -a entries
  entries=("${(@f)report}")
  branch=${entries[1]#\#\# }
  branch=${branch%%...*}
  branch=${branch#No commits yet on }
  branch=${branch#Initial commit on }
  [[ $branch == 'HEAD (no branch)' ]] && branch=$(command git rev-parse --short HEAD 2>/dev/null)
  branch=${branch//\%/%%}
  for line in "${entries[@]:1}"; do
    x=${line[1]}; y=${line[2]}
    if [[ $x == '?' ]]; then
      (( untracked++ ))
    else
      [[ $x != ' ' ]] && (( staged++ ))
      [[ $y != ' ' ]] && (( changed++ ))
    fi
  done
  local result="%F{141} ${branch}%f"
  (( staged )) && result+=" %F{120}+${staged}%f"
  (( changed )) && result+=" %F{222}~${changed}%f"
  (( untracked )) && result+=" %F{117}?${untracked}%f"
  print -r -- "$result"
}

precmd() {
  local -i last_status=$?
  local -i width=${COLUMNS:-80}
  local git='' venv='' details=''
  local -i path_width=$(( width / 2 ))
  (( path_width < 12 )) && path_width=12

  if (( width >= 65 )); then
    git=$(git_prompt)
    [[ -n $git ]] && details+=" %F{245}·%f ${git}"
    if [[ -n $VIRTUAL_ENV ]]; then
      venv=${VIRTUAL_ENV:t}
      venv=${venv//\%/%%}
      details+=" %F{245}·%f %F{120}py:${venv}%f"
    fi
  fi

  PROMPT='%F{81}╭─%f '
  (( width >= 95 )) && PROMPT+='%F{250}%n%f %F{245}·%f '
  [[ -n $SSH_CONNECTION ]] && PROMPT+='%F{222}@%m%f '
  PROMPT+="%F{117}%${path_width}<…<%~%<<%f${details}"
  PROMPT+=$'\n''%F{81}╰─%f '
  if (( last_status )); then
    PROMPT+="%F{203}× ${last_status} %f"
  fi
  PROMPT+='%(#.%F{203}#.%F{120}❯)%f '
  # Clip long branches and environments to keep the upper line inside the pane.
  PROMPT="%$((width > 4 ? width - 2 : 2))<…<${PROMPT%%$'\n'*}%<<"$'\n'"${PROMPT#*$'\n'}"
  # Separate command blocks without adding space below Fastfetch on startup.
  [[ ${_CUSTOM_PROMPT_DRAWN:-0} == 1 ]] && PROMPT=$'\n'"$PROMPT"
  typeset -g _CUSTOM_PROMPT_DRAWN=1
  RPROMPT=''
  (( width >= 95 )) && RPROMPT='%F{245}%D{%H:%M}%f'
  return 0
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



export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Run once at the first prompt, after Kitty/Zsh have established the pane size.
_fastfetch_startup() {
  add-zsh-hook -d precmd _fastfetch_startup
  [[ -t 1 && $TERM == xterm-kitty && -z $SSH_CONNECTION ]] || return 0
  [[ ${KITTY_WINDOW_ID:-1} == 1 ]] || return 0
  [[ ${FASTFETCH_SHOWN_WINDOW:-} != "${KITTY_PID:-kitty}:${KITTY_WINDOW_ID:-1}" ]] || return 0
  [[ ${_FASTFETCH_SHELL_SHOWN:-0} == 0 ]] || return 0
  (( COLUMNS >= 110 && LINES >= 30 )) || return 0
  (( $+commands[fastfetch] )) || return 0
  typeset -g _FASTFETCH_SHELL_SHOWN=1
  export FASTFETCH_SHOWN_WINDOW="${KITTY_PID:-kitty}:${KITTY_WINDOW_ID:-1}"
  command fastfetch
}
# A local marker avoids repeating Fastfetch when sourcing this file.
(( ${_FASTFETCH_SHELL_SHOWN:-0} )) || add-zsh-hook precmd _fastfetch_startup
