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

map('n', '<F5>', dap.continue)
map('n', '<F10>', dap.step_over)
map('n', '<F11>', dap.step_into)
map('n', '<F12>', dap.step_out)
map('n', '<leader>b', dap.toggle_breakpoint)
map('n', '<leader>dr', dap.repl.toggle)
map('n', '<leader>B', function()
  dap.set_breakpoint(vim.fn.input 'Condition: ')
end)

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

require('statuscol').setup {
  setopt = true,
  segments = {
    {
      sign = {
        namespace = { 'gitsign' },
        maxwidth = 1,
        colwidth = 1,
        auto = false
      },
    },
    {
      text = {
        function(args)
          local placed = vim.fn.sign_getplaced(
            args.buf,
            { group = '*', lnum = args.lnum }
          )[1]
          for _, s in ipairs(placed and placed.signs or {}) do
            if s.name == 'DapStopped' then
              return '%#magenta#'
                  .. (args.relnum == 0
                    and string.format('%2d', args.lnum)
                    or string.format('%2d', args.relnum))
                  .. '%*'
            elseif s.name:match '^Dap' then
              return '%#blue#'
                  .. (args.relnum == 0
                    and string.format('%2d', args.lnum)
                    or string.format('%2d', args.relnum))
                  .. '%*'
            end
          end
          local diags = vim.diagnostic.get(args.buf, { lnum = args.lnum - 1 })
          for _, d in ipairs(diags) do
            if d.severity == vim.diagnostic.severity.ERROR then
              return '%#red#'
                  .. (args.relnum == 0
                    and string.format('%2d', args.lnum)
                    or string.format('%2d', args.relnum))
                  .. '%*'
            elseif d.severity == vim.diagnostic.severity.WARN then
              return '%#yellow#'
                  .. (args.relnum == 0
                    and string.format('%2d', args.lnum)
                    or string.format('%2d', args.relnum))
                  .. '%*'
            end
          end
          return '%#'
              .. (args.relnum == 0 and 'white' or 'gray')
              .. '#'
              .. (args.relnum == 0
                and string.format('%2d', args.lnum)
                or string.format('%2d', args.relnum))
              .. '%*'
        end,
      },
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
