local dap = require 'dap'
local map = vim.keymap.set
local q = { silent = true }

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

map('n', '<F5>', dap.continue, q)
map('n', '<F10>', dap.step_over, q)
map('n', '<F11>', dap.step_into, q)
map('n', '<F12>', dap.step_out, q)
map('n', '<leader>b', dap.toggle_breakpoint, q)
map('n', '<leader>dr', dap.repl.toggle, q)
map('n', '<leader>B', function()
  dap.set_breakpoint(vim.fn.input 'Condition: ')
end, q)

require('nvim-dap-virtual-text').setup {
  enabled = true,
  enabled_commands = true,
  highlight_changed_variables = true,
  highlight_new_as_changed = true,
  show_stop_reason = true,
  commented = false,
}
