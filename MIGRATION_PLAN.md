# Minimal Dotfiles Migration Plan

## Overview
Complete rewrite of dotfiles to minimal, SSH-portable configuration. Lightning fast over SSH, defaults-first, keep old setup as reference only.

**This plan will be copied to:** `/home/cesar/dotfiles/MIGRATION_PLAN.md` for version control and iteration.

## Git Strategy

### Recommended Approach: Tag + Branch

```bash
# 1. Tag current sophisticated setup as backup
git tag -a v1.0-sophisticated -m "Backup: Full nvim framework with lazy.nvim, zsh, 211-line tmux"

# 2. Create fresh branch for minimal rewrite
git checkout -b minimal-dotfiles

# 3. Work on minimal-dotfiles branch
# Can nuke files, start fresh, commit iteratively

# 4. Push both
git push origin v1.0-sophisticated
git push origin minimal-dotfiles

# Rollback if needed: git checkout v1.0-sophisticated -b restore-sophisticated
```

**Why this approach:**
- Tag preserves exact snapshot (immutable)
- Branch allows iterative work
- Can cherry-pick old configs as reference
- Easy rollback
- Main stays untouched until ready to merge

## Fresh Start Structure

### GNU Stow Packages (XDG Compliant)

```
dotfiles/
├── shell/
│   ├── .config/bash/
│   │   └── .bashrc          # SSH-pipeable, self-contained
│   └── .bashenv             # Sourced before .bashrc (XDG setup)
│
├── editor/
│   ├── .config/nvim/
│   │   ├── init.lua         # Minimal lua config, native package manager
│   │   └── after/           # Plugin configs (optional)
│   └── .config/vim/
│       └── vimrc            # Fallback, no plugins
│
├── terminal/
│   └── .config/tmux/
│       └── tmux.conf        # ~20 lines, defaults + base-1 indexing
│
└── scripts/
    └── .local/bin/
        ├── py               # Keep complex scripts
        ├── git-backdate
        └── tmux-notifications
```

## Component Designs

### 1. Bash Config (~100 lines total)

**Philosophy:** Self-contained, pipeable over SSH, no external dependencies

**Structure:**
```bash
# .bashrc (single file, no sourcing)

# XDG Base (set early)
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Minimal prompt (pure bash, no starship)
# - Show: user@host:cwd git_branch (exit_status)
# - Colors: green=clean, red=error, yellow=modified
# - Git: parse .git/HEAD directly (no git commands)

# Essential aliases (~15)
# - Navigation: l, ..., ~c, ~d
# - Git: g, m, push, pull
# - Docker: up, down, logs, in
# - Editor: v=vim/nvim detection

# Essential functions (~10)
# - prepend_path, append_path (keep from current)
# - load_env (keep from current)
# - Docker wrappers (convert from aliases)
# - activate (venv)

# Tool XDG compliance
# - Cargo, npm, etc. (keep from current)

# PATH setup
# - /usr/local/bin, ~/.local/bin, cargo, etc.
```

**SSH Portability Test:**
```bash
cat ~/.config/bash/.bashrc | ssh remote 'bash --rcfile /dev/stdin'
```

### 2. Minimal Nvim (~200 lines Lua)

**Modern Neovim Structure (Native Package Manager):**
```
editor/.config/nvim/
├── init.lua                    # Entry point, sets options, loads plugins
├── lua/
│   ├── config/
│   │   ├── options.lua         # All vim.opt settings
│   │   ├── keymaps.lua         # Global keymaps (only additions, no remaps)
│   │   └── autocmds.lua        # Autocommands
│   └── plugins/
│       ├── init.lua            # Plugin loader (autoload from pack/)
│       ├── treesitter.lua      # Treesitter config
│       ├── lspconfig.lua       # LSP setup
│       └── mini.lua            # Mini.nvim modules
├── lsp/
│   ├── lua_ls.lua              # Returns { cmd, filetypes, settings }
│   └── bashls.lua              # Returns { cmd, filetypes, settings }
└── after/
    └── ftplugin/
        └── python.lua          # Python-specific settings (runs after defaults)
```

**Plugin Installation (Native pack/):**
```bash
# Plugins installed to: ~/.local/share/nvim/site/pack/plugins/start/
# Directory structure:
# ~/.local/share/nvim/site/pack/
# └── plugins/
#     ├── start/          # Auto-loaded on startup
#     │   ├── nvim-treesitter/
#     │   ├── nvim-lspconfig/
#     │   └── mini.nvim/
#     └── opt/            # Manually loaded with :packadd
#         └── (none for minimal setup)

# Installation via git clone:
mkdir -p ~/.local/share/nvim/site/pack/plugins/start
cd ~/.local/share/nvim/site/pack/plugins/start
git clone --depth=1 https://github.com/nvim-treesitter/nvim-treesitter
git clone --depth=1 https://github.com/neovim/nvim-lspconfig
git clone --depth=1 https://github.com/echasnovski/mini.nvim
```

**Essential Plugins (3-5 max):**
1. `nvim-treesitter` - Syntax highlighting, text objects
2. `nvim-lspconfig` - LSP client configs
3. `mini.nvim` - Modular collection (statusline, pairs, comment, surround)
4. Optional: `telescope.nvim` or `fzf-lua` for fuzzy finding
5. Optional: `gitsigns.nvim` for git integration

