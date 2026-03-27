local function gh(repo)
  return 'https://github.com/' .. repo
end

vim.pack.add {
  gh 'nvim-treesitter/nvim-treesitter',
  gh 'nvim-mini/mini.pick',
  gh 'nvim-mini/mini.files',
  gh 'mfussenegger/nvim-dap',
  gh 'theHamsta/nvim-dap-virtual-text',
  gh 'luukvbaal/statuscol.nvim',
  gh 'stevearc/conform.nvim',
  gh 'catppuccin/nvim',
  { src = gh 'saghen/blink.cmp', version = vim.version.range '1' },
  gh 'saghen/blink.pairs',
  gh 'lewis6991/gitsigns.nvim',
  gh 'rafamadriz/friendly-snippets',
  gh 'seblyng/roslyn.nvim',
}
