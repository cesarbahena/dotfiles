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

load_env "$XDG_DATA_HOME/nvm/nvm.sh" && alias npmg="l $XDG_DATA_HOME/nvm/versions/node/$(node -v)/bin"
load_env "$HOME/.cargo/env"
load_env "$XDG_DATA_HOME/sdkman/bin/sdkman-init.sh"
load_env "$HOME/dotfiles/.env.local"
load_env "$XDG_CONFIG_HOME/fzf/fzf.zsh"

load_env "zoxide init zsh" "echo zoxide not found"
export MAMBA_ROOT_PREFIX="$XDG_DATA_HOME/miniforge3"
load_env \
  "'$MAMBA_ROOT_PREFIX/bin/mamba' shell hook --shell zsh --root-prefix '$MAMBA_ROOT_PREFIX'" \
  "alias mamba='$MAMBA_ROOT_PREFIX/bin/mamba'"
load_env \
  "'$MAMBA_ROOT_PREFIX/bin/conda' shell.zsh hook" \
  "$MAMBA_ROOT_PREFIX/etc/profile.d/conda.sh"
