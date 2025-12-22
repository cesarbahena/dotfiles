# ============================================================
# History settings
# ============================================================
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=2000
setopt HIST_IGNORE_DUPS      # don’t record duplicates
setopt HIST_IGNORE_SPACE     # don’t record lines starting with space
setopt APPEND_HISTORY        # append instead of overwrite
setopt SHARE_HISTORY         # share history across sessions

export EDITOR="nvim"

# ============================================================
# Aliases
# ============================================================
alias ls='eza -alnoT --no-permissions --no-filesize --smart-group --time-style=relative --git --icons --group-directories-first -L=1'
alias gs='git status'
alias vi=nvim
alias vim=nvim
alias grep='grep --color=auto'

alias get='sudo apt update && sudo apt install -y'
alias activate='source .venv/bin/activate'

alias docker-compose='docker compose'
alias up='docker compose up -d'
alias down='docker compose down'
alias downdb='docker compose down -v'
alias restart='docker compose down && docker compose up -d'
alias restartdb='docker compose down -v && docker compose up -d'
alias build='docker compose build --no-cache'
alias logs='docker compose logs -f'
alias in='docker compose exec'
alias imin='docker compose exec -it'

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" \
"$(history | tail -n1 | sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Load extra aliases if file exists
[ -f ~/.bash_aliases ] && source ~/.bash_aliases

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

# Command existence highlighting (requires zsh-syntax-highlighting)
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
    ZSH_HIGHLIGHT_STYLES[command]='fg=green'
    ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
    ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[builtin]='fg=yellow'
    ZSH_HIGHLIGHT_STYLES[function]='fg=blue'
fi

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

# Autosuggestions
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    bindkey '^y' autosuggest-accept  # Right arrow to accept
fi

# Additional useful features
setopt CORRECT              # command correction
setopt GLOB_COMPLETE        # complete globs
setopt NO_BEEP              # disable beep
setopt EXTENDED_GLOB        # extended globbing

# Better word selection
autoload -U select-word-style
select-word-style bash

# ============================================================
# Environment paths
# ============================================================
export COMPOSE_BAKE=true
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.npm-global/bin:$PATH
export PATH=$HOME/.fzf/bin:$PATH
export PATH=/usr/local/go/bin:$PATH
export PATH=$HOME/.config/composer/vendor/bin:$PATH

# .NET SDK
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools

# SQL Server tools
export PATH=$PATH:/opt/mssql-tools/bin

# Cargo
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# opencode
export PATH=/home/cesar/.opencode/bin:$PATH

# Microsoft CLI
export PATH="$PATH:/mnt/c/Tools/msgraph/"
# ============================================================
# Prompt handled by Starship
# ============================================================
eval "$(starship init zsh)"

precmd() {
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
# tmux auto attach
# ============================================================
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
  tmux attach -t default || tmux new -s default
fi

# ============================================================
# zoxide + fzf
# ============================================================
eval "$(zoxide init zsh)"

export _ZO_FZF_ENABLE_PREVIEW=1
export _ZO_FZF_OPTS="--layout=reverse --info=inline"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# FZF custom keybindings (after fzf is loaded)
bindkey '^p' fzf-history-widget

# ============================================================
# secrets
# ===========================================================
source ~/dotfiles/.env.local

# ============================================================
# conda
# ===========================================================
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/cesar/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/cesar/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/home/cesar/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/home/cesar/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba shell init' !!
export MAMBA_EXE='/home/cesar/miniforge3/bin/mamba';
export MAMBA_ROOT_PREFIX='/home/cesar/miniforge3';
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias mamba="$MAMBA_EXE"  # Fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<
