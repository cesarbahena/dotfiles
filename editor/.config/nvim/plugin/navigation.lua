require('mini.pick').setup()
vim.keymap.set('n', '<leader>f', ':Pick files<cr>')

require('mini.files').setup {
  mappings = {
    go_in_plus = 'l',
    synchronize = '<cr>',
  },
}
vim.keymap.set('n', '<leader>e', [[:lua MiniFiles.open(vim.fn.expand '%:p:h', true)<cr>]])
