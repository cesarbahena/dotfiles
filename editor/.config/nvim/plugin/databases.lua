vim.g.dbs = {
  test = 'postgres://postgres:password@localhost:5432/postgres',
}

vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_show_database_icon = 1
vim.g.db_ui_force_echo_notifications = 1
vim.g.db_ui_win_position = 'left'
vim.g.db_ui_winwidth = 40
vim.g.db_ui_auto_execute_table_helpers = 1
vim.g.db_ui_save_location = vim.fn.stdpath 'data' .. '/dadbod_ui'
vim.g.db_ui_use_nvim_notify = 1

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'sql', 'mysql', 'pgsql' },
  callback = function()
    vim.opt_local.omnifunc = 'vim_dadbod_completion#omni'
  end,
})

vim.keymap.set('n', '<leader>q', require('smart_tabs').cycle_dbui_tab)
