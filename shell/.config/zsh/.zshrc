. "$ZDOTDIR/helpers.zsh"

if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
  tmux attach -t default 2>/dev/null || tmux new -s tmux
fi

load_env "$XDG_DATA_HOME/bob/env/env.sh"
load_env "zoxide init zsh" "echo zoxide not found"

ZINIT_HOME="$XDG_DATA_HOME/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
. "${ZINIT_HOME}/zinit.zsh"

export ZSH="$XDG_DATA_HOME/oh-my-zsh-dummy"
[ ! -d "$ZSH/.git" ] && mkdir -p "$ZSH" && \
  git -C "$ZSH" init && git -C "$ZSH" commit --allow-empty -m \
  "Dummy OMZ repo for OMZP plugin compatibility" >/dev/null 2>&1

zi id-as lucid light-mode for \
  zdharma-continuum/zinit-annex-binary-symlink \
  zsh-users/zsh-syntax-highlighting \
  zsh-users/zsh-autosuggestions \
  zsh-users/zsh-completions\
  Aloxaf/fzf-tab \
  OMZP::git \
  OMZP::git-commit \
  OMZP::pip \
  OMZP::docker \
  OMZP::aws \
  OMZP::kubectl \
  OMZP::kubectx \
  OMZP::helm \
  OMZP::sudo \
  OMZP::command-not-found \
  from'gh-r' lbin'!' \
  atclone'./starship init zsh > init.zsh; ./starship completions zsh > _starship' \
  atpull'%atclone' src'init.zsh' lbin'!' starship/starship
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/.zcompdump"
autoload -Uz compinit && compinit -d "$ZSH_COMPDUMP"
zi cdreplay -q

zi from'gh-r' lbin'!' id-as lucid light-mode wait for \
  lbin'!rg' BurntSushi/ripgrep \
  @sharkdp/fd \
  @sharkdp/bat \
  eza-community/eza \
  lbin'!jq* -> jq' jqlang/jq \
  lbin'!yq* -> yq' mikefarah/yq \
  lbin'!**/uv' @astral-sh/uv \
  lbin'!pnpm* -> pnpm' pnpm/pnpm \
  bootandy/dust \
  dalance/procs \
  dandavison/delta \
  pemistahl/grex \
  lbin'!**/gh' id-as'gh' cli/cli \
  lbin'!kubectx' lbin'!kubens' bpick'kubectx;kubens' ahmetb/kubectx \
  atclone'fzf --zsh > fzf.zsh' atpull'%atclone' src'fzf.zsh' junegunn/fzf \
  atclone'fnm completions --shell zsh > _fnm' atpull'%atclone' atload'eval $(fnm env --shell zsh)' Schniz/fnm 

zi make id-as lucid light-mode wait for dylanaraps/neofetch

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
ZSH_HIGHLIGHT_STYLES[command]='fg=green'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[function]='fg=blue'

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
bindkey '^y' autosuggest-accept

HISTFILE="$XDG_STATE_HOME/zsh/history"
[ ! -f "$HISTFILE" ] && mkdir -p "$(dirname "$HISTFILE")"
HISTSIZE=1000
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt append_history
setopt share_history
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

setopt glob_complete
setopt no_beep
setopt extended_glob

# Enhanced completion settings
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

function up-line-or-tmux-copy() {
    if zle up-line; then
        # Successfully moved up a line
        return 0
    else
        # Couldn't move up (at top), try tmux copy mode
        if [[ -n "$TMUX" ]]; then
            tmux copy-mode \; send -X cursor-up
        fi
    fi
}
zle -N up-line-or-tmux-copy
function tmux-copy-halfpage-up() {
    if [[ -n "$TMUX" ]]; then
        tmux copy-mode \; send -X halfpage-up
    fi
}
zle -N tmux-copy-halfpage-up
function zle-keymap-select {
    if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
        echo -ne '\e[2 q'  # Block cursor for normal mode
    elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
        echo -ne '\e[6 q'  # Beam cursor for insert mode
    fi
}
zle -N zle-keymap-select
function zle-line-init() {
    echo -ne '\e[6 q'  # Beam cursor
}
zle -N zle-line-init

bindkey -v  # Enable vi mode
bindkey '^u' vi-cmd-mode # Activate it
bindkey -M vicmd 'n' down-line-or-history
bindkey -M vicmd 'e' up-line-or-tmux-copy
bindkey -M vicmd 'k' backward-char
bindkey -M vicmd 'o' forward-char
bindkey -M vicmd 'K' beginning-of-line
bindkey -M vicmd 'O' end-of-line
bindkey -M vicmd 'l' vi-open-line-below
bindkey -M vicmd 'L' vi-open-line-above
bindkey -M vicmd ',' vi-forward-word
bindkey -M vicmd 'z' vi-backward-word
bindkey -M vicmd 'm' tmux-copy-halfpage-up      # m = tmux copy mode + half page up
bindkey '^k' delete-char
bindkey '^p' fzf-history-widget

autoload -U select-word-style
select-word-style bash

precmd() {
    # Save the last command for the 'a' function
    _LAST_CMD=$(fc -ln -1 -1 | sed 's/^\s*//')
    
    local input="$(starship prompt --right 2>/dev/null)"
    local output=""
    local in_escape=0
    local i
    
    for (( i=0; i<${#input}; i++ )); do
        local char="${input:$i:1}"
        
        # Check if we're entering an ANSI escape sequence
        if [[ "$char" == $'\033' ]]; then
            in_escape=1
            output+="$char"
        # Check if we're ending an ANSI escape sequence
        elif [[ $in_escape -eq 1 && "$char" == "m" ]]; then
            in_escape=0
            output+="$char"
        # If we're inside escape sequence, just copy
        elif [[ $in_escape -eq 1 ]]; then
            output+="$char"
        # If we're outside escape sequence, convert digits
        else
            case "$char" in
                0) output+="₀" ;;
                1) output+="₁" ;;
                2) output+="₂" ;;
                3) output+="₃" ;;
                4) output+="₄" ;;
                5) output+="₅" ;;
                6) output+="₆" ;;
                7) output+="₇" ;;
                8) output+="₈" ;;
                9) output+="₉" ;;
                *) output+="$char" ;;
            esac
        fi
    done
    
    RPROMPT="$output"
}

a() {
  # Use the last command saved by precmd hook
  notify-send "${_LAST_CMD:-Done}"
}

alias l='eza \
  -alnoT \
  --no-permissions \
  --no-filesize \
  --smart-group \
  --time-style=relative \
  --git \
  --icons \
  --group-directories-first \
  -L=1'
alias g='git status -s'
alias m='git add . && git commit -m'
alias v=nvim
alias c="opencode -c"
alias get='sudo apt update \
  && sudo apt install -y'
alias activate='source .venv/bin/activate'
alias up='docker compose up -d'
alias down='docker compose down'
alias downdb='docker compose down -v'
alias restart='docker compose down \
  && docker compose up -d'
alias restartdb='docker compose down -v \
  && docker compose up -d'
alias build='docker compose build --no-cache'
alias logs='docker compose logs -f'
alias in='docker compose exec'
alias imin='docker compose exec -it'
alias du='dust 2>/dev/null'
alias adbw="/mnt/c/platform-tools/adb.exe"
