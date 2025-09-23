return {
  {
    'coder/claudecode.nvim',
    dependencies = { 'folke/snacks.nvim' },
    opts = {
      terminal = {
        split_side = 'left',
      },
      terminal_cmd = 'claude --continue',
      focus_after_send = true,
      diff_opts = {
        open_in_new_tab = true,
      },
    },
    keys = {
      on_selection { 'give context', cmd 'ClaudeCodeSend' },
      key { 'give context', cmd 'ClaudeCodeTreeAdd', ft = { 'minifiles' } },
      key {
        'give context',
        fn {
          when = { 'diff', in_any = 'window' },
          fn { vim.cmd, 'ClaudeCodeDiffDeny' },
          or_else = fn { vim.cmd, 'ClaudeCodeAdd %' },
        },
      },

      key { 'lgtm', cmd 'ClaudeCodeDiffAccept' },

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
    },
  },
}
