vim.lsp.enable {
  'lua_ls',
  'pyright',
  'ts_ls',
  'intelephense',
  'rust_analyzer',
  'jdtls',
  'jsonls',
  'yamlls',
  'taplo',
  'bashls',
  'marksman',
}

-- vim.api.nvim_create_autocmd('LspAttach', {
--   callback = function(args)
--     local client = vim.lsp.get_client_by_id(args.data.client_id)
--     if client.name == 'lua_ls' then -- use stylua instead
--       client.server_capabilities.documentFormattingProvider = false
--     end
--   end,
-- })
--
-- vim.api.nvim_create_autocmd('BufWritePre', {
--   pattern = '*.lua',
--   callback = function()
--     local view = vim.fn.winsaveview()
--     local buf_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
--     local result = vim.system({ 'stylua', '--search-parent-directories', '-' }, { stdin = buf_content }):wait()
--     if result.code == 0 then
--       vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(result.stdout, '\n', { plain = true, trimempty = true }))
--       vim.fn.winrestview(view)
--     end
--   end,
-- })
