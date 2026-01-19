# CLAUDE.md

Guidance for Claude Code working with this minimal dotfiles repository.

## Repository

Minimal dotfiles using GNU Stow with XDG compliance. Six packages: shell, editor, terminal, scripts, linux, agents.

## Philosophy

Minimal and bleeding-edge. Use native features before plugins. Follow official documentation strictly. XDG-compliant. No backwards compatibility. No custom frameworks.

## Packages

Shell: 1293-line bashrc with XDG setup, git workflow functions (gf, gm, gsq, grb), docker management (up, down, din, dbg), Unicode prompt with exit code symbols. Self-contained and SSH-portable.

Editor: 152-line minimal nvim using vim.pack native package manager. Single plugin gruvbox. LSP via vim.lsp.enable not lspconfig wrapper. Smart motion keymaps. Follow :help lua-guide and :help initialization.

Terminal: Minimal tmux 50 lines with TPM plugins (resurrect, continuum, fingers). Alacritty 3 lines maximized no decorations. Base index 1, mouse support.

Scripts: Seven executables in bin. py for venv/conda detection, git-backdate for commit manipulation, tmux-notifications for MS Graph API, fix-helium-pwa, docker-compose wrapper, sync-nvim-backup, tmux-kill. Keep complex logic in scripts not bashrc.

Linux: XDG user directories configuration.

Agents: OpenCode agent definitions for git-committer and api-tester.

## Anti-Patterns

Do not use nvim-lspconfig. Do not use lazy.nvim directory patterns. Do not use after/ftplugin when autocmds suffice. Do not create custom frameworks or loaders.

## Critical Rules

Use vim.lsp.start and vim.lsp.config for LSP. Use vim.pack for plugins. Read :help before implementing anything. Verify with :lua = commands. Check Neovim 0.12 native features before adding plugins. Maintain XDG compliance.

## Documentation Priority

First :help topic. Second test with :lua = commands. Third plugin docs for essential plugins only. Fourth web docs as last resort.

## Testing

LSP clients: :lua =vim.lsp.get_clients()
Hover docs: :lua vim.lsp.buf.hover()
Diagnostics: :lua =vim.diagnostic.get(0)

## Git Commits

No watermarks. Conventional commits with scope. Examples: feat(nvim), fix(lsp), refactor(shell), docs.

## Stow

stow shell to symlink bash configs. stow editor for nvim. stow terminal for tmux and alacritty. stow scripts for bin executables. stow linux for user dirs. stow agents for opencode.
