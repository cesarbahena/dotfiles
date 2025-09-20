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
      key { 'Paste after', '<Plug>(YankyPutAfter)' },
      key { 'Paste before', '<Plug>(YankyPutBefore)' },
      -- In visual mode, paste over selection without yanking
      -- it's desired default behavior, so we reverse the keys
      on_selection { 'Paste over', '<Plug>(YankyPutBefore)' },
      on_selection { 'Paste over and yank', '<Plug>(YankyPutAfter)' },
      key { 'wrong Paste', '<Plug>(YankyCycleForward)' },
      key { 'Paste wasnt wrong', '<Plug>(YankyCycleBackward)' },
      key { 'Paste below', '<Plug>(YankyPutIndentAfterLinewise)' },
      key { 'Paste above', '<Plug>(YankyPutIndentBeforeLinewise)' },
    },
  },
}
