return {
  {
    'smjonas/inc-rename.nvim',
    depedencies = {
      { 'folke/noice.nvim', optional = true, opts = { presets = { inc_rename = true } } },
    },
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
      auto_select {
        'Search and Replace',
        function()
          local ext = vim.bo.buftype == '' and vim.fn.expand '%:e'
          fn {
            'grug-far.open',
            {
              transient = true,
              prefills = {
                filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
              },
            },
          }
        end,
      },
    },
  },
}
