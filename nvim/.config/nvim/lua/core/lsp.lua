local servers = {
  'lua_ls',
  'ts_ls',
  'pyright',
  'jsonls',
  'yamlls',
  'taplo',
  'marksman',
  'tailwindcss',
}

-- Global LSP configuration
vim.lsp.config('*', {
  capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), {
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
          insertReplaceSupport = false,
        },
      },
    },
  }),
  flags = {
    allow_incremental_sync = true,
    debounce_text_changes = 150,
  },
})

-- Enable servers (configs will be loaded from lsp/ directory automatically)
for _, server in ipairs(servers) do
  vim.lsp.enable(server)
end

-- LSP Diagnostics configuration
vim.diagnostic.config {
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚',
      [vim.diagnostic.severity.WARN] = '󰀪',
      [vim.diagnostic.severity.HINT] = '󰌶',
      [vim.diagnostic.severity.INFO] = '󰋽',
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    focusable = false,
    style = 'minimal',
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
  },
}

-- Set up keymaps and autocommands
autocmd {
  'LspAttach',
  'LanguageServer',
  function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      keymap {
        buffer = args.buf,
        key { 'Code Definition', vim.lsp.buf.definition },
        key { 'Code Declaration', vim.lsp.buf.declaration },
        key { 'Code Type', vim.lsp.buf.type_definition },
        key { 'Code References', vim.lsp.buf.references },
        key { 'Code Implementation', vim.lsp.buf.implementation },
        key { 'Code Suggestions', vim.lsp.buf.code_action },
        key { 'Code Format', function() require('conform').format { async = true, lsp_fallback = true } end },
        key { 'signature', fn { vim.lsp.buf.signature_help, { border = 'rounded' } } },
        insert { 'signature', fn { vim.lsp.buf.signature_help, { border = 'rounded' } } },
      }
      -- Enable completion triggered by <c-x><c-o>
      vim.bo[args.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    end
  end,
}
