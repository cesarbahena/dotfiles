return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = 'VeryLazy',
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    config = function(_, opts) require('nvim-treesitter.configs').setup(opts) end,
    opts = {
      indent = { enable = true },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = false,
          node_incremental = 'v',
          node_decremental = 'u',
          scope_incremental = false,
        },
      },
      textobjects = {
        select = { enable = false },
        lsp_interop = { enable = false },
        swap = {
          enable = true,
          swap_next = { ['<leader>ao'] = '@parameter.inner' },
          swap_previous = { ['<leader>ak'] = '@parameter.inner' },
        },
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = 'VeryLazy',
    opts = { separator = '¯' },
    config = function(_, opts)
      require('treesitter-context').setup(opts)
      -- Make separator really dim
      vim.api.nvim_create_autocmd('ColorScheme', {
        callback = function() vim.api.nvim_set_hl(0, 'TreesitterContextSeparator', { fg = '#555555' }) end,
      })
      vim.api.nvim_set_hl(0, 'TreesitterContextSeparator', { fg = '#555555' })
    end,
  },
  {
    'Wansmer/treesj',
    keys = { { 'j', ':TSJToggle<cr>', desc = 'Toggle node under cursor' } },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {},
  },
}
