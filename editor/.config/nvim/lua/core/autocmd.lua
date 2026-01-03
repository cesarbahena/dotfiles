local auto_register = require 'utils.key_auto_register'

-- Key auto-registration autocommand
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = '*.lua',
  group = vim.api.nvim_create_augroup('KeyAutoRegister', { clear = true }),
  callback = function()
    local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
    local missing = auto_register.scan_for_missing_keys(content)

    if #missing > 0 then vim.schedule(function() auto_register.handle_missing_keys(missing) end) end
  end,
})
