return {
  {
    'folke/trouble.nvim',
    cmd = { 'Trouble' },
    opts = {
      follow = true,
      auto_preview = true,
    },
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
      { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics (Trouble)' },
      { '<leader>cs', '<cmd>Trouble symbols toggle<cr>', desc = 'Symbols (Trouble)' },
      { '<leader>cS', '<cmd>Trouble lsp toggle<cr>', desc = 'LSP references/definitions/... (Trouble)' },
      key { 'quiCkfiX list', cmd 'Trouble qflist toggle' },
      key {
        'Next dx',
        fn 'utils.trouble_cycle.next',
      },
      key {
        'Prev dx',
        fn 'utils.trouble_cycle.prev',
      },
      key { 'clean', fn 'actions.clean' },
    },
  },
}
