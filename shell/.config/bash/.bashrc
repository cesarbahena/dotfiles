export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

export EDITOR="nvim"
export VISUAL="nvim"

export HISTFILE="$XDG_STATE_HOME/bash/history"
mkdir -p "$(dirname "$HISTFILE")"
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

__prompt_command() {
  local exit=$?
  local prompt='$'
  local colors=$(tput colors 2>/dev/null || echo 0)

  # Progressive color enhancement based on terminal capability
  if [ "$colors" -ge 256 ]; then
    # 256-color: dimmest cwd, most vibrant prompts
    local GRAY='\[\e[38;5;240m\]' # very dim gray
    local GREEN='\[\e[38;5;46m\]'  # bright green
    local YELLOW='\[\e[38;5;226m\]' # bright yellow
    local RED='\[\e[38;5;196m\]'    # bright red
    local BLUE='\[\e[38;5;39m\]'    # bright blue
  elif [ "$colors" -ge 16 ]; then
    # 16-color: dim cwd, bright prompts
    local GRAY='\[\e[90m\]'   # dim gray
    local GREEN='\[\e[92m\]'  # bright green
    local YELLOW='\[\e[93m\]' # bright yellow
    local RED='\[\e[91m\]'    # bright red
    local BLUE='\[\e[94m\]'   # bright blue
  else
    # 8-color fallback: white cwd, normal prompts
    local GRAY='\[\e[37m\]'   # white
    local GREEN='\[\e[32m\]'  # green
    local YELLOW='\[\e[33m\]' # yellow
    local RED='\[\e[31m\]'    # red
    local BLUE='\[\e[34m\]'   # blue
  fi
  local RESET='\[\e[0m\]'

  [ "$EUID" -eq 0 ] && prompt='#'

  if [ "$exit" -ne 0 ]; then
    local color="$RED"

    case "$exit" in
      2|64|65|66|67|68|69|75|78|125|127)
        color="$YELLOW"
        ;;
      129|130|131|141|142|148)
        color="$BLUE"
        ;;
    esac

    case "$exit" in
      1)   prompt='!'  ;; # general failure
      2)   prompt='€'  ;; # misuse of shell builtins
      64)  prompt='¿'  ;; # Usage
      65)  prompt='%'  ;; # Format
      66)  prompt='«'  ;; # No input
      67)  prompt='µ'  ;; # No user
      68)  prompt='@'  ;; # No host
      69)  prompt='ø'  ;; # Unavailable
      70)  prompt='£'  ;; # Internal software error
      71)  prompt='œ'  ;; # OS error
      72)  prompt='ƒ'  ;; # File error
      73)  prompt='+'  ;; # Cannot create
      74)  prompt='|'  ;; # IO error
      75)  prompt='…'  ;; # Temporary failure (retry)
      76)  prompt='¶'  ;; # Protocol error
      77)  prompt='©'  ;; # Permission denied
      78)  prompt='ç'  ;; # Configuration error
      125) prompt='Ð'  ;; # Permission denied
      126) prompt='×'  ;; # Command not executable
      127) prompt='?'  ;; # Command not found
      129) prompt='¥'  ;; # SIGHUP (terminal/session closed)
      130) prompt='¢'  ;; # SIGINT (^C)
      131) prompt='\\' ;; # SIGQUIT (^\)
      132) prompt='¡'  ;; # SIGILL (illegal instruction)
      133) prompt='§'  ;; # SIGTRAP (trace/breakpoint)
      134) prompt='‡'  ;; # SIGABRT (abort)
      135) prompt='ß'  ;; # SIGBUS (bus error)
      136) prompt='÷'  ;; # SIGFPE (arithmetic error)
      137) prompt='ð'  ;; # SIGKILL (-9)
      139) prompt='‰'  ;; # SIGSEGV (segmentation fault)
      141) prompt='¦'  ;; # SIGPIPE (broken pipe)
      142) prompt='ö'  ;; # SIGALRM (timeout)
      143) prompt='†'  ;; # SIGTERM (graceful termination)
      147) prompt='¬'  ;; # SIGSTOP (suspended not from terminal)
      148) prompt='&'  ;; # SIGSTP (^Z)
      *)   prompt="($exit)" ;;
    esac

    PS1="${GRAY}\w${RESET} ${color}${prompt}${RESET} "
  else
    PS1="${GRAY}\w${RESET} ${GREEN}${prompt}${RESET} "
  fi
}

