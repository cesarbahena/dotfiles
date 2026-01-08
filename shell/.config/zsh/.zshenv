# XDG Base Directory (needed before other vars)
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Rust
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

# Node
export NVM_DIR="$XDG_DATA_HOME/nvm"
export npm_config_cache="$XDG_CACHE_HOME/npm"

# Bun
export BUN_INSTALL="$XDG_DATA_HOME/bun"

# Less
export LESSHISTFILE="$XDG_STATE_HOME/less/history"

# Conda
export CONDARC="$XDG_CONFIG_HOME/conda/condarc"

# MongoDB
export MONGOSH_CONFIG_DIR="$XDG_DATA_HOME/mongodb"

export EDITOR="nvim"
export VISUAL="nvim"
export _ZO_FZF_ENABLE_PREVIEW=1
export _ZO_FZF_OPTS="--layout=reverse --info=inline"
export SDKMAN_DIR="$XDG_DATA_HOME/sdkman"
