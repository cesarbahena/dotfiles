export EDITOR="nvim"
export _ZO_FZF_ENABLE_PREVIEW=1
export _ZO_FZF_OPTS="--layout=reverse --info=inline"
export SDKMAN_DIR="$HOME/.sdkman"

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
append_path DOTNET_ROOT "$HOME/.dotnet"
append_path "$DOTNET_ROOT/tools"
append_path PNPM_HOME "$HOME/.local/share/pnpm"
append_path ANDROID_SDK_ROOT "$HOME/Android/Sdk" platform-tools
append_path "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"
append_path "$HOME/.config/composer/vendor/bin"
append_path "$HOME/.fzf/bin"
append_path "$HOME/.opencode/bin"
append_path "/mnt/c/Tools/msgraph"
