return {
  {
    'coder/claudecode.nvim',
    opts = {
      terminal_cmd = 'claude --continue',
      diff_opts = {
        open_in_new_tab = true,
      },
      focus_after_send = true,
    },
    keys = {
      on_selection {
        'give context',
        cmd 'ClaudeCodeSend',
      },
      key {
        'give context',
        proc {
          fn { vim.cmd, 'ClaudeCodeTreeAdd' },
          fn { vim.cmd, 'ClaudeCodeFocus' },
        },
        ft = { 'minifiles' },
      },
      key {
        'give context',
        fn {
          when = { 'diff', in_any = 'window' },
          fn { vim.cmd, 'ClaudeCodeDiffDeny' },
          or_else = fn { vim.cmd, 'ClaudeCodeAdd %' },
        },
      },

      key {
        'go',
        fn {
          when = { 'diff', in_this = 'window' },
          fn { vim.cmd, 'ClaudeCodeDiffAccept' },
          or_else = fn {
            -- when {},
            fn { vim.cmd, 'Trouble lsp_definitions toggle' },
            or_else = fn { vim.cmd, 'Trouble lsp_type_definitions toggle' },
          },
        },
      },

      key {
        'new agent',
        proc {
          fn {
            'claudecode.setup',
            {
              terminal_cmd = 'claude',
              focus_after_send = true,
              diff_opts = {
                open_in_new_tab = true,
              },
            },
          },
          fn { vim.cmd, 'ClaudeCode' },
          fn {
            'claudecode.setup',
            {
              terminal_cmd = 'claude --continue',
              focus_after_send = true,
              diff_opts = {
                open_in_new_tab = true,
              },
            },
          },
        },
      },

      auto_select {
        'select agent',
        proc {
          fn {
            'claudecode.setup',
            {
              terminal_cmd = 'claude --resume',
              focus_after_send = true,
              diff_opts = {
                open_in_new_tab = true,
              },
            },
          },
          fn { vim.cmd, 'ClaudeCode' },
          fn {
            'claudecode.setup',
            {
              terminal_cmd = 'claude --continue',
              diff_opts = {
                open_in_new_tab = true,
              },
              focus_after_send = true,
            },
          },
        },
      },

      auto_select {
        'focus agent',
        fn { vim.cmd, 'ClaudeCodeFocus' },
      },
      key { 'focus agent', fn { vim.cmd, 'wincmd p' }, mode = 't' },
    },
  },
}
