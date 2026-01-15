export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

export EDITOR="nvim"
export VISUAL="nvim"

export HISTFILE="$XDG_STATE_HOME/bash/history"
mkdir -p "$(dirname "$HISTFILE")"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export NVM_DIR="$XDG_DATA_HOME/nvm"
export npm_config_cache="$XDG_CACHE_HOME/npm"
export BUN_INSTALL="$XDG_DATA_HOME/bun"
export CONDARC="$XDG_CONFIG_HOME/conda/condarc"
export CONDA_ROOT="$XDG_DATA_HOME/conda"
export MAMBA_ROOT_PREFIX="$XDG_DATA_HOME/miniforge3"
export MONGOSH_CONFIG_DIR="$XDG_DATA_HOME/mongodb"
export CLAUDE_CONFIG_DIR="$XDG_DATA_HOME/claude"
export OPENCODE_CONFIG_DIR="$XDG_CONFIG_HOME/opencode"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export CONDA_ENVS_PATH="$XDG_DATA_HOME/conda/envs"
export SDKMAN_DIR="$XDG_DATA_HOME/sdkman"

__prompt_command() {
  local exit=$?
  local prompt='$'
  local colors=$(tput colors 2>/dev/null || echo 0)

  # Progressive color enhancement based on terminal capability
  if [ "$colors" -ge 256 ]; then
    # 256-color: dimmest cwd, most vibrant prompts
    local GRAY='\[\e[38;5;240m\]' # very dim gray
    local GREEN='\[\e[38;5;46m\]'  # bright green
    local YELLOW='\[\e[38;5;226m\]' # bright yellow
    local RED='\[\e[38;5;196m\]'    # bright red
    local BLUE='\[\e[38;5;39m\]'    # bright blue
  elif [ "$colors" -ge 16 ]; then
    # 16-color: dim cwd, bright prompts
    local GRAY='\[\e[90m\]'   # dim gray
    local GREEN='\[\e[92m\]'  # bright green
    local YELLOW='\[\e[93m\]' # bright yellow
    local RED='\[\e[91m\]'    # bright red
    local BLUE='\[\e[94m\]'   # bright blue
  else
    # 8-color fallback: white cwd, normal prompts
    local GRAY='\[\e[37m\]'   # white
    local GREEN='\[\e[32m\]'  # green
    local YELLOW='\[\e[33m\]' # yellow
    local RED='\[\e[31m\]'    # red
    local BLUE='\[\e[34m\]'   # blue
  fi
  local RESET='\[\e[0m\]'

  [ "$EUID" -eq 0 ] && prompt='#'

  if [ "$exit" -ne 0 ]; then
    local color="$RED"

    case "$exit" in
      2|64|65|66|67|68|69|75|78|127)
        color="$YELLOW"
        ;;
      129|130|131|141|142|148)
        color="$BLUE"
        ;;
    esac

    case "$exit" in
      1)   prompt='!'  ;; # general failure
      2)   prompt='€'  ;; # misuse of shell builtins
      64)  prompt='¿'  ;; # Usage
      65)  prompt='%'  ;; # Format
      66)  prompt='«'  ;; # No input
      67)  prompt='µ'  ;; # No user
      68)  prompt='@'  ;; # No host
      69)  prompt='ø'  ;; # Unavailable
      70)  prompt='£'  ;; # Internal software error
      71)  prompt='œ'  ;; # OS error
      72)  prompt='ƒ'  ;; # File error
      73)  prompt='+'  ;; # Cannot create
      74)  prompt='|'  ;; # IO error
      75)  prompt='…'  ;; # Temporary failure (retry)
      76)  prompt='¶'  ;; # Protocol error
      77)  prompt='Ð'  ;; # Permission denied
      78)  prompt='ç'  ;; # Configuration error
      126) prompt='×'  ;; # Command not executable
      127) prompt='?'  ;; # Command not found
      129) prompt='¥'  ;; # SIGHUP (terminal/session closed)
      130) prompt='¢'  ;; # SIGINT (^C)
      131) prompt='\\' ;; # SIGQUIT (^\)
      132) prompt='¡'  ;; # SIGILL (illegal instruction)
      133) prompt='§'  ;; # SIGTRAP (trace/breakpoint)
      134) prompt='‡'  ;; # SIGABRT (abort)
      135) prompt='ß'  ;; # SIGBUS (bus error)
      136) prompt='÷'  ;; # SIGFPE (arithmetic error)
      137) prompt='ð'  ;; # SIGKILL (-9)
      139) prompt='‰'  ;; # SIGSEGV (segmentation fault)
      141) prompt='¦'  ;; # SIGPIPE (broken pipe)
      142) prompt='ö'  ;; # SIGALRM (timeout)
      143) prompt='†'  ;; # SIGTERM (graceful termination)
      147) prompt='¬'  ;; # SIGSTOP (suspended not from terminal)
      148) prompt='&'  ;; # SIGSTP (^Z)
      *)   prompt="($exit)" ;;
    esac

    PS1="${GRAY}\w${RESET} ${color}${prompt}${RESET} "
  else
    PS1="${GRAY}\w${RESET} ${GREEN}${prompt}${RESET} "
  fi
}

PROMPT_COMMAND=__prompt_command

path() {
  [ $# -eq 0 ] && echo "$PATH" | tr : '\n' && return

  local combined="$PATH"
  for dir in "$@"; do
    combined="$combined:$dir"
  done

  export PATH=$(echo "$combined" | tr : '\n' | awk '!seen[$0]++' | tr '\n' : | sed 's/:$//')
}
