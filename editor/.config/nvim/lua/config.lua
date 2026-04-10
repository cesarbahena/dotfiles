local map = vim.keymap.set

vim.cmd 'colorscheme mfd-flir-rh'
local hl = vim.api.nvim_set_hl
hl(0, 'white', { ctermfg = 15, fg = '#ffffff' })
hl(0, 'gray', { ctermfg = 240, fg = '#585858' })
hl(0, 'green', { ctermfg = 46, fg = '#00ff00' })
hl(0, 'red', { ctermfg = 196, fg = '#ff0000' })
hl(0, 'yellow', { ctermfg = 226, fg = '#ffff00' })
hl(0, 'blue', { ctermfg = 39, fg = '#00afd7' })
hl(0, 'magenta', { ctermfg = 201, fg = '#ff00ff' })
hl(0, 'GitSignsAdd', { link = 'green' })
hl(0, 'GitSignsChange', { link = 'yellow' })
hl(0, 'GitSignsDelete', { link = 'red' })
hl(0, 'GitSignsUntracked', { link = 'green' })

-- Languages
for k, v in pairs({
  'rust_analyzer',
  'ts_ls',
  'lua_ls',
  'gopls',
}) do
if type(k) ~= 'number' then
  vim.lsp.config(k, v)
end
vim.lsp.enable { type(k) == 'number' and v or k }
end

require('conform').setup {
  formatters_by_ft = {},
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

vim.diagnostic.config {
  virtual_text = {
    spacing = 4,
    prefix = '!',
    source = 'if_many',
  },
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
  },
}

--Debuggers
local dap = require 'dap'
map('n', '<F5>', dap.continue)
map('n', '<F9>', dap.repl.toggle)
map('n', '<F10>', dap.step_over)
map('n', '<F11>', dap.step_into)
map('n', '<F12>', dap.step_out)
map('n', '<F4>', dap.toggle_breakpoint)
map('n', '<F16>', function()
  dap.set_breakpoint(vim.fn.input 'Condition: ')
end)

dap.adapters.python = {
  type = 'executable',
  command = 'python',
  args = { '-m', 'debugpy.adapter' },
}

dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = 'Launch file',
    program = '${file}',
    pythonPath = function()
      return vim.fn.exepath 'python'
    end,
  },
}

dap.adapters['pwa-node'] = {
  type = 'server',
  host = 'localhost',
  port = '${port}',
  executable = {
    command = 'node',
    args = {
      vim.fn.stdpath 'data' .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js',
      '${port}',
    },
  },
}

dap.configurations.javascript = {
  {
    type = 'pwa-node',
    request = 'launch',
    name = 'Launch file',
    program = '${file}',
    cwd = '${workspaceFolder}',
  },
  {
    type = 'pwa-node',
    request = 'attach',
    name = 'Attach',
    processId = require('dap.utils').pick_process,
    cwd = '${workspaceFolder}',
  },
}

dap.configurations.typescript = {
  {
    type = 'pwa-node',
    request = 'launch',
    name = 'Launch TypeScript file (tsx)',
    program = '${file}',
    cwd = '${workspaceFolder}',
    sourceMaps = true,
    skipFiles = { '<node_internals>/**', '**/node_modules/**' },
    runtimeExecutable = 'npx',
    runtimeArgs = { 'tsx' },
  },
  {
    type = 'pwa-node',
    request = 'launch',
    name = 'Launch compiled JS',
    program = '${workspaceFolder}/dist/${fileBasenameNoExtension}.js',
    cwd = '${workspaceFolder}',
    sourceMaps = true,
    skipFiles = { '<node_internals>/**' },
  },
  {
    type = 'pwa-node',
    request = 'attach',
    name = 'Attach TypeScript',
    processId = require('dap.utils').pick_process,
    cwd = '${workspaceFolder}',
    sourceMaps = true,
    skipFiles = { '<node_internals>/**' },
  },
  {
    type = 'pwa-node',
    request = 'attach',
    name = 'Attach to Dashboard Docker',
    address = 'localhost',
    port = 9229,
    localRoot = '${workspaceFolder}',
    remoteRoot = '/app',
    sourceMaps = true,
    skipFiles = { '<node_internals>/**', '**/node_modules/**' },
  },
}

dap.adapters.php = {
  type = 'executable',
  command = 'node',
  args = { vim.fn.stdpath 'data' .. '/mason/packages/php-debug-adapter/extension/out/phpDebug.js' },
}

dap.configurations.php = {
  {
    type = 'php',
    request = 'launch',
    name = 'Listen for Xdebug',
    port = 9003,
    hostname = '0.0.0.0',
    pathMappings = {
      ['/var/www/html'] = '${workspaceFolder}',
    },
    xdebugSettings = {
      max_data = 0,
    },
  },
  {
    type = 'php',
    request = 'launch',
    name = 'Launch current file',
    port = 9003,
    cwd = '${workspaceFolder}',
    program = '${file}',
    runtimeExecutable = 'php',
    runtimeArgs = { '-dxdebug.mode=debug', '-dxdebug.start_with_request=yes', '-dxdebug.client_port=9003' },
    xdebugSettings = {
      max_data = 0,
    },
  },
}

