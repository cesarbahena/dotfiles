
# XDG Base Directory vars (ensure set)
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_BIN_HOME="$HOME/.local/bin"

export EDITOR="nvim"
export VISUAL="nvim"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export NVM_DIR="$XDG_DATA_HOME/nvm"
export npm_config_cache="$XDG_CACHE_HOME/npm"
export BUN_INSTALL="$XDG_DATA_HOME/bun"
export CONDARC="$XDG_CONFIG_HOME/conda/condarc"
export CONDA_ROOT="$XDG_DATA_HOME/conda"
export MAMBA_ROOT_PREFIX="$XDG_DATA_HOME/miniforge3"
export MAMBA_EXE="$MAMBA_ROOT_PREFIX/bin/mamba"
export MONGOSH_CONFIG_DIR="$XDG_DATA_HOME/mongodb"
export CLAUDE_CONFIG_DIR="$XDG_DATA_HOME/claude"
export OPENCODE_CONFIG_DIR="$XDG_CONFIG_HOME/opencode"
export OPENCODE_INSTALL_DIR="$XDG_DATA_HOME/opencode/bin"

# gnupg: Move to XDG data
export GNUPGHOME="$XDG_DATA_HOME/gnupg"

# conda: Additional envs path
export CONDA_ENVS_PATH="$XDG_DATA_HOME/conda/envs"

export _ZO_FZF_ENABLE_PREVIEW=1
export _ZO_FZF_OPTS="--layout=reverse --info=inline"
export SDKMAN_DIR="$XDG_DATA_HOME/sdkman"
