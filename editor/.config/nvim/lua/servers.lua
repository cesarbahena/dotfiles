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
    local view = vim.fn.winsaveview()
    local ok = pcall(vim.cmd, 'silent %!stylua --search-parent-directories -')
    if ok then
      vim.fn.winrestview(view)
    end
  end,
})
