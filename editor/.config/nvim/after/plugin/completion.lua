require('blink.cmp').setup {
  enabled = function()
    return not vim.tbl_contains({ 'minifiles' }, vim.bo.filetype)
  end,
}

vim.keymap.set({ 'n', 't' }, '<leader>o', function()
  require('opencode').toggle()
end, { desc = 'Toggle opencode' })
vim.keymap.set({ 'n', 'x' }, '<leader>a', function()
  require('opencode').ask('@this: ', { submit = true })
end, { desc = 'Ask opencode…' })
vim.keymap.set({ 'n', 'x' }, '<leader>x', function()
  require('opencode').select()
end, { desc = 'Execute opencode action…' })

vim.keymap.set({ 'n', 'x' }, '<leader>i', function()
  return require('opencode').operator '@this '
end, { desc = 'Add range to opencode', expr = true })
vim.keymap.set('n', '<leader>ii', function()
  return require('opencode').operator '@this ' .. '_'
end, { desc = 'Add line to opencode', expr = true })

vim.keymap.set('n', '<M-u>', function()
  require('opencode').command 'session.half.page.up'
end, { desc = 'Scroll opencode up' })
vim.keymap.set('n', '<C-d>', function()
  require('opencode').command 'session.half.page.down'
end, { desc = 'Scroll opencode down' })
