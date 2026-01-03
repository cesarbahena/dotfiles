local M = {}

--[[General utils]]

-- Get (or create) global nested table from dot-separated path
function M.global(path)
  local current = _G
  for part in string.gmatch(path, '[^%.]+') do
    current[part] = current[part] or {}
    current = current[part]
  end
  return current
end

-- Helper for command strings with <CR>
function M.cmd(command) return '<cmd>' .. command .. '<cr>' end

-- Helper for vim.cmd.normal with bang
function M.bang(command)
  return function() vim.cmd.normal { command, bang = true } end
end

-- Execute functions sequentially
function M.proc(funcs)
  return function()
    for _, func in ipairs(funcs) do
      func()
    end
  end
end

-- Feed keys with sensible defaults for nvim_replace_termcodes
-- Uses pattern: (str, true, false, true) - standard key feeding
-- Note: If you need do_lt=true for <lt> sequences, use vim.api.nvim_replace_termcodes directly
function M.feed(keys)
  return function()
    local termcodes = vim.api.nvim_replace_termcodes(keys, true, false, true)
    vim.api.nvim_feedkeys(termcodes, 'n', false)
  end
end

-- Returns true only if a *visible* window shows a buffer with given filetype
function M.is_win_open(ft)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buftype = vim.api.nvim_get_option_value('filetype', { buf = buf })
    if buftype == ft then return true end
  end
  return false
end

function M.is_diagnostic()
  local diagnostics = vim.diagnostic.get(0)
  local pos = vim.api.nvim_win_get_cursor(0)
  if #diagnostics == 0 then return false end

  -- Get word boundaries under cursor
  local line = vim.api.nvim_get_current_line()
  local col = pos[2]

  -- Find word start
  local word_start = col
  while word_start > 0 and line:sub(word_start, word_start):match '[%w_]' do
    word_start = word_start - 1
  end

  -- Find word end
  local word_end = col
  while word_end <= #line and line:sub(word_end + 1, word_end + 1):match '[%w_]' do
    word_end = word_end + 1
  end

  local message = vim.tbl_filter(function(d)
    return d.lnum == pos[1] - 1 and not (word_end < d.col or word_start > (d.end_col or d.col)) -- Ranges overlap
  end, diagnostics)
  return #message > 0
end

-- Import fn module
M.fn = require('utils.fn').fn

return M
