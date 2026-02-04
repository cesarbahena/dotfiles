if [ -n "$ZSH_VERSION" ]; then
  _shell=zsh
elif [ -n "$BASH_VERSION" ]; then
  _shell=bash
else
  _shell=bash
fi

# Zoxide with z .. overload
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init $_shell)"
  z() {
    [ $# -eq 0 ] && __zoxide_z .. || __zoxide_z "$@" && \
    echo -e "\033[35m$(pwd)\033[0m" && \
    ls -nohaX --color --group-directories-first
  }
fi

# fnm (Fast Node Manager)
command -v fnm >/dev/null 2>&1 && eval "$(fnm env --shell=$_shell)"

# SSH with portable config
s() {
  local v64 a64
  v64=$(base64 -w0 "$XDG_CONFIG_HOME/nvim/init.vim")
  a64=$(base64 -w0 "$XDG_CONFIG_HOME/shell/aliases.sh")
  ssh -t "$1" "base64 -d <<<$a64 > /tmp/a.sh; base64 -d <<<$v64 > /tmp/v.vim; bash --rcfile <(cat /tmp/a.sh; echo 'vi() { if command -v nvim &>/dev/null; then nvim --clean -u /tmp/v.vim \"\$@\"; else vim -u /tmp/v.vim \"\$@\"; fi; }')"
}

unset _shell
