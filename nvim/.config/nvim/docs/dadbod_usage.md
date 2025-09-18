# Database Tools Usage Guide

## Installed Plugins

1. **vim-dadbod** - Core database interface
2. **vim-dadbod-ui** - Visual database browser
3. **vim-dadbod-completion** - SQL autocompletion
4. **sqls.nvim** - SQL language server

## Key Mappings

| Key | Command | Description |
|-----|---------|-------------|
| `<leader>db` | `:DBUIToggle` | Toggle Database UI |
| `<leader>df` | `:DBUIFindBuffer` | Find Database Buffer |
| `<leader>dr` | `:DBUIRenameBuffer` | Rename Database Buffer |
| `<leader>dq` | `:DBUILastQueryInfo` | Last Query Info |

## Setting Up Database Connections

1. Edit `lua/config/dadbod_connections.lua`
2. Uncomment and modify connection examples
3. Restart Neovim or `:source %`

### Connection URL Formats

```lua
-- SQLite
'sqlite:/path/to/database.db'

-- PostgreSQL
'postgresql://user:password@host:port/database'

-- MySQL
'mysql://user:password@host:port/database'

-- MongoDB
'mongodb://user:password@host:port/database'

-- Redis
'redis://host:port'
```

## Usage Workflow

1. **Open Database UI**: `<leader>db`
2. **Add Connection**: Click `Add connection` or use `:DBUIAddConnection`
3. **Browse Schema**: Expand database → schemas → tables
4. **Run Queries**: 
   - Select table → press `<Enter>` to see data
   - Create new query with `o` or click "New query"
   - Execute with `<C-]>` or `:w`

## SQL File Features

### Autocompletion
- Table names, column names, SQL keywords
- Database-aware suggestions based on current connection

### Language Server Features (sqls)
- Syntax highlighting
- Error detection
- Go to definition
- Schema validation

## Database UI Features

### Navigation
- `o` - Create new query
- `<CR>` - Execute/Open
- `S` - Open in horizontal split
- `V` - Open in vertical split
- `d` - Delete query/connection
- `R` - Refresh
- `A` - Add connection

### Query Management
- Queries are auto-saved in `~/.local/share/nvim/dadbod_ui/`
- Organized by connection name
- Supports multiple query tabs

## Tips

1. **Environment Variables**: Use env vars for sensitive data:
   ```lua
   url = 'postgresql://' .. os.getenv('DB_USER') .. ':' .. os.getenv('DB_PASS') .. '@localhost:5432/mydb'
   ```

2. **Project-specific**: Create `.nvimrc` in project root:
   ```lua
   vim.g.dbs = {
     dev = 'postgresql://user:pass@localhost:5432/project_dev',
     test = 'postgresql://user:pass@localhost:5432/project_test'
   }
   ```

3. **Query Templates**: Save common queries as templates in saved queries

4. **Results Navigation**: Use `gf` on table names to jump to table definition

## Security Notes

- Never commit database credentials to version control
- Use environment variables or local config files
- Consider using connection profiles without embedded credentials