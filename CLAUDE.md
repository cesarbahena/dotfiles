# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Dotfiles managed with GNU Stow. Each top-level dir is a stow package, symlinked to `$HOME`.

## Stow Usage

```bash
stow <package>        # symlink package to ~
stow -D <package>     # unlink package
stow -R <package>     # restow (unlink + link)
```

## Packages

- **bash**: bashrc, XDG env vars, aliases (`v`=nvim, `g`=git status, `d`=docker, `c`=docker compose, `z`=zoxide)
- **nvim**: minimal neovim using `vim.pack.add` for plugins (no lazy.nvim)
- **tmux**: prefix `C-Space`, plugins via tpm
- **git**: conventional commit aliases (`git feat`, `git fix`, `git refactor`, etc)
- **alacritty**, **claude**, **docker**, **opencode**, **freedesktop**: config only

## Neovim

- Leader: `<Space>`
- Format lua: `stylua` (2 spaces, single quotes, no call parens)
- Plugins loaded via `vim.pack.add` in init.lua
- Config split: `plugin/*.lua` for features, `lua/*.lua` for utilities
- LSP configs in `lsp/` dir

## Conventions

- Commit style: conventional commits (`feat:`, `fix:`, `refactor:`, etc)
- Use git aliases when committing: `git feat "message"` or `git feat scope "message"`
