# PATH deduplicated construction (bash/zsh compatible)
paths=(
  "$XDG_DATA_HOME/opencode/bin"
  "~/.opencode/bin"
  "$XDG_DATA_HOME/android/cmdline-tools/latest/bin"
  "$XDG_DATA_HOME/android/platform-tools"
  "$XDG_DATA_HOME/dotnet/tools"
  "$XDG_DATA_HOME/dotnet"
  "$XDG_CONFIG_HOME/composer/vendor/bin"
  "$XDG_DATA_HOME/pnpm"
  "/usr/local/go/bin"
  "$CARGO_HOME/bin"
  "$HOME/.local/bin"
  "$XDG_DATA_HOME/bob/nvim-bin"
)

for p in "${paths[@]}"; do
  [ -d "$p" ] || continue
  case ":$PATH:" in
    *":$p:"*) ;;
    *) PATH="$p:$PATH" ;;
  esac
done

unset paths p
export PATH
