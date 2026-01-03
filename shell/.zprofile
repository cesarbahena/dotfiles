echo ".zprofile lazy loaded"

load_env() {
  if [ $# -eq 1 ]; then # Source the file
    [ -s "$1" ] && . "$1"
    return
  fi
  
  # To execute a hook you must provide a fallback
  local generated_code="$(eval "$1" 2>/dev/null)"
  if [ $? -eq 0 ]; then # Hook generated the code
    eval "$generated_code"
    return
  fi
  
  # Hook failed: execute fallback
  eval "$2"
}

load_env "$NVM_DIR/nvm.sh"
load_env "$HOME/.cargo/env"
load_env "$HOME/.sdkman/bin/sdkman-init.sh"
load_env "$HOME/dotfiles/.env.local"

load_env \
  "'$HOME/miniforge3/bin/conda' shell.zsh hook" \
  "$HOME/miniforge3/etc/profile.d/conda.sh"

export MAMBA_EXE="$HOME/miniforge3/bin/mamba"
export MAMBA_ROOT_PREFIX="$HOME/miniforge3"
load_env \
  "'$MAMBA_EXE' shell hook --shell zsh --root-prefix '$MAMBA_ROOT_PREFIX'" \
  "alias mamba='$MAMBA_EXE'"
