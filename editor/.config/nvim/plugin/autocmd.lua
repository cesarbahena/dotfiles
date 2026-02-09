au = vim.api.nvim_create_autocmd

au('ColorScheme', { callback = require('hl_groups').apply_all })

au({ 'ModeChanged', 'CursorMoved', 'CursorMovedI' }, {
  callback = function()
    vim.cmd('redrawstatus')
  end,
})

au({ 'BufEnter', 'DirChanged' }, {
  callback = function()
    vim.b.git_branch = nil
  end,
})
