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

M.tools_map = {
  lua = {"stylua", "luacheck"},
  python = {"black", "ruff"},
  javascript = {"prettier", "eslint"},
  typescript = {"prettier", "eslint"},
  go = {"gofmt"},
  rust = {"rustfmt"},
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

local function git_branch()
  if not vim.b.git_branch then
    local branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("\n", "")
    vim.b.git_branch = branch ~= "" and branch or nil
  end
  return vim.b.git_branch and ("GIT=" .. vim.b.git_branch .. " ") or ""
end

local function mode_flag()
  local m = vim.fn.mode()
  local map = {n = "-n", i = "-i", v = "-v", V = "-V", ["\22"] = "-b", c = "-c"}
  return map[m] or "-?"
end

local function filename()
  return vim.fn.expand("%:.")
end

local function main_lsp()
  local ft = vim.bo.filetype
  local expected = M.lsp_map[ft]
  if not expected then return "" end

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

local function tools()
  local ft = vim.bo.filetype
  local tool_list = M.tools_map[ft]
  if not tool_list then return "" end

  local active = {}
  for _, tool in ipairs(tool_list) do
    if vim.fn.executable(tool) == 1 then
      table.insert(active, "--" .. tool)
    end
  end

  return #active > 0 and ("%#BashGray#" .. table.concat(active, " ")) or ""
end

local function other_lsps()
  local ft = vim.bo.filetype
  local expected = M.lsp_map[ft]
  local main_name = expected and expected.name or nil

  local clients = vim.lsp.get_clients({bufnr = 0})
  local others = {}

  for _, c in ipairs(clients) do
    if c.name ~= main_name then
      local has_exe = vim.fn.executable(c.name) == 1
      local color = has_exe and "%#BashGreen#" or "%#BashYellow#"
      table.insert(others, color .. c.name)
    end
  end

  return #others > 0 and ("%#Normal# | " .. table.concat(others, " ")) or ""
end

function M.render()
  local parts = {
    cwd() .. " %#BashGreen#$ ",
    "%#BashGray#" .. git_branch(),
    main_lsp(),
    "%#Normal#" .. mode_flag() .. " ",
    "%#BashBold#" .. filename(),
    " " .. tools(),
    other_lsps(),
  }
  return table.concat(parts, "")
end

vim.api.nvim_create_autocmd({"BufEnter", "DirChanged"}, {
  callback = function() vim.b.git_branch = nil end
})

return M
