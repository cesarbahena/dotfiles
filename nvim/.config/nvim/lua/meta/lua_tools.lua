return {
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    cmd = 'LazyDev',
    opts = {
      library = {
        { path = 'utils/fn.lua', words = { 'fn' } },
      },
    },
  },
}
