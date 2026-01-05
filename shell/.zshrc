if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
  tmux attach -t default 2>/dev/null || tmux new -s default
fi

ZINIT_HOME="$XDG_DATA_HOME/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
. "${ZINIT_HOME}/zinit.zsh"

# Load annexes for lbin/sbin ice modifiers
zi light zdharma-continuum/zinit-annex-bin-gem-node
zi light zdharma-continuum/zinit-annex-binary-symlink

zi light-mode for \
  zsh-users/zsh-syntax-highlighting \
  zsh-users/zsh-autosuggestions \
  zsh-users/zsh-completions

zi light-mode for \
  as"command" \
  from"gh-r" \
  atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
  atpull"%atclone" \
  src"init.zsh" \
  starship/starship

# Portable CLI tools (single binaries from GitHub releases)
zi from'gh-r' id-as null for \
    lbin'!' @sharkdp/bat \
    lbin'!' @sharkdp/fd \
    lbin'!rg' @BurntSushi/ripgrep

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
[ -d $HISTFILE ] && mkdir -p "$(dirname $HISTFILE)"
HISTSIZE=1000
SAVEHIST=$HISTSIZE
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt APPEND_HISTORY
setopt SHARE_HISTORY

# ============================================================
# Completions
# ============================================================
autoload -Uz compinit
compinit

# Enhanced completion settings
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric



# ============================================================
# Vim keymaps
# ============================================================
bindkey -v  # Enable vim mode

# Custom vim keymaps
bindkey '^u' vi-cmd-mode               # Ctrl+E to enter normal mode (escape to normal mode)
bindkey '^k' delete-char

# Colemak movement in vi mode
bindkey -M vicmd 'n' down-line-or-history      # n = down (next line)
# Custom function for 'e' key - up line or tmux copy if at top
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
bindkey -M vicmd 'e' up-line-or-tmux-copy      # e = up line or tmux copy if at top  
bindkey -M vicmd 'k' backward-char              # k = left
bindkey -M vicmd 'o' forward-char               # o = right
bindkey -M vicmd 'K' beginning-of-line          # K = beginning of line
bindkey -M vicmd 'O' end-of-line                # O = end of line
bindkey -M vicmd 'l' vi-open-line-below         # l = open line below
bindkey -M vicmd 'L' vi-open-line-above         # L = open line above
bindkey -M vicmd ',' vi-forward-word            # h = next page/word
bindkey -M vicmd 'z' vi-backward-word           # z = prev page/word

# Custom function for 'm' key - enter tmux copy mode and half page up
function tmux-copy-halfpage-up() {
    if [[ -n "$TMUX" ]]; then
        tmux copy-mode \; send -X halfpage-up
    fi
}
zle -N tmux-copy-halfpage-up
bindkey -M vicmd 'm' tmux-copy-halfpage-up      # m = tmux copy mode + half page up

# Vi mode visual indicators
function zle-keymap-select {
    if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
        echo -ne '\e[2 q'  # Block cursor for normal mode
    elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
        echo -ne '\e[6 q'  # Beam cursor for insert mode
    fi
}
zle -N zle-keymap-select

# Initialize cursor
function zle-line-init() {
    echo -ne '\e[6 q'  # Beam cursor
}
zle -N zle-line-init



# Additional useful features
setopt GLOB_COMPLETE        # complete globs
setopt NO_BEEP              # disable beep
setopt EXTENDED_GLOB        # extended globbing

# Better word selection
autoload -U select-word-style
select-word-style bash

# ============================================================
# Prompt customization
# ============================================================
# Note: Starship is loaded by zinit (lines 15-21)

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

# ============================================================
# FZF custom keybindings
# ============================================================
# Note: fzf and zoxide are initialized in .zprofile (runs before .zshrc in login shells)
# Tmux creates login shells by default, so functions are already loaded
bindkey '^p' fzf-history-widget


a() {
  # Use the last command saved by precmd hook
  notify-send "${_LAST_CMD:-Done}"
}
alias l='eza \
  -alnoT \
  --no-permissions \
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
alias adbw="/mnt/c/platform-tools/adb.exe"
