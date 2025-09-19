return {
  {
    'smjonas/inc-rename.nvim',
    cmd = 'IncRename',
    opts = {},
    keys = {
      key {
        'Code Rename',
        function()
          local inc_rename = require 'inc_rename'
          return ':' .. inc_rename.config.cmd_name .. ' ' .. vim.fn.expand '<cword>'
        end,
        expr = true,
        desc = 'Rename (inc-rename.nvim)',
      },
    },
  },
  {
    'MagicDuck/grug-far.nvim',
    opts = { headerMaxWidth = 80 },
    cmd = 'GrugFar',
    keys = {
      {
        '<leader><F3>',
        function()
          local grug = require 'grug-far'
          local ext = vim.bo.buftype == '' and vim.fn.expand '%:e'
          grug.open {
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
            },
          }
        end,
        mode = { 'n', 'v' },
        desc = 'Search and Replace',
      },
    },
  },
}
