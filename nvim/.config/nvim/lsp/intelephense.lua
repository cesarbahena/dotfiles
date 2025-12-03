return {
  cmd = { 'intelephense', '--stdio' },
  filetypes = { 'php', 'blade' },
  init_options = {
    storagePath = vim.fn.stdpath('data') .. '/intelephense',
  },
  root_markers = { 'composer.json', '.git' },
  settings = {
    intelephense = {
      files = {
        maxSize = 10000000,
        associations = { '*.php' },
      },
      environment = {
        includePaths = { 'vendor' },
      },
    },
  },
}