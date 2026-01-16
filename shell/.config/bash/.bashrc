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
      2|64|65|66|67|68|69|75|78|127)
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
      77)  prompt='Ð'  ;; # Permission denied
      78)  prompt='ç'  ;; # Configuration error
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
alias e=$EDITOR
alias c='claude -c'
alias oc='opencode -c'
alias du='dust 2>/dev/null' # silence permission errors
alias get='sudo apt update && sudo apt install -y'
alias activate='source .venv/bin/activate'

alias g='git status -sb'
alias gs='git status'
alias ga='git add -v'
alias gaa='git add -v --all'
alias gah='git add -p' # add hunk
alias gat='git add -uv' # add tracked
alias gb='git branch -av'
alias gbnm='git branch -av --no-merged' # whats up with this
alias gsw='git switch'
alias gswc='git switch --create'
alias gc='git commit -v'
alias gca='git commit -av'
alias gcf='git config --list'
alias gfck='git reflog' # find commit killed
alias gfk='git commit -v --amend --no-edit' # quick amend
alias gfuck='git commit -v --amend' # need to be precise with the msg
alias gfu='git commit --fixup'
# Should we even use --date=now and --signoff in amend aliases?
# What about gpg-sign for normal commits?
alias ge='git mergetool --no-prompt'
alias gvim='git mergetool --no-prompt --tool=vimdiff'
alias gp='git push -v'
alias gcpr='git reset --soft' # copy index --reset head
alias grm='git rm'
alias grmf='git rm --cached' # file unstage
alias grmr='git reset' # rm index --reset head
alias grmri='git reset --keep' # rm index --reset head --intelligent keep wt 
alias grmrf='git reset --hard' # rm index --reset head --force rm wt
alias grmu='git remote remove origin'
alias gmvu='git remote rename origin'
alias grmw='git worktree remove'
alias gmvw='git worktree move'
alias gr='git restore'
alias grs='git restore --source'
alias grt='git restore --staged'
alias gcat='git show --pretty=short --show-signature'
alias gpop='git stash pop'
alias gsi='git update-index --no-assume-unchanged' # source .gitignore

# Make the ultimate git log function out of these:
alias glg='git log --stat'
alias glgg='git log --graph'
alias glgga='git log --graph --decorate --all'
alias glgm='git log --graph --max-count=10'
alias glgp='git log --stat --patch'
alias glo='git log --oneline --decorate'
alias glod='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset"'
alias glods='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset" --date=short'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias glol='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'
alias glola='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all'
alias glols='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --stat'
alias gwch='git log --patch --abbrev-commit --pretty=medium --raw'

 # whats up with tags
alias gta='git tag --annotate'
alias gts='git tag --sign'
alias gpoat='git push origin --all && git push origin --tags'

# Docker
alias up='docker compose up -d'
alias down='docker compose down'
alias downdb='docker compose down -v'
alias rs='docker compose down && docker compose up -d'
alias rsdb='docker compose down -v && docker compose up -d'
alias build='docker compose build --no-cache'
alias logs='docker compose logs -f'
alias imin='docker compose exec -it'
alias dbl='docker build'
alias dcin='docker container inspect'
alias dcls='docker container ls'
alias dclsa='docker container ls -a'
alias dib='docker image build'
alias dii='docker image inspect'
alias dils='docker image ls'
alias dipru='docker image prune -a'
alias dipu='docker image push'
alias dirm='docker image rm'
alias dit='docker image tag'
alias dlo='docker container logs'
alias dnc='docker network create'
alias dncn='docker network connect'
alias dndcn='docker network disconnect'
alias dni='docker network inspect'
alias dnls='docker network ls'
alias dnrm='docker network rm'
alias dpo='docker container port'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dpu='docker pull'
alias dr='docker container run'
alias drit='docker container run -it'
alias drm='docker container rm'
alias drm!='docker container rm -f'
alias drs='docker container restart'
alias dst='docker container start'
alias dsta='docker stop $(docker ps -q)'
alias dstp='docker container stop'
alias dsts='docker stats'
alias dtop='docker top'
alias dvi='docker volume inspect'
alias dvls='docker volume ls'
alias dvprune='docker volume prune'
alias dxc='docker container exec'
alias dxcit='docker container exec -it'

# Python/pip
alias pipi='pip install'
alias pipir='pip install -r requirements.txt'
alias piplo='pip list -o'
alias pipreq='pip freeze > requirements.txt'
alias pipu='pip install --upgrade'
alias pipun='pip uninstall'

# Functions
in() {
  docker compose exec "$@" || docker exec "$@"
}

imin() {
  cat ~/.config/bash/.bashrc | ssh "$@" 'bash --rcfile /dev/stdin'
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

# We need a rebase workflow as good as the merge one
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase --interactive'
alias grbo='git rebase --onto'
alias grbs='git rebase --skip'

# Also an overloaded stash function
alias gsta='git stash push'
alias gstaa='git stash apply'
alias gstall='git stash --all'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gsts='git stash show --patch'
alias gstu='git stash push --include-untracked'

# And a diff one too
alias gd='git diff'
alias gdca='git diff --cached'
alias gdcw='git diff --cached --word-diff'
alias gds='git diff --staged'
alias gdt='git diff-tree --no-commit-id --name-only -r'
alias gdw='git diff --word-diff'
