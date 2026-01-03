# Database Tools Usage Guide

## Architecture Overview

A sophisticated database workflow system built around four core plugins with intelligent tab management and seamless completion integration.

### Plugin Stack
1. **vim-dadbod** - Core database interface for executing queries
2. **vim-dadbod-ui** - Visual database browser with tree navigation
3. **vim-dadbod-completion** - Database-aware SQL autocompletion via blink.cmp
4. **sqls.nvim** - Enhanced SQL language server with Telescope integration

## Intelligent Tab Cycling System

### Primary Interface
**`?` key** - Activates `actions.dadbod.cycle_dbui_tab()` for stateless DBUI tab management

### Cycling States & Logic
The system implements a 4-state cycle that preserves workflow context:

1. **Switch to DBUI** - If DBUI tab exists but user is elsewhere → switch to it
2. **Hide DBUI** - If currently in DBUI tab → move to last position and switch away
3. **Restore Hidden** - If DBUI buffers exist but not in visible tabs → restore them in new tab
4. **Create Fresh** - If no DBUI exists anywhere → create new DBUI instance

### Hidden Tab Management
- **Preservation**: Hidden tabs maintain their state and buffer content
- **Recovery**: System can restore DBUI buffers that exist but aren't visible
- **Cleanup**: Automatically handles tab positioning without cluttering tab bar

## Keymap Override Architecture

### Custom Implementation
- **ftplugin Override**: `after/ftplugin/dbui.lua` unmaps DBUI's default `?` help key
- **Event-driven**: Uses `DBUIOpened` autocmd to ensure proper timing after plugin initialization  
- **Buffer-local**: Only affects DBUI buffers, preserves `?` functionality elsewhere
- **Selective**: All other DBUI default mappings remain active and functional

## Completion Integration

### SQL File Autocompletion
- **Database-aware**: Completion suggestions based on active connection schema
- **LSP Override**: Dadbod completion takes precedence over SQL LSP for relevant files
- **Scope**: Automatically configured for `sql`, `mysql`, `plsql` filetypes
- **Integration**: Seamlessly works with blink.cmp completion engine

### Language Server Features (sqls)
- **Telescope Integration**: Enhanced schema browsing and navigation
- **Syntax Validation**: Real-time error detection and highlighting
- **Schema Awareness**: Context-aware suggestions and validations

## Configuration System

### UI Settings
```lua
vim.g.db_ui_use_nerd_fonts = 1              -- Nerd Font icon support
vim.g.db_ui_show_database_icon = 1          -- Database type indicators
vim.g.db_ui_win_position = 'left'           -- Left sidebar positioning
vim.g.db_ui_winwidth = 40                   -- Fixed width for consistency
vim.g.db_ui_auto_execute_table_helpers = 1  -- Automatic table actions
vim.g.db_ui_use_nvim_notify = 1             -- Modern notification system
```

### Storage & Persistence
- **Query Storage**: `~/.local/share/nvim/dadbod_ui/` (cross-session persistence)
- **Connection Loading**: Auto-discovery from `config/dadbod_connections.lua`
- **Buffer Management**: Intelligent cleanup and restoration of hidden buffers

## Database Connection Setup

### Connection Configuration
1. Edit `lua/config/dadbod_connections.lua`
2. Define connections using standard database URLs
3. Restart Neovim or source configuration

### Supported Database Types
```lua
-- SQLite (local files)
'sqlite:/path/to/database.db'

-- PostgreSQL
'postgresql://user:password@host:port/database'

-- MySQL/MariaDB  
'mysql://user:password@host:port/database'

-- MongoDB
'mongodb://user:password@host:port/database'
```

## Workflow Examples

### Basic Usage
1. **Access**: Press `?` to open/cycle DBUI
2. **Connect**: Add database connections via UI or configuration
3. **Browse**: Navigate schema tree to explore tables and structure
4. **Query**: Create new queries with `o`, execute with `<C-]>` or `:w`

### Advanced Tab Management
- **Hide when done**: Press `?` in DBUI tab to hide without losing state
- **Quick restore**: Press `?` anywhere to restore hidden DBUI with preserved context
- **Multi-project**: Each DBUI instance maintains independent connection state

## Security Best Practices

### Credential Management
- **Environment Variables**: Use `os.getenv()` for sensitive credentials
- **Local Configuration**: Keep credentials in local, non-versioned files
- **Connection Profiles**: Prefer parameterized connections over embedded secrets

### Example Secure Setup
```lua
-- In lua/config/dadbod_connections.lua
local connections = {
  dev = {
    url = 'postgresql://' .. os.getenv('DB_USER') .. ':' .. os.getenv('DB_PASS') .. '@localhost:5432/project_dev',
    name = 'Development DB'
  }
}
```