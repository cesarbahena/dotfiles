[[ -n ${_ZSH_HELPERS_LOADED:-} ]] && return
readonly _ZSH_HELPERS_LOADED=1

load_env() {
  # One argument → source file if it exists
  if [ $# -eq 1 ]; then
    [ -s "$1" ] && . "$1"
    return
  fi

  # Two arguments: try primary command, fallback to secondary
  local generated_code
  if generated_code="$(eval "$1" 2>/dev/null)"; then
    eval "$generated_code"
    return
  fi

  # Fallback: source file or run command
  if [ -s "$2" ]; then
    . "$2"
  fi
  # Run command logic pending
}

prepend_path() {
  if [ $# -ge 2 ]; then # Export runtime variable
    export "$1=$2"
    local dir="${3:+$2/$3}"
    [ -z "$3" ] && local dir="$2"
  else # Just add to path
    local dir="$1"
  fi
  case ":$PATH:" in
    *":$dir:"*) ;;
    *) [ -d "$dir" ] && export PATH="$dir:$PATH" ;;
  esac
}

append_path() {
  if [ $# -ge 2 ]; then # Export runtime variable
    export "$1=$2"
    local dir="${3:+$2/$3}"
    [ -z "$3" ] && local dir="$2"
  else # Just add to path
    local dir="$1"
  fi
  case ":$PATH:" in
    *":$dir:"*) ;;
    *) [ -d "$dir" ] && export PATH="$PATH:$dir" ;;
  esac
}
