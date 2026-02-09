local M = {}

M.langs = {
  lua = {
    lsp = { 'lua_ls', 'lua-language-server' },
    fmt = { 'stylua' },
  },
  python = {
    lsp = { 'pyright' },
    fmt = { 'ruff_format', 'ruff_organize_imports' },
  },
  javascript = {
    lsp = { 'tsserver', 'typescript-language-server' },
    fmt = { 'prettier' },
  },
  typescript = {
    lsp = { 'tsserver', 'typescript-language-server' },
    fmt = { 'prettier' },
  },
  typescriptreact = {
    lsp = { 'tsserver', 'typescript-language-server' },
    fmt = { 'prettier' },
  },
  javascriptreact = {
    lsp = { 'tsserver', 'typescript-language-server' },
    fmt = { 'prettier' },
  },
  go = {
    lsp = { 'gopls' },
    fmt = { 'goimports', 'gofumpt' },
  },
  rust = {
    lsp = { 'rust_analyzer' },
    fmt = { 'rustfmt' },
  },
  c = {
    lsp = { 'clangd' },
    fmt = { 'clang-format' },
  },
  cpp = {
    lsp = { 'clangd' },
    fmt = { 'clang-format' },
  },
  java = {
    lsp = { 'jdtls' },
    fmt = { 'google-java-format' },
  },
  json = {
    lsp = { 'jsonls' },
    fmt = { 'prettier' },
  },
  yaml = {
    lsp = { 'yamlls' },
    fmt = { 'prettier' },
  },
  toml = {
    lsp = { 'taplo' },
    fmt = { 'taplo' },
  },
  markdown = {
    lsp = { 'marksman' },
    fmt = { 'prettier' },
  },
  html = {
    lsp = { 'nil' },
    fmt = { 'prettier' },
  },
  css = {
    lsp = { 'cssls' },
    fmt = { 'prettier' },
  },
  scss = {
    lsp = { 'cssls' },
    fmt = { 'prettier' },
  },
  vue = {
    lsp = { 'vuels' },
    fmt = { 'prettier' },
  },
  bash = {
    lsp = { 'bashls' },
    fmt = { 'shfmt' },
  },
  php = {
    lsp = { 'intelephense' },
    fmt = { 'phpbf', 'phpcbf' },
  },
  vim = {
    lsp = { 'vimls' },
    fmt = { 'vimfmt' },
  },
}

function M.get_lsp_names()
  local names = {}
  for _, cfg in pairs(M.langs) do
    table.insert(names, cfg.lsp[1])
  end
  return names
end

function M.get_lsp_config(ft)
  local cfg = M.langs[ft]
  if not cfg or not cfg.lsp then
    return nil
  end
  local name = cfg.lsp[1]
  local cmd = cfg.lsp[2] or name
  return { name = name, cmd = cmd }
end

function M.get_formatters(ft)
  local cfg = M.langs[ft]
  if not cfg or not cfg.fmt then
    return {}
  end
  return cfg.fmt
end

function M.get_formatters_by_ft()
  local by_ft = {}
  for ft, cfg in pairs(M.langs) do
    if cfg.fmt then
      by_ft[ft] = cfg.fmt
    end
  end
  return by_ft
end

return M
