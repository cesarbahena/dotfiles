require('mini.pick').setup()
vim.keymap.set('n', '<leader>f', ':Pick files<cr>')

require('mini.files').setup {}
vim.keymap.set('n', '-', ':lua MiniFiles.open()<cr>')
