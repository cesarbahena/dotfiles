# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository using GNU Stow structure for managing configurations. Contains Neovim configuration with sophisticated error handling and backup mechanisms, plus tmux configuration.

### Managed Configurations

- **nvim**: Neovim configuration at `nvim/.config/nvim/`
- **tmux**: Tmux configuration at `tmux/.config/tmux/`

## Key Commands

### Testing

- `make test` - Run all tests with plenary.nvim
- `make test-verbose` - Run tests with verbose output
- `make test-file` - Run a specific test file
- `make dev-test` - Interactive testing (run `:PlenaryBustedDirectory tests/` in nvim)

### Stow Management

- `stow <package>` - Create symlinks for a package (e.g., `stow nvim`, `stow tmux`)
- `stow -D <package>` - Remove symlinks for a package

### Backup and Sync

- `./sync-nvim-backup.sh` - Sync nvim config to backup location (complete replacement)

### Environment Variables

- `NVIM_BACKUP_PATH` - Path to backup configuration (default: `~/.config/nvim_backup`)
- `NVIM_SAFE_MODE` - Set to '1' to load backup config immediately without waiting for errors

## Architecture

### Core Error Handling System

The configuration is built around a sophisticated error handling system using a custom `try` API:

- **Safe Execution**: All module loading uses `try()` wrapper for error resilience
- **Error Collection**: Errors are stored in `_G.Errors` for debugging
- **Backup Fallback**: Automatic fallback to backup configuration when modules fail
- **Retry Mechanism**: Failed modules can be retried before package manager initialization

### Enhanced Function Utilities

The configuration includes advanced utility functions for cleaner, more maintainable code:

#### `fn` API (Lazy Function Wrapper)
- **Conditional Execution**: Execute different functions based on runtime conditions
- **Enhanced Condition Evaluation**: Vim-aware condition checking with scope-based variable/option access
- **Error Handling**: Graceful fallback with configurable notification strategies
- **Module Path Resolution**: Call functions from modules by string path

**Key Features:**
- **Merged Scopes**: `window`/`buffer`/`global` automatically check both variables (`vim.w`/`vim.b`/`vim.g`) and options (`vim.wo`/`vim.bo`/`vim.go`)
- **Iteration Options**: `in_this` (current context) and `in_any` (iterate with early return)
- **Comparison Operators**: `eq`, `ne`, `gt`, `lt`, `gte`, `lte` for precise matching
- **Custom Iteration**: `forEach` support for arrays and functions

See `docs/fn_api.md` for comprehensive documentation and examples.

### Directory Structure

```
nvim/.config/nvim/
├── init.lua              # Entry point with backup/safe mode logic
├── Makefile             # Test commands
├── lazy-lock.json       # Package lockfile
├── stylua.toml         # Lua formatter config
├── lsp/                # Language server configurations
├── lua/
│   ├── core/           # Core system modules
│   │   ├── init.lua    # Main loader with try() usage
│   │   ├── lsp/        # LSP configuration
│   │   ├── package_manager.lua  # lazy.nvim setup
│   │   └── retry.lua   # Module retry logic
│   ├── plugins/        # Plugin configurations (~30+ plugins)
│   ├── utils/          # Utility modules
│   │   └── try.lua     # Core error handling API
│   └── ui/             # UI-related modules
└── tests/              # Test suite for try API
```

### Try API

The `try` function provides multiple execution patterns:

- Simple calls: `try(function, args...)`
- Single operations: `try { function, args..., options }`
- Batch operations: `try { {func1, args...}, {func2, args...}, options }`
- Multi-call: `try { function, {args1...}, {args2...}, options }`

### Package Management

Uses lazy.nvim with:

- Lockfile at `json/lazy-lock.json`
- Plugin specs imported from `plugins/` directory
- Performance optimizations with disabled default plugins
- Automatic plugin checking enabled

### LSP Configuration

Language servers are configured in `lsp/` directory with automatic loading:

- Individual server configs: `lsp/<server_name>.lua`
- Mason auto-installs configured servers
- When adding LSP support: also add formatter to `conform.lua` formatters_by_ft

## Git Commit Preferences

- **No watermarks**: Do not add "Generated with Claude Code" or "Co-Authored-By: Claude" to commit messages
- **Scoped commits**: Use conventional commit format with scope, e.g.:
  - `feat(nvim): add new plugin configuration`
  - `fix(tmux): correct key binding configuration`
  - `refactor(backup): improve sync script reliability`
  - `docs: update installation instructions`

## Development Notes

- All Lua files use the `try()` wrapper for safe module loading
- Test files are located in `tests/` and use plenary.nvim
- Configuration supports both normal and safe mode operation
- Backup configuration path is configurable via environment variable
- The setup automatically handles plugin installation and lazy loading
- Use GNU Stow for managing dotfile symlinks

### CLI Theme Implementation

The configuration features a comprehensive command-line interface theme documented in `docs/cli_theme.md`:

#### Key Components
- **Tabline**: Simulates command execution (`~/project main ±1 nvim -t filename --file1 --file2`)
- **Statuscolumn**: Green starship prompt (`❯`) that turns red when files have errors
- **Incline**: Window status bars with git status colors and line numbers for focused windows
- **Treesitter Context**: Minimal separator with transparent background

#### Visual Language
- **Colors**: Red (errors/conflicts), green (untracked), orange (modified), white (clean)
- **Decorations**: Bold (removed for minimal aesthetic), italic (unsaved), underline (warnings)
- **Mode Awareness**: Tabline shows different CLI programs based on vim mode

#### Git Integration
- File-level status detection using `git status --porcelain`
- Conflict detection for merge states (UU, AA, DD, AU, UA, UD, DU)
- Clean separation: statuscolumn shows code health, incline shows git status

### Plugin Management Notes

#### Conditional Plugins
- `illuminate.lua` is commented out - provides symbol highlighting under cursor
- Use for code navigation but can add visual noise to minimal theme
- Toggle with `<leader>ux` if enabled

#### Error Handling Strategy
- Diagnostic errors shown in statuscolumn (red prompt)
- Git conflicts shown in incline (red filenames)
- Warnings/hints use underline decoration (removed for cleaner appearance)

#### Theme Integration
- `transparent.nvim` handles background transparency
- Custom highlight groups override colorscheme defaults
- ColorScheme autocmds ensure highlights persist after theme changes

## Claude Development Guidelines

**CRITICAL: Always read documentation FIRST before making any API claims or suggestions.**

### Documentation Priority Order
1. **Local plugin documentation** - Check `/home/cesar/.local/share/nvim/lazy/*/doc/` and `/home/cesar/.local/share/nvim/lazy/*/README.md`
2. **Plugin source code** - Read lua files in `/home/cesar/.local/share/nvim/lazy/*/lua/` when docs are unclear
3. **Verification commands** - Use Neovim commands like `:=vim.treesitter.query.get('lang', 'textobjects')` to verify behavior
4. **Web documentation** only as last resort

### Key Lessons
- **Treesitter textobjects**: Unknown directives like `#make-range!` are ignored by `vim.treesitter` and won't work with mini.ai
- **API assumptions**: Never assume API behavior - always verify with local documentation first
- **Error investigation**: Read actual error messages and outputs carefully instead of guessing solutions

### Methodology
1. Read relevant documentation thoroughly
2. Understand the API constraints and requirements  
3. Implement based on documented behavior
4. Test and verify with provided tools
5. Only then provide solutions

**Remember: Confidence without proper research wastes time. Documentation reading saves hours of trial-and-error.**
