-- Database connections configuration
-- This file shows examples of how to set up database connections
-- Copy this to your project or home directory and customize

--[[
SSH TUNNEL SETUP FOR REMOTE DATABASE ACCESS

To connect to meindev1@docker-1.mein.com.mx:9207, you have two options:

OPTION 1: SSH Tunnel (Recommended for security)
1. Set up SSH tunnel in a separate terminal:
   ssh -L 9207:localhost:9207 meindev1@docker-1.mein.com.mx
   
2. Or use background tunnel:
   ssh -f -N -L 9207:localhost:9207 meindev1@docker-1.mein.com.mx
   
3. Then connect to localhost:9207 (see connection below)

OPTION 2: Direct Connection
- Uncomment the direct connection example
- Make sure the remote server allows external connections
- Update with your actual credentials

OPTION 3: SSH Config
Add to ~/.ssh/config:
```
Host mein-docker
    HostName docker-1.mein.com.mx
    User meindev1
    LocalForward 9207 localhost:9207
```
Then: ssh mein-docker
--]]

local M = {}

-- Example database connections
-- Uncomment and modify as needed for your databases

M.connections = {
  -- Direct MySQL connection using environment variables
  {
    name = 'mein_docker_mysql',
    url = string.format('mysql://%s:%s@docker-1.mein.com.mx:9207/%s',
      os.getenv('MEIN_DB_USER') or 'username',
      os.getenv('MEIN_DB_PASS') or 'password', 
      os.getenv('MEIN_DB_NAME') or 'database'
    )
  },
  
  -- Test database for document templates (local development)
  {
    name = 'mein_test_mysql',
    url = 'mysql://mein_test_user:mein_test_pass@127.0.0.1:3306/mein_test'
  },
  
  -- SQLite example
  -- {
  --   name = 'local_sqlite',
  --   url = 'sqlite:' .. vim.fn.expand('~') .. '/database.db'
  -- },
}

-- URL encode function for special characters in passwords
local function url_encode(str)
  if not str then return str end
  return str:gsub("([^%w%-%.%_%~])", function(c)
    return string.format("%%%02X", string.byte(c))
  end)
end

-- Set up connections in vim-dadbod-ui
function M.setup()
  if #M.connections > 0 then
    -- URL encode passwords for proper connection strings
    local encoded_connections = {}
    for _, conn in ipairs(M.connections) do
      local encoded_conn = vim.deepcopy(conn)
      -- Extract and encode password from URL
      encoded_conn.url = encoded_conn.url:gsub("://([^:]+):([^@]+)@", function(user, pass)
        return "://" .. user .. ":" .. url_encode(pass) .. "@"
      end)
      table.insert(encoded_connections, encoded_conn)
    end
    
    -- According to documentation, vim.g.dbs should be an array of objects
    vim.g.dbs = encoded_connections
  end
end

return M