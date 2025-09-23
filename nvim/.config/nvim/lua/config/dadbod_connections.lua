local M = {}

-- Example database connections
-- Uncomment and modify as needed for your databases

M.connections = {
  -- Direct MySQL connection using environment variables
  {
    name = 'mein_docker_mysql',
    url = string.format(
      'mysql://%s:%s@docker-1.mein.com.mx:9207/%s',
      os.getenv 'MEIN_DB_USER' or 'username',
      os.getenv 'MEIN_DB_PASS' or 'password',
      os.getenv 'MEIN_DB_NAME' or 'database'
    ),
  },

  -- Test database for document templates (local development)
  {
    name = 'mein_test_mysql',
    url = 'mysql://mein_test_user:mein_test_pass@127.0.0.1:3306/mein_test',
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
  return str:gsub('([^%w%-%.%_%~])', function(c) return string.format('%%%02X', string.byte(c)) end)
end

-- Set up connections in vim-dadbod-ui
function M.setup()
  if #M.connections > 0 then
    -- URL encode passwords for proper connection strings
    local encoded_connections = {}
    for _, conn in ipairs(M.connections) do
      local encoded_conn = vim.deepcopy(conn)
      -- Extract and encode password from URL
      encoded_conn.url = encoded_conn.url:gsub(
        '://([^:]+):([^@]+)@',
        function(user, pass) return '://' .. user .. ':' .. url_encode(pass) .. '@' end
      )
      table.insert(encoded_connections, encoded_conn)
    end

    -- According to documentation, vim.g.dbs should be an array of objects
    vim.g.dbs = encoded_connections
  end
end

return M

