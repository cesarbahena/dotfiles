local M = {}
local config = require 'config'
local hl = require 'hl_groups'

local gray = '%#' .. hl.gray .. '#'
local bold = '%#' .. hl.bold .. '#'
local green = '%#' .. hl.green .. '#'
local green_bold = '%#' .. hl.green_bold .. '#'
local yellow = '%#' .. hl.yellow .. '#'
local yellow_bold = '%#' .. hl.yellow_bold .. '#'
local red = '%#' .. hl.red .. '#'
local red_bold = '%#' .. hl.red_bold .. '#'
local blue = '%#' .. hl.blue .. '#'
local blue_bold = '%#' .. hl.blue_bold .. '#'
local magenta = '%#' .. hl.magenta .. '#'
local magenta_bold = '%#' .. hl.magenta_bold .. '#'
local white = '%#' .. hl.white .. '#'
local normal = '%#Normal#'

function M.cwd()
  local path = vim.fn.getcwd()
  local home = vim.env.HOME
  if path:sub(1, #home) == home then
    path = '~' .. path:sub(#home + 1)
  end
  return path
end

function M.cmd_prompt()
  local path = M.cwd()
  local parts = vim.split(path, '/')

  local result = {}
  table.insert(result, { text = '(' .. vim.fn.line '$' .. ') ', hl = hl.gray })

  if #parts <= 1 then
    table.insert(result, { text = path, hl = hl.gray })
    table.insert(result, { text = ' $', hl = hl.green })
    return result
  end

  for i = 1, #parts - 1 do
    table.insert(result, { text = parts[i], hl = hl.gray })
    table.insert(result, { text = '/', hl = hl.gray })
  end
  table.insert(result, { text = parts[#parts], hl = 'Normal' })
  table.insert(result, { text = ' $', hl = hl.green })
  return result
end

function M.search_prompt()
  local result = M.cmd_prompt()
  local cmd = vim.fn.executable 'rg' == 1 and 'rg' or 'grep'
  table.insert(result, { text = ' ' .. cmd, hl = hl.gray })
  return result
end

function M.reverse_search_prompt()
  local result = M.cmd_prompt()
  local cmd = vim.fn.executable 'rg' == 1 and 'rg' or 'grep'
  table.insert(result, { text = ' ' .. cmd .. ' -r', hl = hl.gray })
  return result
end

function M.prompt_parts(prefix)
  if prefix == ';' then
    return M.cmd_prompt()
  elseif prefix == '/' then
    return M.search_prompt()
  elseif prefix == '?' then
    return M.reverse_search_prompt()
  end
  return M.cmd_prompt()
end

function M.execute_search(prefix, query)
  local cmd = vim.fn.executable 'rg' == 1 and 'rg' or 'grep'
  if prefix == ';' then
    vim.cmd('vimgrep /' .. query .. '/g %')
  elseif prefix == '/' then
    vim.cmd('vimgrep /' .. query .. '/g **/*')
  elseif prefix == '?' then
    vim.cmd('vimgrep /' .. query .. '/rg **/*')
  end
end

local function cwd()
  return M.cwd() .. ' '
end

local function mode_prompt_symbol()
  local m = vim.fn.mode(true)
  if m:match '^no' then
    return magenta_bold .. '#' .. normal .. ' '
  end
  local map = {
    n = { green, '$' },
    i = { yellow, '&' },
    v = { blue, 'æ' },
    V = { blue, 'Æ' },
    ['\22'] = { blue, 'ß' },
    c = { green, '$' },
  }
  local mode = map[m] or { yellow, '?' }
  return mode[1] .. mode[2] .. normal .. ' '
end

local function filename()
  return bold .. vim.fn.expand '%:.' .. normal .. ' '
end

local function main_lsp_cmd()
  local ft = vim.bo.filetype
  local expected = config.get_lsp_config(ft)
  if not expected then
    return gray .. 'nvim '
  end

  local has_exe = vim.fn.executable(expected.cmd) == 1
  local color = has_exe and green or red
  return color .. expected.name .. normal .. ' '
end

local function other_lsp_flags()
  local ft = vim.bo.filetype
  local expected = config.get_lsp_config(ft)
  if not expected then
    return ''
  end

  local clients = vim.lsp.get_clients { bufnr = 0 }
  local flags = {}
  for _, c in ipairs(clients) do
    if c.name ~= expected.name then
      local has_exe = vim.fn.executable(c.name) == 1
      local color = has_exe and gray or red
      table.insert(flags, color .. '--' .. c.name)
    end
  end
  return #flags > 0 and ' ' .. table.concat(flags, ' ') or ''
end

local function formatter_flags()
  local ft = vim.bo.filetype
  local fmts = config.get_formatters(ft)
  if #fmts == 0 then
    return ''
  end
  local available = vim.tbl_filter(function(f)
    return vim.fn.executable(f) == 1
  end, fmts)
  if #available == 0 then
    return red .. '--' .. fmts[1] .. ' '
  end
  return gray .. '--' .. available[1] .. ' '
end

local function error_file()
  local diagnostics = vim.diagnostic.get(0)
  local errors = 0
  local warnings = 0

  for _, d in ipairs(diagnostics) do
    if d.severity == vim.diagnostic.severity.ERROR then
      errors = errors + 1
    elseif d.severity == vim.diagnostic.severity.WARN then
      warnings = warnings + 1
    end
  end

  if errors > 0 then
    return gray .. '2>' .. red .. errors .. '.err' .. normal .. ' '
  elseif warnings > 0 then
    return gray .. '2>' .. yellow .. warnings .. '.wrn' .. normal .. ' '
  end
  return ''
end

local function modified_redir()
  local fname = vim.fn.expand '%'
  if vim.bo.modified then
    return yellow .. '>> '
  elseif fname ~= '' and vim.fn.filereadable(fname) == 0 then
    return green .. '> '
  else
    return gray .. '< '
  end
end

local function encoding_format_file()
  local encoding = vim.bo.fileencoding ~= '' and vim.bo.fileencoding or vim.o.encoding
  local format = vim.bo.fileformat
  return gray .. encoding .. '.' .. format
end

local function grep_cmd()
  return vim.fn.executable 'rg' == 1 and 'rg' or 'grep'
end

local function regex()
  local search = vim.fn.getreg '/'
  return search ~= '' and search or 'pattern'
end

local function match_count_flag(pattern)
  if pattern == 'pattern' then
    return 0
  end
  local ok, result = pcall(vim.fn.searchcount, { pattern = pattern, maxcount = 999 })
  return (ok and result.total) and result.total or 0
end

local function marks()
  local upper = {}
  local lower = {}
  for i = 65, 90 do
    local name = vim.fn.nr2char(i)
    if vim.fn.getpos('\'' .. name)[1] ~= 0 then
      table.insert(upper, name)
    end
  end
  for i = 97, 122 do
    local name = vim.fn.nr2char(i)
    if vim.fn.getpos('\'' .. name)[2] ~= 0 then
      table.insert(lower, name)
    end
  end
  local result = table.concat(upper, '')
  if #lower > 0 then
    result = result .. '.' .. table.concat(lower, '')
  end
  return result
end

local function grep_invocation()
  local pattern = regex()
  local matches = match_count_flag(pattern)
  local cmd = grep_cmd()

  local pattern_color = matches > 0 and green or red

  return gray .. '&& ' .. cmd .. ' -' .. matches .. ' ' .. pattern_color .. '"' .. pattern .. '" ' .. gray .. marks()
end

local function alternate_file()
  local alt = vim.fn.expand '#:t'
  if #alt == 0 then
    return gray .. '.'
  end
  return gray .. alt
end

function total_lines_env()
  return gray .. '(' .. vim.fn.line '$' .. ') '
end

function buf_count_flag()
  return blue .. '-' .. #vim.fn.getbufinfo { buflisted = 1 } .. gray
end

local function test_buffers_file()
  return gray .. '; [ ' .. buf_count_flag() .. ' ' .. alternate_file() .. ' ] '
end

local function pipe_into_macro()
  local recording = vim.fn.reg_recording()
  if recording ~= '' then
    return gray .. ' | ' .. magenta .. recording
  end
end

function M.statusline()
  return table.concat({
    total_lines_env(),
    cwd(),
    mode_prompt_symbol(),
    main_lsp_cmd(),
    other_lsp_flags(),
    formatter_flags(),
    filename(),
    error_file(),
    modified_redir(),
    encoding_format_file(),
    test_buffers_file(),
    grep_invocation(),
    pipe_into_macro(),
  }, '')
end

return M