-- Gutter
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '·' },
    delete = { text = '-' },
    topdelete = { text = '-' },
    changedelete = { text = '·' },
    untracked = { text = '+' },
  },
  on_attach = function(bufnr)
    local gs = require 'gitsigns'

    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true }
      else
        gs.nav_hunk 'next'
      end
    end, { buffer = bufnr })

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true }
      else
        gs.nav_hunk 'prev'
      end
    end, { buffer = bufnr })

    map('n', '<F2>', gs.preview_hunk_inline, { buffer = bufnr })
    map({ 'n', 'v' }, '<M-u>', ':Gitsigns stage_hunk<CR>', { buffer = bufnr })
    map({ 'n', 'v' }, '<M-y>', ':Gitsigns reset_hunk<CR>', { buffer = bufnr })
  end,
}

-- =========================
-- Highlight helper assumed:
-- hl = vim.api.nvim_set_hl
-- =========================

hl(0, "LineNrNormal", {})
hl(0, "LineNrCurrent", { bold = true })
hl(0, "LineNrGit", { italic = true })
hl(0, "LineNrDiag", { underline = true })

hl(0, "LineNrBreakpoint", { bold = true })
hl(0, "LineNrStopped", { bold = true, underline = true })
hl(0, "LineNrGitDelete", { italic = true })


-- =========================
-- Gitsigns setup (no signs rendered)
-- =========================
require('gitsigns').setup {
  signs = {
    add          = { text = '' },
    change       = { text = '' },
    delete       = { text = '' },
    topdelete    = { text = '' },
    changedelete = { text = '' },
  },
}


-- =========================
-- DAP signs
-- =========================
vim.fn.sign_define('DapBreakpoint', {
  text = '·',
  texthl = 'LineNrBreakpoint',
})

vim.fn.sign_define('DapStopped', {
  text = '●',
  texthl = 'LineNrStopped',
})


-- =========================
-- Gitsigns cache
-- =========================
local git_cache = {}

vim.api.nvim_create_autocmd("User", {
  pattern = "GitSignsUpdate",
  callback = function(args)
    local ok, gs = pcall(require, "gitsigns")
    if ok and gs.get_hunks then
      git_cache[args.buf] = gs.get_hunks(args.buf) or {}
    end
  end,
})


-- =========================
-- Safe helpers (NO format)
-- =========================
local function hl_wrap(hl_group, text)
  if type(hl_group) ~= "string" or hl_group == "" then
    hl_group = "LineNrNormal"
  end
  return "%#" .. hl_group .. "#" .. text .. "%*"
end

local function pad2(n)
  if n < 10 then
    return " " .. n
  end
  return tostring(n)
end


-- =========================
-- Line number function
-- =========================
local function linenr_fn(args)
  local num = args.relnum == 0 and args.lnum or args.relnum
  local txt = pad2(num)

  -- DAP
  local placed = vim.fn.sign_getplaced(args.buf, {
    group = '*',
    lnum = args.lnum,
  })[1]

  for _, s in ipairs(placed and placed.signs or {}) do
    if s.name == "DapStopped" then
      return hl_wrap("LineNrStopped", txt)
    elseif s.name:match("^Dap") then
      return hl_wrap("LineNrBreakpoint", txt)
    end
  end

  -- Diagnostics
  local diags = vim.diagnostic.get(args.buf, {
    lnum = args.lnum - 1,
  })
  if #diags > 0 then
    return hl_wrap("LineNrDiag", txt)
  end

  -- Git (added/changed)
  local hunks = git_cache[args.buf]
  if hunks then
    for _, h in ipairs(hunks) do
      if (h.type == "add" or h.type == "change") and h.added then
        local start = h.added.start
        local count = h.added.count or 0
        if args.lnum >= start and args.lnum < start + count then
          return hl_wrap("LineNrGit", txt)
        end
      end
    end
  end

  -- Default
  if args.relnum == 0 then
    return hl_wrap("LineNrCurrent", txt)
  else
    return hl_wrap("LineNrNormal", txt)
  end
end


-- =========================
-- Right-side signal column
-- =========================
local function signal_fn(args)
  local bufnr = args.buf
  local lnum = args.lnum

  -- DAP (priority)
  local placed = vim.fn.sign_getplaced(bufnr, {
    group = '*',
    lnum = lnum,
  })[1]

  for _, s in ipairs(placed and placed.signs or {}) do
    if s.name == "DapStopped" then
      return hl_wrap("LineNrStopped", "●")
    elseif s.name:match("^DapBreakpoint") then
      return hl_wrap("LineNrBreakpoint", "·")
    end
  end

  -- Git deleted (robust, handles EOF + topdelete)
  local hunks = git_cache[bufnr]
  if hunks then
    local line_count = vim.api.nvim_buf_line_count(bufnr)

    for _, h in ipairs(hunks) do
      if (h.type == "delete" or h.type == "topdelete") and h.removed then
        local l = h.removed.start

        -- topdelete always goes to line 1
        if h.type == "topdelete" then
          l = 1
        end

        -- clamp to valid buffer range (handles EOF delete)
        if l > line_count then
          l = line_count
        end

        if lnum == l then
          return hl_wrap("LineNrGitDelete", "-")
        end
      end
    end
  end

  return " "
end


-- =========================
-- Statuscol setup
-- =========================
require('statuscol').setup {
  setopt = true,
  segments = {
    {
      text = { linenr_fn },
    },
    {
      text = { signal_fn },
    },
  },
}

require('mini.pick').setup()
map('n', '<C-k>', function()
  MiniPick.builtin.cli(
    { command = { 'rg', '--files', '--hidden', '--color=never' } },
    { source = { name = 'Files' } }
  )
end)
