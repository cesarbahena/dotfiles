-- Native Ruff language server (replaces deprecated ruff-lsp)
-- Handles linting and can do formatting, but we defer formatting to conform
return {
  cmd = { 'ruff', 'server', '--preview' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
  init_options = {
    settings = {
      -- Ruff server settings
      lineLength = 88, -- Match black's default
      lint = {
        enable = true,
        select = { 'E', 'F', 'W', 'I', 'N' }, -- Enable specific rule categories
      },
      format = {
        preview = true,
      },
    },
  },
  -- Disable hover to let pyright handle documentation
  on_attach = function(client, bufnr)
    client.server_capabilities.hoverProvider = false
  end,
}
