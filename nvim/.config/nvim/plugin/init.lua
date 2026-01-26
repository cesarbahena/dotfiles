vim.keymap.set('n', '<space>', '<nop>')
vim.g.mapleader = ' '

vim.g.loaded_sql_completion = 1
vim.g.omni_sql_no_default_maps = 1

vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.tabline = [[%!v:lua.require'components'.tabline()]]

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
  gh 'ellisonleao/gruvbox.nvim',
  { src = gh 'saghen/blink.cmp', version = vim.version.range '1' },
  gh 'saghen/blink.pairs',
  gh 'rafamadriz/friendly-snippets',
  gh 'tpope/vim-dadbod',
  gh 'kristijanhusak/vim-dadbod-ui',
  gh 'kristijanhusak/vim-dadbod-completion',
  gh 'lewis6991/gitsigns.nvim',
}
