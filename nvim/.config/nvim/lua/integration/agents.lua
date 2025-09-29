return {
  {
    'coder/claudecode.nvim',
    opts = {
      terminal = {
        split_side = 'left',
        provider = 'native',
      },
      terminal_cmd = 'claude --continue',
      focus_after_send = true,
      diff_opts = {
        open_in_new_tab = true,
      },
    },
    keys = {
      on_selection {
        'give context',
        proc {
          fn { vim.cmd, 'ClaudeCodeSend' },
          fn { vim.cmd, 'ClaudeCodeFocus' },
        },
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
        'lgtm',
        proc {
          fn { vim.cmd, 'wincmd l' },
          fn { vim.cmd, 'wincmd l' },
          fn { vim.cmd, 'wincmd l' },
          fn { vim.cmd, 'ClaudeCodeDiffAccept' },
        },
      },

      key {
        'new agent',
        proc {
          fn { 'claudecode.setup', { terminal_cmd = 'claude' } },
          fn { vim.cmd, 'ClaudeCode' },
          fn { 'claudecode.setup', { terminal_cmd = 'claude --continue' } },
        },
      },

      auto_select {
        'select agent',
        proc {
          fn { 'claudecode.setup', { terminal_cmd = 'claude --resume' } },
          fn { vim.cmd, 'ClaudeCode' },
          fn { 'claudecode.setup', { terminal_cmd = 'claude --continue' } },
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
