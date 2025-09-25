return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-telescope/telescope-ui-select.nvim',
    },
    keys = {
      { desc = 'Continue', 'B', fn 'dap.continue' },
      { desc = 'Step over', 'bn', fn 'dap.step_over' },
      { desc = 'Step into', 'bi', fn 'dap.step_into' },
      { desc = 'Step out', 'be', fn 'dap.step_out' },
      { desc = 'Debug again', 'bb', fn 'dap.run_last' },
      { desc = 'Run to Cursor', 'bt', fn 'dap.run_to_cursor' },
      { desc = 'Toggle Breakpoint', 'bp', fn 'dap.toggle_breakpoint' },
      {
        desc = 'Breakpoint condition',
        'bf',
        fn { vim.fn.input, { prompt = 'Breakpoint condition:' } },
      },
      {
        desc = 'Logpoint',
        'bl',
        fn { vim.fn.input, { prompt = 'Log:' } },
      },
    },
    config = function()
      vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DiagnosticSignError', linehl = '', numhl = '' })
      vim.fn.sign_define('DapStopped', { text = '', texthl = 'DiagnosticSignOk', linehl = '', numhl = '' })
      vim.fn.sign_define(
        'DapBreakpointRejected',
        { text = ' ', texthl = 'DiagnosticSignError', linehl = '', numhl = '' }
      )
      vim.fn.sign_define(
        'DapBreakpointCondition',
        { text = ' ', texthl = 'DiagnosticSignWarn', linehl = '', numhl = '' }
      )
      vim.fn.sign_define('DapLogPoint', { text = '󱅰 ', texthl = 'DiagnosticSignInfo', linehl = '', numhl = '' })

      -- TypeScript/JavaScript configuration
      local dap = require 'dap'
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

      -- PHP configuration
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
            max_children = 0,
            max_data = 0,
            max_depth = 0,
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
            max_children = 0,
            max_data = 0,
            max_depth = 0,
          },
        },
      }
    end,
  },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
    },
    keys = {
      { desc = 'Toggle UI', '<leader>b', fn 'dapui.toggle' },
      { desc = 'Inspect expresion', 'bk', fn 'dapui.eval' },
      {
        desc = 'Watch variable',
        'bw',
        -- This has to be a vim cmd because elements.watches doesn't exist at load time
        fn 'dapui::elements.watches.add',
      },
    },
    opts = {
      mappings = {
        edit = 's',
        expand = 'i',
        open = '<cr>',
        remove = 'd',
        toggle = 'c',
        repl = 'r',
      },
      expand_lines = true,
      layouts = {
        {
          elements = {
            { id = 'scopes', size = 0.7 },
            { id = 'watches', size = 0.3 },
          },
          size = 40,
          position = 'left',
        },
        {
          elements = {
            { id = 'stacks', size = 0.7 },
            { id = 'breakpoints', size = 0.3 },
          },
          size = 40,
          position = 'right',
        },
        {
          elements = {
            { id = 'repl', size = 0.5 },
            { id = 'console', size = 0.5 },
          },
          size = 10,
          position = 'bottom',
        },
      },
      floating = {
        border = 'rounded',
        mappings = {},
      },
    },
    config = function(_, opts)
      local dap = require 'dap'
      local dapui = require 'dapui'
      dapui.setup(opts)
      dap.listeners.after.event_initialized['dapui_config'] = fn 'dapui.open'
      dap.listeners.before.event_terminated['dapui_config'] = fn 'dapui.close'
      dap.listeners.before.event_exited['dapui_config'] = fn 'dapui.close'
      dap.listeners.before.disconnect['dapui_config'] = fn 'dapui.close'
    end,
  },
}
