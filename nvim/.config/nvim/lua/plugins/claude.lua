return {
  {
    'wtfox/claude-chat.nvim',
    opts = {
      -- Optional configuration
      split = 'vsplit', -- "vsplit" or "split"
      position = 'left', -- "right", "left", "top", "bottom"
      width = 0.4, -- percentage of screen width (for vsplit)
      height = 0.4, -- percentage of screen height (for split)
      claude_cmd = 'claude --continue', -- command to invoke Claude Code
    },
    keys = {
      { '?', ':ClaudeChat<CR>', desc = 'Ask Claude', mode = { 'n', 'v' } },
    },
  },
  {
    'coder/claudecode.nvim',
    dependencies = { 'folke/snacks.nvim' },
    config = true,
    keys = {
      key { 'AI agent continue session', cmd 'ClaudeCode --continue' },
      key { 'AI agent select session', cmd 'ClaudeCode --resume' },
      key { 'AI agent reset session', cmd 'ClaudeCode' },
      key { 'accept Agent changes', cmd 'ClaudeCodeDiffAccept' },
      key { 'reject Agent changes', cmd 'ClaudeCodeDiffDeny' },
      key {
        'agent',
        fn {
          when = { fn { vim.fn.system, 'pgrep -f claude' }, eq = '' },
          fn { vim.cmd, 'ClaudeCode --continue' },
          or_else = proc {
            fn { vim.cmd, 'ClaudeCode --continue' },
            fn { vim.cmd, 'ClaudeCodeAdd %', defer = 500 },
          },
        },
      },
      key { 'send Context', cmd 'ClaudeCodeAdd %' },
      key { 'send Context', cmd 'ClaudeCodeTreeAdd', ft = { 'NvimTree', 'neo-tree', 'oil', 'minifiles' } },
      on_selection { 'send Context', cmd 'ClaudeCodeSend' },
    },
  },
}
