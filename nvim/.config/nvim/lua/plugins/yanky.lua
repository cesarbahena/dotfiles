return {
  {
    'gbprod/yanky.nvim',
    recommended = true,
    desc = 'Better Yank/Paste',
    event = 'VeryLazy',
    opts = {
      highlight = { timer = 150 },
    },
    keys = {
      auto_select { 'Yank', '<Plug>(YankyYank)' },
      auto_select { 'Paste after', '<Plug>(YankyGPutAfter)' },
      auto_select { 'Paste before', '<Plug>(YankyGPutBefore)' },
      key { 'wrong Paste', '<Plug>(YankyCycleForward)' },
      key { 'Paste wasnt wrong', '<Plug>(YankyCycleBackward)' },
      key { 'Paste below', '<Plug>(YankyPutIndentAfterLinewise)' },
      key { 'Paste above', '<Plug>(YankyPutIndentBeforeLinewise)' },
    },
  },
}
