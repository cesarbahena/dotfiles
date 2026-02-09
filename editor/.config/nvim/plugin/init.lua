-- Neovim specific options
vim.opt.laststatus = 3
vim.opt.cmdheight = 0
vim.opt.showmode = false
vim.opt.showcmd = false
vim.opt.statusline = [[%!v:lua.require'components'.statusline()]]
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

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
  gh 'ellisonleao/gruvbox.nvim',
  { src = gh 'saghen/blink.cmp', version = vim.version.range '1' },
  gh 'saghen/blink.pairs',
  gh 'rafamadriz/friendly-snippets',
  gh 'tpope/vim-dadbod',
  gh 'kristijanhusak/vim-dadbod-ui',
  gh 'kristijanhusak/vim-dadbod-completion',
  gh 'lewis6991/gitsigns.nvim',
  gh 'seblyng/roslyn.nvim',
}
