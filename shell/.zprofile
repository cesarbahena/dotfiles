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

load_env "$$HOME/.nvm/nvm.sh" && alias npmg="l $HOME/.nvm/versions/node/$(node -v)/bin"
load_env "$HOME/.cargo/env"
load_env "$HOME/.sdkman/bin/sdkman-init.sh"
load_env "$HOME/dotfiles/.env.local"
load_env "$HOME/.fzf.zsh"

load_env "zoxide init zsh" "echo zoxide not found"
export MAMBA_ROOT_PREFIX="$HOME/miniforge3"
load_env \
  "'$HOME/miniforge3/bin/mamba' shell hook --shell zsh --root-prefix '$MAMBA_ROOT_PREFIX'" \
  "alias mamba='$HOME/miniforge3/bin/mamba'"
load_env \
  "'$HOME/miniforge3/bin/conda' shell.zsh hook" \
  "$HOME/miniforge3/etc/profile.d/conda.sh"
