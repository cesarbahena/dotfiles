. "$ZDOTDIR/helpers.zsh"

load_env "$XDG_DATA_HOME/nvm/nvm.sh" && alias npmg="l $XDG_DATA_HOME/nvm/versions/node/$(node -v)/bin"
prepend_path "$CARGO_HOME/bin"
load_env "$XDG_DATA_HOME/sdkman/bin/sdkman-init.sh"
load_env "$HOME/dotfiles/.env.local"
load_env "$XDG_CONFIG_HOME/fzf/fzf.zsh"
load_env "$XDG_DATA_HOME/bob/env/env.sh"
load_env \
  "'$MAMBA_ROOT_PREFIX/bin/mamba' shell hook --shell zsh --root-prefix '$MAMBA_ROOT_PREFIX'" \
  "alias mamba='$MAMBA_ROOT_PREFIX/bin/mamba'"
load_env \
  "'$MAMBA_ROOT_PREFIX/bin/conda' shell.zsh hook" \
  "$MAMBA_ROOT_PREFIX/etc/profile.d/conda.sh"

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
