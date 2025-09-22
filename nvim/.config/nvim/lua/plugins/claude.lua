return {
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
        when = { fn { 'vim.fn.system', 'pgrep -f claude' }, eq = '' },
        fn { vim.cmd, 'ClaudeCode --continue' },
        or_else = fn { vim.cmd, 'ClaudeCodeAdd %' },
      },
    },
    key { 'send Context', cmd 'ClaudeCodeAdd %' },
    key { 'send Context', cmd 'ClaudeCodeTreeAdd', ft = { 'NvimTree', 'neo-tree', 'oil', 'minifiles' } },
    on_selection { 'send Context', cmd 'ClaudeCodeSend' },
  },
}
