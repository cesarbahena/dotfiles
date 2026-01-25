local connections_file = vim.fn.expand '~/.config/nvim/connections.json'
if vim.fn.filereadable(connections_file) == 1 then
  local ok, connections = pcall(vim.json.decode, table.concat(vim.fn.readfile(connections_file)))
  if ok then
    vim.g.dbs = connections
  end
else
  vim.g.dbs = {}
end

vim.g.db_ui_save_location = vim.fn.stdpath 'data' .. '/dadbod_ui'
vim.g.db_ui_auto_execute_table_helpers = 1
vim.g.db_ui_force_echo_notifications = 1

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'sql', 'mysql', 'pgsql' },
  callback = function()
    vim.opt_local.omnifunc = 'vim_dadbod_completion#omni'
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'dbui',
  callback = function()
    vim.api.nvim_create_autocmd('CursorMoved', {
      buffer = 0,
      callback = function()
        vim.cmd 'redraw!'
      end,
    })
    vim.keymap.set('n', '<c-n>', 'j', { buffer = 0 })
    vim.keymap.set('n', '<cr>', 'j', { buffer = 0 })
  end,
})

vim.keymap.set('n', '<leader>q', require('smart_tabs').cycle_dbui_tab)
