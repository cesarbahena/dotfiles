---@class RetryHandler
---Retry mechanism for failed modules before lazy.nvim initialization
local M = {}

---Clear module from package cache
---@param source string Full path to the source file
---@return string|nil module_name The module name if successfully converted
local function clear_module_cache(source)
  if not source or source == 'unknown' then return nil end

  -- Convert file path to module name
  -- Examples:
  -- "lua/core/keymaps.lua" -> "core.keymaps"
  -- "/home/user/.config/nvim/lua/core/options.lua" -> "core.options"
  -- "core/lsp.lua" -> "core.lsp"

  local module_name = source

  -- Remove .lua extension
  module_name = module_name:gsub('%.lua$', '')

  -- Remove lua/ prefix if present
  module_name = module_name:gsub('^.*lua/', '')

  -- Convert path separators to dots
  module_name = module_name:gsub('/', '.')

  -- Remove init if it's the last part (lua/core/init.lua -> core)
  module_name = module_name:gsub('%.init$', '')

  -- Clear from package cache
  if module_name and module_name ~= '' then
    package.loaded[module_name] = nil
    return module_name
  end

  return nil
end

---Attempt to retry a failed module
---@param error_info table Error information with source field
---@return boolean success Whether the retry succeeded
local function retry_module(error_info)
  if not error_info or not error_info.source then return false end

  local module_name = clear_module_cache(error_info.source)
  if not module_name then return false end

  -- Attempt to re-require the module
  local success, result = pcall(require, module_name)
  if success then
    print(string.format('✅ Successfully retried module: %s', module_name))
    return true
  else
    print(string.format('❌ Retry failed for module: %s - %s', module_name, result))
    return false
  end
end

---Retry all failed modules stored in _G.Errors
---@return table retry_results Results of retry attempts
function M.retry_failed_modules()
  if not _G.Errors or #_G.Errors == 0 then return { total = 0, successful = 0, failed = 0 } end

  -- Prepend backup path for retry attempts
  local backup_path = vim.env.NVIM_BACKUP_PATH or vim.fn.expand('~/.config/nvim_backup')
  vim.opt.rtp:prepend(backup_path)

  print(string.format('🔄 Attempting to retry %d failed modules...', #_G.Errors))

  local results = {
    total = #_G.Errors,
    successful = 0,
    failed = 0,
    retried_modules = {},
  }

  -- Keep track of already retried modules to avoid duplicates
  local already_retried = {}

  for i, error_info in ipairs(_G.Errors) do
    if error_info.source and not already_retried[error_info.source] then
      already_retried[error_info.source] = true

      local success = retry_module(error_info)
      local module_name = clear_module_cache(error_info.source)

      table.insert(results.retried_modules, {
        source = error_info.source,
        module = module_name,
        success = success,
        original_error = error_info.message,
      })

      if success then
        results.successful = results.successful + 1
      else
        results.failed = results.failed + 1
      end
    end
  end

  -- Note: We don't remove errors from _G.Errors to preserve error history

  print(string.format('✅ Retry complete: %d successful, %d failed', results.successful, results.failed))

  return results
end

---Check if there are any retryable errors
---@return boolean has_retryable_errors
function M.has_retryable_errors()
  if not _G.Errors or #_G.Errors == 0 then return false end

  for _, error_info in ipairs(_G.Errors) do
    if error_info.source and error_info.source ~= 'unknown' then return true end
  end

  return false
end

return M

