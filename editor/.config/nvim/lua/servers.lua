vim.lsp.enable 'lua_ls'

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.name == 'lua_ls' then -- use stylua instead
      client.server_capabilities.documentFormattingProvider = false
    end
  end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.lua',
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local input = table.concat(lines, '\n')
    local output = vim.fn.system({ 'stylua', '--search-parent-directories', '-' }, input)
    if vim.v.shell_error == 0 then
      local formatted = vim.split(output, '\n')
      if formatted[#formatted] == '' then table.remove(formatted) end
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted)
    end
  end,
})
