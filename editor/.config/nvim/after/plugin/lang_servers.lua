vim.lsp.enable(require('config').get_lsp_names())

-- Diagnostics UI config
vim.diagnostic.config {
  virtual_text = {
    spacing = 4,
    prefix = '●',
    source = 'if_many',
  },
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
  },
}

vim.lsp.config('roslyn', {
  cmd = {
    'dotnet',
    vim.fs.joinpath(
      vim.fn.expand '~/.local/share/roslyn',
      'content',
      'LanguageServer',
      'neutral',
      'Microsoft.CodeAnalysis.LanguageServer.dll'
    ),
    '--logLevel',
    'Information',
    '--extensionLogDirectory',
    vim.fs.joinpath(vim.fn.stdpath 'cache', 'roslyn_ls', 'logs'),
    '--stdio',
  },
})

require('roslyn').setup {}
