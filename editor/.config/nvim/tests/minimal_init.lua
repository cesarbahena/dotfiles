-- Minimal init for testing
vim.opt.rtp:prepend(vim.fn.getcwd())

-- Add lazy.nvim plugin paths
local lazy_path = vim.fn.stdpath('data') .. '/lazy'
vim.opt.rtp:append(lazy_path .. '/plenary.nvim')

-- Essential globals
_G.Errors = {}

-- Verify plenary is available
local ok, _ = pcall(require, 'plenary')
if not ok then
  error('plenary.nvim is required for testing')
end