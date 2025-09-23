return {
  -- Tailwind CSS tools with conceal/folding
  {
    'luckasRanarison/tailwind-tools.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      document_color = {
        enabled = true,
        kind = 'inline',
      },
      conceal = {
        enabled = true,
        min_length = 20,
        symbol = '…',
      },
    },
  },
}
