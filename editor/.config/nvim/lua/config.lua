local M = {}

M.lsps = {
  { name = 'lua_ls', filetypes = { 'lua' } },
  { name = 'pyright', filetypes = { 'python' } },
  { name = 'ts_ls', filetypes = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' } },
  { name = 'gopls', filetypes = { 'go' } },
  { name = 'rust_analyzer', filetypes = { 'rust' } },
  { name = 'clangd', filetypes = { 'c', 'cpp' } },
  { name = 'jdtls', filetypes = { 'java' } },
  { name = 'jsonls', filetypes = { 'json' } },
  { name = 'yamlls', filetypes = { 'yaml' } },
  { name = 'taplo', filetypes = { 'toml' } },
  { name = 'bashls', filetypes = { 'bash' } },
  { name = 'marksman', filetypes = { 'markdown' } },
  { name = 'intelephense', filetypes = { 'php' } },
}

M.formatters_by_ft = {
  lua = { 'stylua' },
  python = { 'ruff_format', 'ruff_organize_imports' },
  go = { 'goimports', 'gofumpt' },
  typescript = { 'prettier' },
  typescriptreact = { 'prettier' },
  javascript = { 'prettier' },
  javascriptreact = { 'prettier' },
  json = { 'prettier' },
  yaml = { 'prettier' },
  toml = { 'taplo' },
  markdown = { 'prettier' },
  html = { 'prettier' },
  css = { 'prettier' },
  scss = { 'prettier' },
  vue = { 'prettier' },
  java = { 'google-java-format' },
}

M.lsp_map = {
  lua = { cmd = 'lua-language-server', name = 'lua_ls' },
  python = { cmd = 'pyright', name = 'pyright' },
  javascript = { cmd = 'typescript-language-server', name = 'ts_ls' },
  typescript = { cmd = 'typescript-language-server', name = 'ts_ls' },
  go = { cmd = 'gopls', name = 'gopls' },
  rust = { cmd = 'rust-analyzer', name = 'rust_analyzer' },
  c = { cmd = 'clangd', name = 'clangd' },
  cpp = { cmd = 'clangd', name = 'clangd' },
}

M.formatters = {
  lua = 'stylua',
  python = 'ruff_format',
  javascript = 'prettier',
  typescript = 'prettier',
  go = 'goimports',
  rust = 'rustfmt',
}

return M
