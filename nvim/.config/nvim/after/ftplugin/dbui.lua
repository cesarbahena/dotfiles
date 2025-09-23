-- Unmap DBUI's ? mapping after plugin loads
vim.api.nvim_create_autocmd('User', {
  pattern = 'DBUIOpened',
  once = true,
  callback = function()
    vim.keymap.del('n', '?', { buffer = true })
  end,
})