vim.g.mapleader = ' '

local function gh(repo)
  return 'https://github.com/' .. repo
end

vim.pack.add {
  gh 'ellisonleao/gruvbox.nvim',
  gh 'luukvbaal/statuscol.nvim',
  gh 'nvim-mini/mini.pick',
  gh 'nvim-mini/mini.files',
  gh 'mfussenegger/nvim-dap',
  gh 'nvim-treesitter/nvim-treesitter',
  gh 'theHamsta/nvim-dap-virtual-text',
  gh 'rafamadriz/friendly-snippets',
  { src = gh 'saghen/blink.cmp', version = vim.version.range '1' },
  { src = gh 'saghen/blink.pairs', version = vim.version.range '0' },
}
