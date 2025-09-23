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
      key { 'Put', '<Plug>(YankyPutAfter)' },
      on_selection { 'Put', '<Plug>(YankyPutBefore)' },
      on_selection { 'Put and yank', '<Plug>(YankyPutAfter)' },
      key { 'Prev put', '<Plug>(YankyCycleForward)' },
      key { 'Put below', '<Plug>(YankyPutIndentAfterLinewise)' },
      key { 'Put above', '<Plug>(YankyPutIndentBeforeLinewise)' },
    },
  },
}
