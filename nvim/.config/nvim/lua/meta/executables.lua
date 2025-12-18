return {
  {
    'williamboman/mason.nvim',
    opts = {},
    build = ':MasonUpdate',
  },
  {
    'williamboman/mason-lspconfig.nvim',
    opts = {
      ensure_installed = {
        'lua_ls',
        'ts_ls',
        'ruff',
        'pyright',
        'intelephense',
        'rust_analyzer',
        'jsonls',
        'yamlls',
        'taplo',
        'marksman',
        'tailwindcss',
        'jdtls',
      },
    },
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    opts = {
      auto_update = true,
      debounce_hours = 24,
      ensure_installed = {
        'stylua',
        'prettier',
        'google-java-format',
      },
    },
  },
}