**init.lua Structure:**
```lua
-- Load core config
require('config.options')
require('config.keymaps')
require('config.autocmds')

-- Plugins auto-load from pack/plugins/start/
-- Configure them after they load
require('plugins.treesitter')
require('plugins.lspconfig')
require('plugins.mini')

-- LSP configs auto-loaded from lsp/ folder
```

**LSP Configuration Pattern:**
```lua
-- lsp/lua_ls.lua (returns table)
return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
    },
  },
}

-- lua/plugins/lspconfig.lua (loads lsp/*.lua files)
local lspconfig = require('lspconfig')
local servers = { 'lua_ls', 'bashls' }

for _, server in ipairs(servers) do
  local config = require('lsp.' .. server)
  lspconfig[server].setup(config)
end
```

**after/ Usage:**
- `after/ftplugin/python.lua` - Python-specific settings (runs after vim defaults)
- Loaded automatically when opening Python files
- Use for language-specific keymaps, options, etc.

**Philosophy:**
- Defaults first (keep hjkl, dd, yy, p, etc.)
- Only ADD keymaps (like <leader>ff for telescope, <leader>gc for git)
- NO custom frameworks (no try/fn APIs)
- NO lazy loading (all plugins in start/, load on startup)
- Simple, readable, <50ms startup target

### 3. Minimal Vimrc (~30 lines)

**Pure Vim, no plugins:**
```vim
" XDG compliance
set viminfo+=n~/.local/state/vim/viminfo
set undodir=~/.local/state/vim/undo

" Essentials
set number relativenumber
syntax on
set ignorecase smartcase
set tabstop=2 shiftwidth=2 expandtab
set clipboard=unnamedplus

" Minimal keymaps (only additions, no remaps)
" Keep defaults intact
```

### 4. Minimal Tmux (~20 lines)

**Non-negotiables only:**
```conf
# Base index
set -g base-index 1
setw -g pane-base-index 1

# Terminal
set -g default-terminal "tmux-256color"

# Mouse
set -g mouse on

# Essential bindings (keep defaults, maybe add splits)
# Keep Ctrl+b prefix (default)

# NO plugins, NO complex status bar, NO custom navigation
```

### 5. Prompt Implementation

**Pure Bash Git Prompt (fast):**
```bash
# Parse git branch without calling git command
# Read .git/HEAD directly: ref: refs/heads/main
# Check for modified files: ls -la .git/refs/heads vs .git/index mtime
# Colors: ANSI codes only, no tput

__git_prompt() {
  local gitdir=".git"
  [ -f "$gitdir/HEAD" ] || return
  local branch=$(cat "$gitdir/HEAD")
  branch=${branch##*/}
  echo " ($branch)"
}

PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[33m\]$(__git_prompt)\[\e[0m\]\$ '
```

**Speed target:** <1ms prompt rendering

### 6. Script Migration

**Convert to functions (in .bashrc):**
- docker-compose wrapper
- tmux-kill
- sync-nvim-backup (if still needed)

**Keep as scripts:**
- py (411 lines - too complex)
- git-backdate (684 lines - external command)
- tmux-notifications (149 lines - optional, MS Graph API)

## Migration Steps

### Phase 1: Backup & Branch
1. Copy this plan to repo: `cp ~/.local/share/claude/plans/frolicking-wondering-thimble.md ~/dotfiles/MIGRATION_PLAN.md`
2. Tag current state: `v1.0-sophisticated`
3. Create branch: `minimal-dotfiles`
4. Commit plan: `git add MIGRATION_PLAN.md && git commit -m "docs: add minimal migration plan"`
5. Push both to remote

### Phase 2: Nuke & Rebuild
1. Delete entire contents of: shell/, editor/, terminal/
2. Keep: scripts/ (reference), linux/, agents/
3. Build fresh:
   - shell/.config/bash/.bashrc (from scratch, reference old zsh)
   - editor/.config/nvim/init.lua (from scratch, native pkg manager)
   - editor/.config/vim/vimrc (from scratch)
   - terminal/.config/tmux/tmux.conf (from scratch)

### Phase 3: Test SSH Portability
1. Test bash piping: `cat ~/.config/bash/.bashrc | ssh remote 'bash --rcfile /dev/stdin'`
2. Test vim fallback when nvim not available
3. Test tmux minimal functionality

### Phase 4: Iterate
1. Commit small, atomic changes
2. Test each addition
3. Keep it minimal - resist feature creep

### Phase 5: Merge Decision
- Keep minimal-dotfiles as main branch, OR
- Keep both branches (sophisticated for local, minimal for servers)

## Reference Files from Old Setup

**To reference (not copy):**
- `/home/cesar/dotfiles/shell/.config/zsh/.zshrc` - Alias ideas
- `/home/cesar/dotfiles/shell/.config/zsh/helpers.zsh` - Function patterns
- `/home/cesar/dotfiles/editor/.config/nvim/lua/core/options.lua` - Vim option ideas
- `/home/cesar/dotfiles/terminal/.config/tmux/tmux.conf` - Keybinding ideas

**Philosophy:**
- Don't copy-paste old configs
- Start from defaults
- Add ONLY what you truly need
- Question every addition

## Success Criteria

1. ✓ Bash config pipes over SSH without errors
2. ✓ Nvim starts in <50ms
3. ✓ Vim (no plugins) works as fallback
4. ✓ Tmux functional with defaults + base-1
5. ✓ Prompt renders in <1ms
6. ✓ XDG compliance maintained
7. ✓ No home directory pollution
8. ✓ Total config: <500 lines across all files
