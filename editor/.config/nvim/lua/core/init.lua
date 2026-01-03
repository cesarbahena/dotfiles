-- Safe try assignment with backup fallback using dofile approach
local success, try_module = pcall(require, 'utils.try')
if success then
  -- Test if the try function actually works
  local try_success = pcall(try_module.try, function() end)
  if try_success then
    _G.try = try_module.try
  else
    success = false
  end
end

if not success then
  -- Load backup directly with dofile and setup dependencies
  local backup_path = vim.env.NVIM_BACKUP_PATH or vim.fn.expand '~/.config/nvim_backup'
  local backup_file = backup_path .. '/lua/utils/try.lua'
  try_module = dofile(backup_file)
  _G.try = try_module.try
end

try {
  require,
  { 'core.globals' },
  { 'core.keymaps' },
  { 'core.options' },
  { 'core.autocmd' },
  { 'core.lsp' },
}

-- Retry failed modules before lazy.nvim initialization
local retry = require 'core.retry'
if retry.has_retryable_errors() then retry.retry_failed_modules() end

try(require, 'meta.plugins')
