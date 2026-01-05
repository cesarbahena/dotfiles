export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

export EDITOR="nvim"
export _ZO_FZF_ENABLE_PREVIEW=1
export _ZO_FZF_OPTS="--layout=reverse --info=inline"
export SDKMAN_DIR="$XDG_DATA_HOME/sdkman"

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

prepend_path "$HOME/bin" # User scripts/custom binaries
append_path "/usr/local/go/bin"
append_path DOTNET_ROOT "$XDG_DATA_HOME/dotnet"
append_path "$DOTNET_ROOT/tools"
append_path PNPM_HOME "$XDG_DATA_HOME/pnpm"
append_path ANDROID_SDK_ROOT "$XDG_DATA_HOME/android" platform-tools
append_path "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"
append_path "$XDG_CONFIG_HOME/composer/vendor/bin"
append_path "$XDG_DATA_HOME/fzf/bin"
append_path "$HOME/.opencode/bin"
append_path "/mnt/c/Tools/msgraph"
append_path "$HOME/.local/bin"
