local M = {}
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
local normal = '%#Normal#'

M.lsp_map = {
  lua = { cmd = 'lua-language-server', name = 'lua_ls' },
  python = { cmd = 'pyright', name = 'pyright' },
  javascript = { cmd = 'typescript-language-server', name = 'tsserver' },
  typescript = { cmd = 'typescript-language-server', name = 'tsserver' },
  go = { cmd = 'gopls', name = 'gopls' },
  rust = { cmd = 'rust-analyzer', name = 'rust_analyzer' },
  c = { cmd = 'clangd', name = 'clangd' },
  cpp = { cmd = 'clangd', name = 'clangd' },
}

M.formatters = {
  lua = 'stylua',
  python = 'black',
  javascript = 'prettier',
  typescript = 'prettier',
  go = 'gofmt',
  rust = 'rustfmt',
}

local function cwd()
  local path = vim.fn.getcwd()
  local home = vim.env.HOME
  if path:sub(1, #home) == home then
    path = '~' .. path:sub(#home + 1)
  end
  local parts = vim.split(path, '/')
  if #parts <= 1 then
    return path .. ' '
  end

  local result = {}
  for i = 1, #parts - 1 do
    table.insert(result, gray .. parts[i])
  end
  table.insert(result, normal .. parts[#parts])
  return table.concat(result, '/') .. ' '
end

local function mode_flag()
  local m = vim.fn.mode(true)
  if m:match '^no' then
    return magenta_bold .. '-o' .. normal .. ' '
  end
  local map = {
    n = { green_bold, '-n' },
    i = { yellow_bold, '-i' },
    v = { blue_bold, '-v' },
    V = { blue_bold, '-V' },
    ['\22'] = { blue_bold, '-b' },
    c = { bold, '-c' },
  }
  local mode = map[m] or { red_bold, '-?' }
  return mode[1] .. mode[2] .. normal .. ' '
end

local function filename()
  return bold .. vim.fn.expand '%:.' .. normal .. ' '
end

local function main_lsp()
  local ft = vim.bo.filetype
  local expected = M.lsp_map[ft]
  if not expected then
    return 'nvim '
  end

  local clients = vim.lsp.get_clients { bufnr = 0 }
  local has_client = false
  for _, c in ipairs(clients) do
    if c.name == expected.name then
      has_client = true
      break
    end
  end

  local has_exe = vim.fn.executable(expected.cmd) == 1
  local color = has_client and has_exe and green or has_client and yellow or red

  return color .. expected.name .. normal .. ' '
end

local function formatter()
  local ft = vim.bo.filetype
  local fmt = M.formatters[ft]
  if not fmt or vim.fn.executable(fmt) ~= 1 then
    return ''
  end
  return gray .. '--' .. fmt .. ' '
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
    return gray .. '2>' .. yellow .. warnings .. '.warn' .. normal .. ' '
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
  return gray .. encoding .. '.' .. format .. ' '
end

local function filesize_param_expansion()
  local size = vim.fn.getfsize(vim.fn.expand '%')
  local total = vim.fn.line '$'
  local size_str
  if size < 0 then
    size_str = '0B'
  elseif size < 1024 then
    size_str = size .. 'B'
  elseif size < 1024 * 1024 then
    size_str = string.format('%.1fK', size / 1024)
  elseif size < 1024 * 1024 * 1024 then
    size_str = string.format('%.1fM', size / (1024 * 1024))
  else
    size_str = string.format('%.1fG', size / (1024 * 1024 * 1024))
  end
  return gray .. '${' .. size_str .. ':-' .. total .. '} '
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

local function grep_invocation()
  local pattern = regex()
  local matches = match_count_flag(pattern)
  local total = vim.fn.line '$'
  local cmd = grep_cmd()

  local pattern_color = matches > 0 and green or red

  return gray
    .. '| '
    .. cmd
    .. ' '
    .. pattern_color
    .. '"'
    .. pattern
    .. '" '
    .. gray
    .. '-'
    .. matches
    .. normal
    .. ' '
end

local function second_lsp()
  local ft = vim.bo.filetype
  local expected = M.lsp_map[ft]
  local main_name = expected and expected.name or nil

  local clients = vim.lsp.get_clients { bufnr = 0 }

  for _, c in ipairs(clients) do
    if c.name ~= main_name then
      local has_exe = vim.fn.executable(c.name) == 1
      local color = has_exe and green or red
      return color .. c.name .. normal .. ' '
    end
  end

  return 'nvim '
end

local function alternate_file()
  local alt = vim.fn.expand '#:t:r'
  if #alt == 0 then
    return '. '
  end
  return alt .. ' '
end

function curr_line_env_var()
  return gray .. 'L=' .. vim.fn.line '.' .. ' '
end

function buf_count_flag()
  return magenta .. '-' .. #vim.fn.getbufinfo { buflisted = 1 }
end

function M.tabline()
  return table.concat({
    cwd(),
    green .. '$ ',
    curr_line_env_var(),
    main_lsp(),
    mode_flag(),
    filename(),
    formatter(),
    error_file(),
    modified_redir(),
    encoding_format_file(),
    grep_invocation(),
    filesize_param_expansion(),
    gray .. '&& ',
    second_lsp(),
    alternate_file(),
    buf_count_flag(),
  }, '')
end

return M
