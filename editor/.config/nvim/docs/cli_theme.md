# CLI Theme Documentation

This document describes the command-line interface theme implemented throughout the Neovim configuration, creating a cohesive terminal aesthetic.

## Overview

The CLI theme transforms Neovim into a sophisticated command-line environment by styling various UI components to resemble terminal applications and shell commands.

## Components

### 1. Tabline - Command-Line Simulation

The tabline (`lualine.lua`) displays as a realistic command prompt:

```
~/project main ±1 nvim -t filename --file1 --file2
```

**Structure:**
- **Working directory**: `~/project` (cyan)
- **Git branch**: `main` (purple) 
- **Git status**: `±1` (yellow, shows changes)
- **Vim mode command**: `nvim`/`vi`/`vim`/`sh`/`nano`/`zsh` (gray)
- **Harpoon flags**: `-t filename --file1 --file2` (gray, active file uses `-t` flag)

**Mode Mapping:**
- Normal mode: `nvim`
- Insert mode: `vi` 
- Visual modes: `vim`
- Command mode: `sh`
- Select modes: `sed`
- Replace modes: `nano`
- Shell mode: `bash`
- Terminal mode: `zsh`

### 2. Statuscolumn - Starship Prompt

The statuscolumn (`statuscolumn.lua`) shows a starship-style prompt:

- **Current line**: ` ❯` (green starship prompt character)
- **Other lines**: Relative line numbers (default color)
- **Signs**: Diagnostics and git signs integrated

Uses `statuscol.nvim` plugin for proper highlight group support.

### 3. Incline - VSCode-Style Status Bars

Window-level status bars (`incline.lua`) with:

**Colors (priority order):**
- Red: Diagnostic errors (overrides all)
- Green: Untracked files (git status)
- Orange: Modified files (git status)  
- White: Clean files (default)

**Text Decorations:**
- **Bold**: Focused window
- **Underline**: Warnings/info/hints
- **Italic**: Unsaved modifications

**Layout:**
- File icon + filename (left)
- Diagnostics represented by colors and decorations only (no numbers/icons)

### 4. Status Line - Centered Diagnostics

The main status line shows workspace diagnostics centered using proper `%=` alignment syntax.

## Color Palette

- **Green**: `#50a14f` (starship prompt)
- **Cyan**: `#7FB4CA` (directory)
- **Purple**: `#938AA9` (git branch)
- **Yellow**: `#E6C384` (git status)
- **Gray**: `#666666` (commands and flags)
- **Blue**: `#61afef` (harpoon component background)

## Key Features

### Command-Line Authenticity
- Realistic command syntax with proper flag usage
- Context-aware program names based on vim mode
- Git status integration mimicking shell prompts

### Minimalist Design
- No redundant visual indicators
- Clean typography and spacing
- Subtle color usage for maximum readability

### Contextual Information
- Mode-aware command display
- Git status with standard ±additions/deletions format
- Active file highlighting with `-t` (target) flag syntax

## Implementation Files

- `lua/plugins/lualine.lua` - Main tabline and status line
- `lua/plugins/statuscolumn.lua` - Starship prompt in gutter
- `lua/plugins/incline.lua` - Window status bars
- `lua/core/autocmd.lua` - Highlight group management

This theme creates a unique, terminal-focused editing experience that feels like working directly in a sophisticated command-line environment.