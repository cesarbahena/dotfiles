export _ZO_FZF_ENABLE_PREVIEW=1
export _ZO_FZF_OPTS="--layout=reverse --info=inline"
export SDKMAN_DIR="$HOME/.sdkman"
export EDITOR="nvim"
export COMPOSE_BAKE=true
export NVM_DIR="$HOME/.nvm"
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PNPM_HOME="$HOME/.local/share/pnpm"

prepend_path() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) [ -d "$1" ] && export PATH="$1:$PATH" ;;
  esac
}

append_path() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) [ -d "$1" ] && export PATH="$PATH:$1" ;;
  esac
}

# Priority 1: User overrides
prepend_path "$HOME/bin" # User scripts/custom binaries

# Priority 2: System PATH
# System PATH already exists: /usr/local/bin, /usr/bin, /bin, etc.

# Priority 3: Version managers (managed by scripts in .zprofile)
# NVM adds: $NVM_DIR/versions/node/$(version)/bin (managed by nvm.sh)
# Conda adds: $CONDA_PREFIX/bin (managed by conda init)
# Cargo adds: $HOME/.cargo/bin (managed by cargo env)


# Priority 4: Platform SDKs & specialized tools
# .NET SDK
if [ -d "$HOME/.dotnet" ]; then
  export DOTNET_ROOT="$HOME/.dotnet"
  append_path "$DOTNET_ROOT"
  append_path "$DOTNET_ROOT/tools"
fi

# Android SDK
if [ -d "$HOME/Android/Sdk" ]; then
  export ANDROID_HOME="$HOME/Android/Sdk"
  append_path "$ANDROID_HOME/platform-tools"
  append_path "$ANDROID_HOME/cmdline-tools/latest/bin"
fi

# Priority 5: Tools
append_path "/usr/local/go/bin"
append_path "$PNPM_HOME"
append_path "$HOME/.config/composer/vendor/bin"
append_path "$HOME/.fzf/bin"
append_path "$HOME/.opencode/bin"
append_path "/mnt/c/Tools/msgraph"
