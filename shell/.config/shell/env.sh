# XDG Base Directory Specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Editor
export EDITOR="nvim"
export VISUAL="nvim"

# Tool XDG compliance
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export NVM_DIR="$XDG_DATA_HOME/nvm"
export npm_config_cache="$XDG_CACHE_HOME/npm"
export BUN_INSTALL="$XDG_DATA_HOME/bun"
export CONDARC="$XDG_CONFIG_HOME/conda/condarc"
export CONDA_ROOT="$XDG_DATA_HOME/conda"
export MAMBA_ROOT_PREFIX="$XDG_DATA_HOME/miniforge3"
export MONGOSH_CONFIG_DIR="$XDG_DATA_HOME/mongodb"
export CLAUDE_CONFIG_DIR="$XDG_DATA_HOME/claude"
export OPENCODE_CONFIG_DIR="$XDG_CONFIG_HOME/opencode"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export CONDA_ENVS_PATH="$XDG_DATA_HOME/conda/envs"
export SDKMAN_DIR="$XDG_DATA_HOME/sdkman"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
