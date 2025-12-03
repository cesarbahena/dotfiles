local M = {}

-- Example database connections
-- Uncomment and modify as needed for your databases

M.connections = {
  -- Main application database (exam data, patients, etc.)
  {
    name = 'mein',
    url = string.format(
      'mysql://%s:%s@docker-1.mein.com.mx:9207/mein',
      os.getenv 'MEIN_DB_USER' or 'username',
      os.getenv 'MEIN_DB_PASS' or 'password'
    ),
  },

  {
    name = 'adminte',
    url = string.format(
      'mysql://%s:%s@34.28.141.45:3306/promedic_laboratorio',
      os.getenv 'ADMINTE_DB_USER' or 'username',
      os.getenv 'ADMINTE_DB_PASS' or 'password'
    ),
  },

  {
    name = 'adminte-tunel',
    url = string.format(
      'mysql://%s:%s@34.28.141.45:3306/promedic_laboratorio',
      os.getenv 'ADMINTE_DB_USER',
      os.getenv 'ADMINTE_DB_PASS'
    ),
  },

  -- Authentication database (usernames, pandas table)
  {
    name = 'pandax',
    url = string.format(
      'mysql://%s:%s@docker-1.mein.com.mx:9207/pandax',
      os.getenv 'MEIN_DB_USER' or 'username',
      os.getenv 'MEIN_DB_PASS' or 'password'
    ),
  },

  -- Test database for document templates (local development)
  {
    name = 'mein_test',
    url = 'mysql://mein_test_user:mein_test_pass@127.0.0.1:3306/mein_test',
  },
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
