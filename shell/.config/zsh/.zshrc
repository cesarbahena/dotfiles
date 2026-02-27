export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Source shell agnostic config
. "$XDG_CONFIG_HOME/sh/env.sh"
. "$XDG_CONFIG_HOME/sh/path.sh"
. "$XDG_CONFIG_HOME/sh/aliases.sh"
. "$XDG_CONFIG_HOME/sh/init.sh"

# Docker aliases with completions
autoload -Uz compinit && compinit
alias d='docker'
compdef _docker d=docker

setopt prompt_subst

precmd() {
  local exit=$?
  local sym='%%'
  local color='%F{196}'  # red

  # zshenv corruption check
  local zshenv_lines=("${(@f)$(< ~/.zshenv 2>/dev/null)}")
  if (( ${#zshenv_lines} > 1 )); then
    sym='þ'
    local cwd="${PWD/#$HOME/~}"
    local dir="${cwd%/*}"
    local base="${cwd##*/}"
    [[ "$cwd" = "$base" ]] && dir=""
    [[ -z "$dir" && "$cwd" = /* ]] && base="$cwd"
    local env=""
    if [[ -n "$VIRTUAL_ENV" ]]; then
      env="(${VIRTUAL_ENV##*/}) "
    elif [[ -n "$CONDA_DEFAULT_ENV" ]]; then
      env="($CONDA_DEFAULT_ENV) "
    fi
    if [[ -n "$dir" ]]; then
      PROMPT="%F{240}${env}%f%F{240}${dir}/%f%F{39}${base}%f ${color}${sym}%f "
    else
      PROMPT="%F{240}${env}%f%F{39}${base}%f ${color}${sym}%f "
    fi
    return
  fi

  color='%F{46}'  # green
  (( EUID == 0 )) && sym='#'

  if (( exit != 0 )); then
    color='%F{196}'  # red
    case $exit in
      2|3|16|64|65|66|67|68|69|75|78|125|127|128) color='%F{226}' ;;  # yellow
      129|130|131|141|142|148) color='%F{39}' ;;  # blue
    esac
    case $exit in
      1)   sym='!'  ;; # General failure
      2)   sym='€'  ;; # Misuse of shell builtins
      3)   sym='Æ'  ;; # Page not found
      7)   sym='¤'  ;; # Option error
      16)  sym='M'  ;; # No manual entry found
      35)  sym='Š'  ;; # SSL failure
      64)  sym='¿'  ;; # Usage
      65)  sym='$'  ;; # Format
      66)  sym='«'  ;; # No input
      67)  sym='µ'  ;; # No user
      68)  sym='@'  ;; # No host
      69)  sym='ø'  ;; # Unavailable
      70)  sym='£'  ;; # Internal software error
      71)  sym='œ'  ;; # OS error
      72)  sym='ƒ'  ;; # File error
      73)  sym='+'  ;; # Cannot create
      74)  sym='|'  ;; # IO error
      75)  sym='…'  ;; # Temporary failure (retry)
      76)  sym='¶'  ;; # Protocol error
      77)  sym='–'  ;; # Permission denied
      78)  sym='ç'  ;; # Configuration error
      100) sym='©'  ;; # APT failure
      101) sym='®'  ;; # Rust build error
      125) sym='Ð'  ;; # Permission denied
      126) sym='×'  ;; # Command not executable
      127) sym='?'  ;; # Command not found
      128) sym='§'  ;; # Fatal application error
      129) sym='¥'  ;; # SIGHUP (terminal/session closed)
      130) sym='¢'  ;; # SIGINT (^C)
      131) sym='\\' ;; # SIGQUIT (^\)
      132) sym='¡'  ;; # SIGILL (illegal instruction)
      133) sym='»'  ;; # SIGTRAP (redirected signal)
      134) sym='‡'  ;; # SIGABRT (abort)
      135) sym='ß'  ;; # SIGBUS (bus error)
      136) sym='÷'  ;; # SIGFPE (arithmetic error)
      137) sym='ð'  ;; # SIGKILL (-9)
      139) sym='‰'  ;; # SIGSEGV (segmentation fault)
      141) sym='¦'  ;; # SIGPIPE (broken pipe)
      142) sym='ö'  ;; # SIGALRM (timeout)
      143) sym='†'  ;; # SIGTERM (graceful termination)
      147) sym='ž'  ;; # SIGSTOP (suspended not from terminal)
      148) sym='&'  ;; # SIGSTP (^Z)
      217) sym='™'  ;; # NPM error
      254) sym='}'  ;; # Missing package.json
      255) sym='Ñ'  ;; # Invalid characters
      *)   sym="($exit)" ;;
    esac
  fi

  local cwd="${PWD/#$HOME/~}"
  local dir="${cwd%/*}"
  local base="${cwd##*/}"
  [[ "$cwd" = "$base" ]] && dir=""
  [[ -z "$dir" && "$cwd" = /* ]] && base="$cwd"

  local env=""
  if [[ -n "$VIRTUAL_ENV" ]]; then
    env="(${VIRTUAL_ENV##*/}) "
  elif [[ -n "$CONDA_DEFAULT_ENV" ]]; then
    env="($CONDA_DEFAULT_ENV) "
  fi

  if [[ -n "$dir" ]]; then
    PROMPT="%F{240}${env}%f%F{240}${dir}/%f%F{39}${base}%f ${color}${sym}%f "
  else
    PROMPT="%F{240}${env}%f%F{39}${base}%f ${color}${sym}%f "
  fi
}
