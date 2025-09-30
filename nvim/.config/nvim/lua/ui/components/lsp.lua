local M = {}

local static = {
  excluded = { 'copilot', 'efm', 'null-ls', 'conform' },
  is_refreshing = false,
  refresh_timer = nil,
}

local function start_refresh_cycle()
  if static.refresh_timer then static.refresh_timer:stop() end

  local function refresh()
    if static.is_refreshing then
      vim.cmd 'redrawtabline'
      static.refresh_timer = vim.defer_fn(refresh, 200)
    end
  end

  refresh()
end

local function stop_refresh_cycle()
  if static.refresh_timer then
    static.refresh_timer:stop()
    static.refresh_timer = nil
  end
  vim.cmd 'redrawtabline'
end

function M.server()
  local ok, lsp_progress = pcall(require, 'lsp-progress')
  if ok then
    local progress = lsp_progress.progress()
    local has_progress = progress ~= ''

    if has_progress and not static.is_refreshing then
      static.is_refreshing = true
      start_refresh_cycle()
    elseif not has_progress and static.is_refreshing then
      static.is_refreshing = false
      stop_refresh_cycle()
    end
  end

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

  local lsp_indicator
  if _G.Errors and type(_G.Errors) == 'table' and #_G.Errors > 0 then
    lsp_indicator = ' '
  else
    if ok then
      local progress = lsp_progress.progress()
      lsp_indicator = progress ~= '' and (progress .. ' ') or '  '
    else
      lsp_indicator = '  '
    end
  end

  if #language_servers == 0 then return lsp_indicator .. 'nvim' end

  local client = language_servers[1]
  return lsp_indicator .. client.name
end

return M

