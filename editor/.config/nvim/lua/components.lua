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
local white = '%#' .. hl.white .. '#'
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

local function mode_prompt_symbol()
  local m = vim.fn.mode(true)
  if m:match '^no' then
    return magenta_bold .. '-o' .. normal .. ' '
  end
  local map = {
    n = { green, '$' },
    i = { yellow, '&' },
    v = { blue, 'æ' },
    V = { blue, 'Æ' },
    ['\22'] = { blue, 'ß' },
    c = { green, '#' },
  }
  local mode = map[m] or { yellow, '?' }
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

function curr_line_env()
  return gray .. '(' .. vim.fn.line '$' .. ') '
end

function buf_count_flag()
  return magenta .. '-' .. #vim.fn.getbufinfo { buflisted = 1 } .. gray
end

local function test_buffers_file()
  return gray .. '; [ ' .. buf_count_flag() .. ' ' .. alternate_file() .. ' ] '
end

local function pipe_macro()
  local recording = vim.fn.reg_recording()
  if recording ~= '' then
    return gray .. ' | ' .. green .. recording
  end

  local last = vim.v.register
  if last and last:match '^%a$' then
    return gray .. ' | ' .. gray .. last
  end

  return ''
end

function M.statusline()
  return table.concat({
    curr_line_env(),
    cwd(),
    mode_prompt_symbol(),
    main_lsp(),
    filename(),
    formatter(),
    error_file(),
    modified_redir(),
    encoding_format_file(),
    test_buffers_file(),
    grep_invocation(),
    pipe_macro(),
  }, '')
end

return M
