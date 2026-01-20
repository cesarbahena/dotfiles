local M = {}

M.lsp_map = {
  lua = {cmd = "lua-language-server", name = "lua_ls"},
  python = {cmd = "pyright", name = "pyright"},
  javascript = {cmd = "typescript-language-server", name = "tsserver"},
  typescript = {cmd = "typescript-language-server", name = "tsserver"},
  go = {cmd = "gopls", name = "gopls"},
  rust = {cmd = "rust-analyzer", name = "rust_analyzer"},
  c = {cmd = "clangd", name = "clangd"},
  cpp = {cmd = "clangd", name = "clangd"},
}

M.formatters = {
  lua = "stylua",
  python = "black",
  javascript = "prettier",
  typescript = "prettier",
  go = "gofmt",
  rust = "rustfmt",
}

local function cwd()
  local path = vim.fn.getcwd()
  local home = vim.env.HOME
  if path:sub(1, #home) == home then
    path = "~" .. path:sub(#home + 1)
  end
  local parts = vim.split(path, "/")
  if #parts <= 1 then return path end

  local result = {}
  for i = 1, #parts - 1 do
    table.insert(result, "%#BashGray#" .. parts[i])
  end
  table.insert(result, "%#Normal#" .. parts[#parts])
  return table.concat(result, "/")
end

local function mode_flag()
  local m = vim.fn.mode()
  local map = {n = "-n", i = "-i", v = "-v", V = "-V", ["\22"] = "-b", c = "-c"}
  return "%#BashYellow#" .. (map[m] or "-?") .. "%#Normal#"
end

local function filename()
  return vim.fn.expand("%:.")
end

local function main_lsp()
  local ft = vim.bo.filetype
  local expected = M.lsp_map[ft]
  if not expected then return "nvim " end

  local clients = vim.lsp.get_clients({bufnr = 0})
  local has_client = false
  for _, c in ipairs(clients) do
    if c.name == expected.name then
      has_client = true
      break
    end
  end

  local has_exe = vim.fn.executable(expected.cmd) == 1
  local color = has_client and has_exe and "%#BashGreen#"
             or has_client and "%#BashYellow#"
             or "%#BashRed#"

  return color .. expected.name .. "%#Normal# "
end

local function formatter()
  local ft = vim.bo.filetype
  local fmt = M.formatters[ft]
  if not fmt or vim.fn.executable(fmt) ~= 1 then return "" end
  return "%#BashGray#--" .. fmt .. " "
end

local function error_count()
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
    return "%#BashGray#2>" .. "%#BashRed#" .. errors .. ".err%#Normal# "
  elseif warnings > 0 then
    return "%#BashGray#2>" .. "%#BashYellow#" .. warnings .. ".warn%#Normal# "
  end
  return ""
end

local function modified_flag()
  return vim.bo.modified and "%#BashYellow#<< " or "%#BashGray#>> "
end

local function encoding_format()
  local encoding = vim.bo.fileencoding ~= "" and vim.bo.fileencoding or vim.o.encoding
  local format = vim.bo.fileformat
  return "%#BashGray#" .. encoding .. "." .. format .. " "
end

local function grep_info()
  local search = vim.fn.getreg("/")
  if search == "" then search = "pattern" end

  local line = vim.fn.line(".")
  local total = vim.fn.line("$")

  local matches = 0
  if search ~= "pattern" then
    local count_ok, count_result = pcall(vim.fn.searchcount, {pattern = search, maxcount = 999})
    if count_ok and count_result.total then
      matches = count_result.total
    end
  end

  local cmd = vim.fn.executable("rg") == 1 and "rg" or "grep"

  return "%#BashGray#| " .. cmd .. " %#BashBlue#" .. search .. " %#BashGray#-c " .. matches .. " -L" .. line .. "," .. total .. "%#Normal# "
end

local function alternate()
  local alt = vim.fn.expand("#:t:r")
  return alt .. "."
end

local function second_lsp()
  local ft = vim.bo.filetype
  local expected = M.lsp_map[ft]
  local main_name = expected and expected.name or nil

  local clients = vim.lsp.get_clients({bufnr = 0})

  for _, c in ipairs(clients) do
    if c.name ~= main_name then
      local has_exe = vim.fn.executable(c.name) == 1
      local color = has_exe and "%#BashGreen#" or "%#BashRed#"
      return color .. c.name .. "%#Normal# "
    end
  end

  return "nvim "
end

function M.render()
  local parts = {
    cwd() .. " %#BashGreen#$ ",
    main_lsp(),
    mode_flag() .. " ",
    "%#BashBold#" .. filename() .. "%#Normal# ",
    formatter(),
    error_count(),
    modified_flag(),
    encoding_format(),
    grep_info(),
    "%#BashGray#&& ",
    second_lsp(),
    alternate(),
  }
  return table.concat(parts, "")
end

vim.api.nvim_create_autocmd({"BufEnter", "DirChanged"}, {
  callback = function() vim.b.git_branch = nil end
})

return M
