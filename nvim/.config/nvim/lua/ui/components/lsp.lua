local M = {}

local static = {
  excluded = { 'copilot', 'efm', 'null-ls', 'conform' },
}

function M.server()
  local buf_clients = vim.lsp.get_clients { bufnr = 0 }

  local language_servers = {}
  for _, client in ipairs(buf_clients) do
    local is_excluded = false
    for _, excluded_name in ipairs(static.excluded) do
      if client.name:lower():find(excluded_name:lower()) then
        is_excluded = true
        break
      end
    end
    if not is_excluded then table.insert(language_servers, client) end
  end

  local config_errors = _G.Errors and type(_G.Errors) == 'table' and #_G.Errors > 0 and ' ' or ' '

  if #language_servers == 0 then return config_errors .. 'nvim' end

  local client = language_servers[1]
  return config_errors .. client.name
end

return M
