vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- Environment variable configuration:
-- NVIM_BACKUP_PATH: Path to backup configuration (default: ~/.config/nvim_backup)
-- NVIM_SAFE_MODE: Set to '1' to load backup config immediately without waiting for errors
local NVIM_BACKUP_PATH = vim.env.NVIM_BACKUP_PATH or vim.fn.expand '~/.config/nvim_backup'
local NVIM_SAFE_MODE = vim.env.NVIM_SAFE_MODE == '1'

-- Add backup path to runtimepath FIRST if SAFE_MODE is enabled
if NVIM_SAFE_MODE then vim.opt.rtp:prepend(NVIM_BACKUP_PATH) end

require 'core'
