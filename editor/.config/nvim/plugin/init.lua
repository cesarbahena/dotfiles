local function gh(repo)
  return 'https://github.com/' .. repo
end

vim.pack.add {
  gh 'neovim/nvim-lspconfig',
  gh 'nvim-mini/mini.pick',
  gh 'mfussenegger/nvim-dap',
  gh 'stevearc/conform.nvim',
  gh 'luukvbaal/statuscol.nvim',
  gh 'lewis6991/gitsigns.nvim',
  gh 'kungfusheep/mfd.nvim',
}

require 'config'
