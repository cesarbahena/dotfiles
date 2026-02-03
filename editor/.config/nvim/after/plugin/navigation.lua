require('mini.pick').setup()
vim.keymap.set('n', '<leader>f', function()
  MiniPick.builtin.cli(
    { command = { 'rg', '--files', '--hidden', '--color=never' } },
    { source = { name = 'Files (rg)' } }
  )
end)

require('mini.files').setup {
  mappings = {
    go_in_plus = 'l',
    synchronize = '<cr>',
  },
}
vim.keymap.set('n', '<leader>e', [[:lua MiniFiles.open(vim.fn.expand '%:p:h', true)<cr>]])
