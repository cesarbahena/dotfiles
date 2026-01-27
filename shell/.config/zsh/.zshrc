# Source shared shell config
. "$HOME/.config/shell/env.sh"
. "$HOME/.config/shell/path.sh"
. "$HOME/.config/shell/aliases.sh"
. "$HOME/.config/shell/init.sh"

# Docker completions (zsh-specific)
autoload -Uz compinit && compinit
alias d='docker'
alias c='docker compose'
compdef _docker d=docker
compdef '_dispatch docker docker-compose' c

# Zsh prompt
setopt prompt_subst

precmd() {
  local exit=$?
  local sym='%%'
  local color='%F{46}'  # green

  (( EUID == 0 )) && sym='#'

  if (( exit != 0 )); then
    color='%F{196}'  # red
    case $exit in
      2|3|16|64|65|66|67|68|69|75|78|125|127|128) color='%F{226}' ;;  # yellow
      129|130|131|141|142|148) color='%F{39}' ;;  # blue
    esac
    case $exit in
      1)   sym='!'  ;;
      2)   sym='€'  ;;
      3)   sym='Æ'  ;;
      16)  sym='M'  ;;
      64)  sym='¿'  ;;
      65)  sym='$'  ;;
      66)  sym='«'  ;;
      67)  sym='µ'  ;;
      68)  sym='@'  ;;
      69)  sym='ø'  ;;
      70)  sym='£'  ;;
      71)  sym='œ'  ;;
      72)  sym='ƒ'  ;;
      73)  sym='+'  ;;
      74)  sym='|'  ;;
      75)  sym='…'  ;;
      76)  sym='¶'  ;;
      77)  sym='©'  ;;
      78)  sym='ç'  ;;
      101) sym='®'  ;;
      125) sym='Ð'  ;;
      126) sym='×'  ;;
      127) sym='?'  ;;
      128) sym='§'  ;;
      129) sym='¥'  ;;
      130) sym='¢'  ;;
      131) sym='\\'  ;;
      132) sym='¡'  ;;
      133) sym='»'  ;;
      134) sym='‡'  ;;
      135) sym='ß'  ;;
      136) sym='÷'  ;;
      137) sym='ð'  ;;
      139) sym='‰'  ;;
      141) sym='¦'  ;;
      142) sym='ö'  ;;
      143) sym='†'  ;;
      147) sym='¬'  ;;
      148) sym='&'  ;;
      255) sym='&'  ;;
      *)   sym="($exit)" ;;
    esac
  fi

  local cwd="${PWD/#$HOME/~}"
  local dir="${cwd%/*}"
  local base="${cwd##*/}"
  [[ "$cwd" = "$base" ]] && dir=""

  if [[ -n "$dir" ]]; then
    PROMPT="%F{240}${dir}/%f${base} ${color}${sym}%f "
  else
    PROMPT="${base} ${color}${sym}%f "
  fi
}