PROMPT_COMMAND=__prompt_command

path() {
  [ $# -eq 0 ] && echo "$PATH" | tr : '\n' && return

  local combined="$PATH"
  for dir in "$@"; do
    combined="$combined:$dir"
  done

  export PATH=$(echo "$combined" | tr : '\n' | awk '!seen[$0]++' | tr '\n' : | sed 's/:$//')
}

alias l='ls -nohaX --group-directories-first --color'
alias ls='ls -a --color'
alias rm='rm -r'
alias e=$EDITOR
alias c='claude -c'
alias oc='opencode -c'
alias du='dust 2>/dev/null' # silence permission errors
alias get='sudo apt update && sudo apt install -y'
alias venv='source .venv/bin/activate'

imin() {
  cat ~/.config/bash/.bashrc | ssh "$@" 'bash --rcfile /dev/stdin'
}

dl() {
  {
    docker ps -a --format "{{.State}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" | awk -F'\t' '
      BEGIN {
        symbols["running"] = "•"
        symbols["exited"] = "¤"
        symbols["paused"] = "…"
        symbols["restarting"] = "«"
        print "XXXSTATE\tNAME\tIMAGE\tSTATUS"
      }
      {
        state = $1
        symbol = symbols[state]
        name = $2
        image = $3
        status = $4
        printf "%s\t%s\t%s\t%s\n", symbol, name, image, status
      }'
  } | column -t -s $'\t' | sed 's/XXXSTATE/STATE/' | awk '
    BEGIN {
      running_sym = "•"
    }
    NR == 1 { print; next }
    {
      if (substr($1, 1, 1) == running_sym) {
        print
      } else {
        printf "\033[2m%s\033[0m\n", $0
      }
    }'
}

din() {
  local force_global=false
  local use_follow=true
  local from_file=""
  local args=()
  local is_exec=false

  for arg in "$@"; do
    if [ "$arg" = "-g" ] || [ "$arg" = "--global" ]; then
      force_global=true
    elif [ "$arg" = "-d" ] || [ "$arg" = "--detached" ]; then
      use_follow=false
    elif [ "$arg" = "-f" ] || [ "$arg" = "--file" ]; then
      from_file="next"
    elif [ "$from_file" = "next" ]; then
      from_file="$arg"
      args+=("$arg")
    else
      args+=("$arg")
    fi
  done

  if [ ${#args[@]} -ge 2 ]; then
    is_exec=true
  fi

  if [ "$is_exec" = true ]; then
    if [ "$force_global" = false ]; then
      local has_compose_file=false
      [ -n "$from_file" ] && [ "$from_file" != "next" ] && has_compose_file=true

      if [ -f docker-compose.yml ] || [ -f compose.yml ] || [ "$has_compose_file" = true ]; then
        docker compose exec "${args[@]}"
        return
      fi
    fi
    docker exec "${args[@]}"
  else
    local log_flags=()
    [ "$use_follow" = true ] && log_flags+=("-f")

    if [ "$force_global" = false ]; then
      local has_compose_file=false
      [ -n "$from_file" ] && [ "$from_file" != "next" ] && has_compose_file=true

      if [ -f docker-compose.yml ] || [ -f compose.yml ] || [ "$has_compose_file" = true ]; then
        [ -n "$from_file" ] && [ "$from_file" != "next" ] && log_flags+=("-f" "$from_file")
        docker compose logs "${log_flags[@]}" "${args[@]}"
        return
      fi
    fi
    docker logs "${log_flags[@]}" "${args[@]}"
  fi
}

dbg() {
  if [ $# -eq 0 ]; then
    echo "Error: No arguments provided. Usage: dbg [din-args...] pattern"
    return 1
  fi

  local pattern="${!#}"
  local din_args=("${@:1:$#-1}")

  if command -v rg >/dev/null 2>&1; then
    din -d "${din_args[@]}" | rg "$pattern"
  else
    din -d "${din_args[@]}" | grep --color=always -E -n "$pattern"
  fi
}

up() {
  if [ $# -eq 0 ]; then
    docker compose up -d
    return
  fi

  local force_global=false
  local from_arg=""
  local non_flags=()
  local other_args=()
  local i=1

  while [ $i -le $# ]; do
    arg="${!i}"

    case "$arg" in
      -g|--global)
        force_global=true
        ;;
      -f|--from)
        ((i++))
        from_arg="${!i}"
        ;;
      -e|-v|-p|--env|--volume|--publish|--name|-w|--workdir|-u|--user|--network|--label|--entrypoint|--restart|-m|--memory|--cpus|-h|--hostname)
        other_args+=("$arg")
        ((i++))
        [ $i -le $# ] && other_args+=("${!i}")
        ;;
      --*=*|-*=*)
        other_args+=("$arg")
        ;;
      -*)
        other_args+=("$arg")
        ;;
      *)
        non_flags+=("$arg")
        other_args+=("$arg")
        ;;
    esac
    ((i++))
  done

  if [ -n "$from_arg" ]; then
    if [[ "$from_arg" == *.yml ]] || [[ "$from_arg" == *.yaml ]]; then
      docker compose -f "$from_arg" up -d "${other_args[@]}"
      return
    fi

    local dockerfile_path=""
    local build_context=""

    if [ -d "$from_arg" ]; then
      if [ -f "$from_arg/Dockerfile" ]; then
        build_context="$from_arg"
      fi
    elif [ -f "$from_arg" ]; then
      dockerfile_path="$from_arg"
      build_context="$(dirname "$from_arg")"
    fi

    if [ -n "$build_context" ]; then
      local tag_name
      if git rev-parse --show-toplevel >/dev/null 2>&1; then
        tag_name="$(basename "$(git rev-parse --show-toplevel)"):latest"
      else
        tag_name="$(basename "$PWD"):latest"
      fi

      if [ -n "$dockerfile_path" ]; then
        docker build -t "$tag_name" -f "$dockerfile_path" "$build_context" || return 1
      else
        docker build -t "$tag_name" "$build_context" || return 1
      fi

      docker run -d "${other_args[@]}" "$tag_name"
      return
    fi

    if [ ${#non_flags[@]} -eq 0 ]; then
      docker run -d "${other_args[@]}" "$from_arg"
    elif [ ${#non_flags[@]} -eq 1 ]; then
      docker run -d --name "${non_flags[0]}" "${other_args[@]}" "$from_arg"
    else
      echo "Error: docker run only supports single container."
      echo "Found: ${non_flags[*]}"
      return 1
    fi
    return
  fi

  if [ "$force_global" = false ] && { [ -f docker-compose.yml ] || [ -f compose.yml ]; }; then
    docker compose up -d "${other_args[@]}"
    return
  fi

  if [ ${#non_flags[@]} -eq 0 ]; then
    echo "Error: No container/image specified for docker mode."
    return 1
  fi

  local first_target="${non_flags[0]}"

  if docker ps -a --format '{{.Names}}' | grep -q "^${first_target}$"; then
    docker start "${other_args[@]}"
  else
    if [ ${#non_flags[@]} -gt 1 ]; then
      echo "Error: docker run only supports single container."
      echo "Found: ${non_flags[*]}"
      return 1
    fi
    docker run -d "${other_args[@]}"
  fi
}

down() {
  if [ $# -eq 0 ]; then
    if [ -f docker-compose.yml ] || [ -f compose.yml ]; then
      docker compose down
    else
      echo "Error: No compose file and no containers specified."
      return 1
    fi
    return
  fi

  local force_global=false
  local remove_volumes=false
  local containers=()
  local compose_args=()
  local has_compose_file=false

  for arg in "$@"; do
    if [ "$arg" = "-g" ] || [ "$arg" = "--global" ]; then
      force_global=true
    elif [ "$arg" = "-v" ] || [ "$arg" = "--volumes" ]; then
      remove_volumes=true
      compose_args+=("$arg")
    elif [ "$arg" = "-f" ] || [ "$arg" = "--file" ]; then
      has_compose_file=true
      compose_args+=("$arg")
    elif [[ "$arg" == -* ]]; then
      compose_args+=("$arg")
    else
      containers+=("$arg")
      compose_args+=("$arg")
    fi
  done

  if [ "$force_global" = false ] && { [ -f docker-compose.yml ] || [ -f compose.yml ] || [ "$has_compose_file" = true ]; }; then
    docker compose down "${compose_args[@]}"
  else
    if [ ${#containers[@]} -eq 0 ]; then
      echo "Error: No containers specified."
      return 1
    fi

    docker stop "${containers[@]}" || return 1

    if [ "$remove_volumes" = true ]; then
      docker rm -v "${containers[@]}"
    fi
  fi
}

rs() {
  if [ $# -eq 0 ]; then
    if [ -f docker-compose.yml ] || [ -f compose.yml ]; then
      docker compose down && docker compose up -d
    else
      echo "Error: No compose file and no containers specified."
      return 1
    fi
    return
  fi

  local force_global=false
  local has_compose_file=false
  local temp_args=()

  # First pass: extract mode flags
  for arg in "$@"; do
    if [ "$arg" = "-g" ] || [ "$arg" = "--global" ]; then
      force_global=true
    else
      temp_args+=("$arg")
      [ "$arg" = "-f" ] || [ "$arg" = "--file" ] && has_compose_file=true
    fi
  done

  if [ "$force_global" = false ] && { [ -f docker-compose.yml ] || [ -f compose.yml ] || [ "$has_compose_file" = true ]; }; then
    local down_flags=()
    local up_flags=()
    local services=()
    local i=0

    while [ $i -lt ${#temp_args[@]} ]; do
      arg="${temp_args[$i]}"

      case "$arg" in
        -v|--volumes|--remove-orphans)
          down_flags+=("$arg")
          ;;
        -t|--timeout|--rmi)
          down_flags+=("$arg")
          ((i++))
          [ $i -lt ${#temp_args[@]} ] && down_flags+=("${temp_args[$i]}")
          ;;
        -f|--file)
          down_flags+=("$arg")
          up_flags+=("$arg")
          ((i++))
          if [ $i -lt ${#temp_args[@]} ]; then
            down_flags+=("${temp_args[$i]}")
            up_flags+=("${temp_args[$i]}")
          fi
          ;;
        --timeout=*|--rmi=*)
          down_flags+=("$arg")
          ;;
        --file=*|-f=*)
          down_flags+=("$arg")
          up_flags+=("$arg")
          ;;
        -e|-p|--env|--publish|--scale|--build-arg)
          up_flags+=("$arg")
          ((i++))
          [ $i -lt ${#temp_args[@]} ] && up_flags+=("${temp_args[$i]}")
          ;;
        --*=*)
          up_flags+=("$arg")
          ;;
        --build|--force-recreate|--no-deps|--no-build|--pull|--quiet-pull|--wait)
          up_flags+=("$arg")
          ;;
        -*)
          up_flags+=("$arg")
          ;;
        *)
          services+=("$arg")
          ;;
      esac
      ((i++))
    done

    docker compose down "${down_flags[@]}" "${services[@]}" && \
      docker compose up -d "${up_flags[@]}" "${services[@]}"
  else
    local has_volume_flag=false
    local containers=()

    for arg in "${temp_args[@]}"; do
      if [ "$arg" = "-v" ] || [ "$arg" = "--volumes" ]; then
        has_volume_flag=true
      elif [[ "$arg" != -* ]]; then
        containers+=("$arg")
      fi
    done

    if [ "$has_volume_flag" = true ]; then
      echo "Warning: -v flag not supported for restart in docker mode (ignoring). Container must be recreated to reset volumes."
      echo "Use: down -v ${containers[*]} then recreate with 'up -f <image>'"
    fi

    docker restart "${containers[@]}"
  fi
}

gf() {
  upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
  if [ -z "$upstream" ]; then
    echo "No upstream set for current branch."
    return 1
  fi

  git fetch >/dev/null

  outgoing=$(git log --oneline "$upstream"..HEAD)
  incoming=$(git log --oneline HEAD.."$upstream")

  if [ -z "$incoming" ] && [ -z "$outgoing" ]; then
    echo "✅ Everything is in sync with $upstream"
    return 0
  fi

  echo "<<<<<<< HEAD"
  [ -n "$outgoing" ] && echo "$outgoing"
  echo "======="
  [ -n "$incoming" ] && echo "$incoming"
  echo ">>>>>>> $upstream"
}

gfi() {
  any_changes=0

  for branch in $(git for-each-ref --format='%(refname:short)' refs/heads/); do
    upstream=$(git rev-parse --abbrev-ref --symbolic-full-name "$branch@{u}" 2>/dev/null)
    [ -z "$upstream" ] && continue

    outgoing=$(git log --oneline "$upstream"..$branch)
    incoming=$(git log --oneline $branch.."$upstream")

    if [ -n "$outgoing" ] || [ -n "$incoming" ]; then
      any_changes=1
      echo
      echo "<<<<<<< $branch"
      [ -n "$outgoing" ] && echo "$outgoing"
      echo "======="
      [ -n "$incoming" ] && echo "$incoming"
      echo ">>>>>>> $upstream"
    fi
  done

  if [ $any_changes -eq 0 ]; then
    echo "All branches are in sync with their upstreams."
  fi
}

gfa() {
  echo "Fetching all remotes, tags, pruning stale branches..."
  git fetch --all --tags --prune --jobs=10 >/dev/null
  gfi
}


gfd() {
  upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
  if [ -z "$upstream" ]; then
    echo "No upstream set for current branch."
    return 1
  fi

  git fetch >/dev/null

  echo "Diff from remote → local"
  git diff --color HEAD.."$upstream"

  echo "Diff from local → remote"
  git diff --color "$upstream"..HEAD
}

gm() {
  if [ -f .git/MERGE_HEAD ] && [ $# -eq 0 ]; then
    echo "Continuing merge..."
    git merge --continue
    return
  fi

  if [ $# -eq 0 ]; then # merge with upstream
    upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    if [ -z "$upstream" ]; then
      echo "No upstream set for current branch."
      return 1
    fi
    git merge "$upstream"
  else # merge with specified branch
    git merge "$@"
  fi
}

gff() {
  if [ $# -eq 0 ]; then # ff to upstream
    upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    if [ -z "$upstream" ]; then
      echo "No upstream set for current branch."
      return 1
    fi
    git merge --ff-only "$upstream"
  else # ff to specified branch
    git merge --ff-only "$@"
  fi
}

gsq() {
  mode="normal" # normal/stash/all
  commit_msg=""
  branch=""
  merge_flags=()

  # Parse arguments
  while [ $# -gt 0 ]; do
    case "$1" in
      --stash)
        mode="stash"
        shift
        ;;
      --all)
        mode="all"
        shift
        ;;
      -m)
        shift
        commit_msg="$1"
        shift
        ;;
      -*)
        # Pass any other flags to merge
        merge_flags+=("$1")
        shift
        ;;
      *)
        # First non-flag argument is branch
        [ -z "$branch" ] && branch="$1"
        shift
        ;;
    esac
  done

  if [ -z "$branch" ]; then # use remote
    branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    if [ -z "$branch" ]; then
      echo "No branch specified and no upstream set."
      return 1
    fi
  fi

  staged=false
  if ! git diff --cached --quiet; then
    staged=true
  fi

  if [ "$mode" = "normal" ] && [ "$staged" = true ]; then
    echo "You have staged changes."
    echo "Use --stash to stash WIP or --all to combine staged changes with squash merge."
    return 1
  fi

  stash_applied=false
  if [ "$mode" = "stash" ] && [ "$staged" = true ]; then
    echo "⚠️ Stashing staged changes to avoid mixing with squash..."
    git stash push -m "WIP: staged changes before squash merge" || return 1
    stash_applied=true
  fi

  git merge --squash "$branch" "${merge_flags[@]}" || {
    echo "❌ Squash merge failed."
    [ "$stash_applied" = true ] && git stash pop --quiet
    return 1
  }

  if [ -n "$commit_msg" ]; then
    git commit -m "$commit_msg" || {
      echo "❌ Commit failed"
      [ "$stash_applied" = true ] && git stash pop --quiet
      return 1
    }
  fi

  if [ "$stash_applied" = true ]; then
    echo "Restoring stashed WIP changes..."
    git stash pop --quiet
  fi
}

grb() {
  if [ -d .git/rebase-apply ] || [ -d .git/rebase-merge ]; then
    if [ $# -eq 0 ]; then
      echo "Continuing rebase..."
      git rebase --continue
      return
    fi
  fi

  if [ $# -eq 0 ]; then
    upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    if [ -z "$upstream" ]; then
      echo "No upstream set for current branch."
      return 1
    fi
    git rebase "$upstream"
  else
    git rebase "$@"
  fi
}

gfo() {
  if [ -f .git/MERGE_HEAD ]; then
    echo "Aborting merge..."
    git merge --abort
    return
  fi

  if [ -d .git/rebase-apply ] || [ -d .git/rebase-merge ]; then
    echo "Aborting rebase..."
    git rebase --abort
    return
  fi

  if [ -f .git/CHERRY_PICK_HEAD ]; then
    echo "Aborting cherry-pick..."
    git cherry-pick --abort
    return
  fi

  echo "Nothing to abort: no merge, rebase, or cherry-pick in progress."
}

gcp() {
  if [ -f .git/CHERRY_PICK_HEAD ] && [ $# -eq 0 ]; then
    echo "Continuing cherry-pick..."
    git cherry-pick --continue
    return
  fi

  if [ $# -eq 0 ]; then
    echo "No commits specified to cherry-pick."
    return 1
  fi

  git cherry-pick "$@"
}

gw() {
  [ $# -eq 0 ] && git worktree list && return
  git worktree add "$@"
}

gst() {
  [ $# -eq 0 ] && git stash list && return
  git stash push "$@"
}

gcats() {
  local s=stash@{0}
  git stash list | sed -n '1p'
  git stash show \
    --patch --stat \
    --no-prefix --minimal \
    --diff-algorithm=histogram \
    --ignore-space-change
  echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
  git stash list | sed '1d'
}

gb() {
  [ $# -eq 0 ] && git branch -av && return
  git switch "$@"
}

gbare() {
  git clone --bare "$1" .git
}

gg() {
  git_dir=$(git rev-parse --git-dir 2>/dev/null) || return 1
  bisect_file="$git_dir/BISECT_LOG"

  if [ -f "$bisect_file" ]; then # reset
    git bisect reset
    echo "Bisect session reset."
    return
  fi

  # else start
  bad_commit="HEAD"
  good_commit="$1"

  if [ -z "$good_commit" ]; then
    good_commit=$(git rev-parse HEAD)  # default to current commit
  fi

  git bisect start
  git bisect bad "$bad_commit"
  git bisect good "$good_commit"
  echo "Bisect started: bad=$bad_commit, good=$good_commit"
}

gy() {
  git bisect good
  echo "Marked current commit as GOOD. Next commit:"
  git log -1 --oneline
}

gn() {
  git bisect bad
  echo "Marked current commit as BAD. Next commit:"
  git log -1 --oneline
}

gmvu() {
  if [ $# -eq 0 ]; then # show
    git remote -v
    return
  fi

  ssh_host="${REMOTE_REPO_HOST:-}"
  github_user=$(git config user.name)
  remote_name="origin"
  repo_name=""
  
  while [ $# -gt 0 ]; do
    case "$1" in
      -h|--host)
        shift
        ssh_host="$1"
        ;;
      -u|--user)
        shift
        github_user="$1"
        ;;
      -r|--remote)
        shift
        remote_name="$1"
        ;;
      *) # First non-flag is repo name or DSN
        [ -z "$repo_name" ] && repo_name="$1"
        ;;
    esac
    shift
  done

  if [ -z "$repo_name" ]; then
    echo "Repository not specified. Pass it as the first argument."
    return 1
  fi

  if [[ "$repo_name" == *:* ]]; then # is DSN
    ssh_url="$repo_name"
  else
    if [ -z "$ssh_host" ]; then
      echo "REMOTE_REPO_HOST not set. Use -h flag or set REMOTE_REPO_HOST."
      return 1
    fi

    if [ -z "$github_user" ] || [[ "$github_user" =~ [[:space:]] ]]; then
      echo "Your git user.name ('$github_user') is not DSN string compatible. Use -u to pass a username that is or pass the full DSN string."
      return 1
    fi

    ssh_url="${ssh_host}:${github_user}/${repo_name}"
  fi

  existing_remote=$(git remote | grep -E "^${remote_name}$")

  if [ -n "$existing_remote" ]; then # update
    git remote set-url "$remote_name" "$ssh_url"
    echo "Updated remote '$remote_name' to $ssh_url"
  else
    detected_remote=$(git remote | head -n1)
    if [ -n "$detected_remote" ]; then
      git remote set-url "$detected_remote" "$ssh_url"
      echo "Updated remote '$detected_remote' to $ssh_url"
    else # add origin
      git remote add "$remote_name" "$ssh_url"
      echo "Added remote '$remote_name' pointing to $ssh_url"
    fi
  fi
}

alias gls='git log --stat \
--pretty="~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%n\
%C(magenta)%h%Creset\
%C(auto)%d%Creset \
%C(blue)%as%Creset \
%C(242)%an%Creset \
%n%C(bold)%s%Creset\
%n%b"'

alias gld='git log --abbrev-commit --compact-summary \
--patch --minimal --diff-algorithm=histogram \
--no-prefix --color-moved=dimmed-zebra \
--pretty="~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%n\
%C(magenta)%h%Creset\
%C(auto)%d%Creset \
%C(blue)%as%Creset \
%C(242)%an%Creset \
%n%C(bold)%s%Creset\
%n%b"'

alias g='git status -sb'
alias gs='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias gbm='git branch -avv --no-merged'
alias gl='git log --graph --pretty="%C(magenta)%h%Creset %C(242)%p%Creset %C(blue)%as%Creset%C(auto)%d%Creset %s %Creset%C(242)%an%Creset"'
alias gla='git log --graph --pretty="%C(magenta)%h%Creset %C(242)%p%Creset %C(blue)%as%Creset%C(auto)%d%Creset %s %Creset%C(242)%an%Creset" -a'
alias gcat='git show --pretty=short --show-signature'
alias ga='git add -v'
alias gaa='git add -v --all'
alias gah='git add -p' # add hunk
alias gat='git add -uv' # add tracked
alias gc='git commit -v'
alias gca='git commit -av'
alias gcf='git config --list'
alias gfck='git reflog' # find commit killed
alias gfk='git commit -v --amend --no-edit' # quick amend
alias gfuck='git commit -v --amend' # need to be precise with the msg
alias gp='git push -v'
alias gcpr='git reset --soft' # copy index --reset head
alias grm='git rm'
alias grmf='git rm --cached' # file unstage
alias grmr='git reset' # rm index --reset head
alias grmri='git reset --keep' # rm index --reset head --intelligent keep wt
alias grmrf='git reset --hard' # rm index --reset head --force rm wt
alias grmu='git remote remove origin'
alias grmw='git worktree remove'
alias gmvw='git worktree move'
alias gr='git restore'
alias grc='git restore --source'
alias grs='git restore --staged'
alias gsi='git update-index --no-assume-unchanged' # source .gitignore
alias gpop='git stash pop'
alias ge='git mergetool --no-prompt'
alias gv='git mergetool --no-prompt --tool=nvimdiff'

alias dk='docker stop $(docker ps -q)'
alias dr='docker compose down && docker compose up -d'
alias drd='docker container restart'
alias rsd='docker compose down -v && docker compose up -d'
alias di='docker inspect'
alias dii='docker image inspect'
alias dinet='docker network inspect'
alias div='docker volume inspect'
alias dtop='docker top'
alias dli='docker image ls'
alias dlv='docker volume ls'
alias dln='docker network ls'
alias drm='docker rm'
alias drmr='docker rmi'
alias drmrf='docker image prune -a'
alias drmn='docker network rm'
alias drmv='docker volume prune'
alias drun='docker run'
alias dbl='docker compose build --no-cache'
alias dbl='docker build'
alias dpull='docker pull'
alias dpush='docker image push'
alias dt='docker image tag'
alias dn='docker network create'
alias dnc='docker network connect'
alias dnd='docker network disconnect'
alias dp='docker container port'
