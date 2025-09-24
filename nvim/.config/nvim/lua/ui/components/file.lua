local utils = require 'ui.components.utils'
local git = require 'ui.components.git'

local M = {}

function M.icon()
  local rightmost_win = utils.window()
  local buf = vim.api.nvim_win_get_buf(rightmost_win)
  local filetype = vim.api.nvim_get_option_value('filetype', { buf = buf })
  local icon, hl = require('mini.icons').get('filetype', filetype)
  return icon
end

function M.icon_hl()
  local rightmost_win = utils.window()
  local buf = vim.api.nvim_win_get_buf(rightmost_win)
  local filetype = vim.api.nvim_get_option_value('filetype', { buf = buf })
  local icon, hl_group = require('mini.icons').get('filetype', filetype)

  local hl_attrs = vim.api.nvim_get_hl(0, { name = hl_group })
  local color = hl_attrs.fg and string.format('#%06x', hl_attrs.fg) or 'NonText'

  return { fg = color }
end

function M.name()
  local rightmost_win = utils.window()
  local buf = vim.api.nvim_win_get_buf(rightmost_win)
  local filepath = vim.api.nvim_buf_get_name(buf)
  local filename = vim.fn.fnamemodify(filepath, ':t')
  return filename ~= '' and (' ' .. filename) or ''
end

function M.name_hl()
  local rightmost_win = utils.window()
  local buf = vim.api.nvim_win_get_buf(rightmost_win)
  local filepath = vim.api.nvim_buf_get_name(buf)
  local modified = vim.api.nvim_get_option_value('modified', { buf = buf })
  local has_diagnostics = #vim.diagnostic.get(buf) > 0

  local color = git.status_colors(filepath)
  local hl_attrs = { fg = color }
  if modified then hl_attrs.italic = true end
  if has_diagnostics then hl_attrs.underline = true end

  return hl_attrs
end

function M.format()
  local rightmost_win = utils.window()
  local buf = vim.api.nvim_win_get_buf(rightmost_win)
  local fileformat = vim.api.nvim_get_option_value('fileformat', { buf = buf })

  if fileformat == 'dos' then
    return ' '
  elseif fileformat == 'mac' then
    return ' '
  else
    return ' '
  end
end

function M.format_condition()
  local rightmost_win = utils.window()
  local buf = vim.api.nvim_win_get_buf(rightmost_win)
  local fileformat = vim.api.nvim_get_option_value('fileformat', { buf = buf })

  local system_format = 'unix'
  if vim.fn.has 'wsl' == 1 then
    system_format = 'unix'
  elseif vim.fn.has 'win32' == 1 or vim.fn.has 'win64' == 1 then
    system_format = 'dos'
  elseif vim.fn.has 'mac' == 1 then
    system_format = 'mac'
  end

  return fileformat ~= system_format
end

return M