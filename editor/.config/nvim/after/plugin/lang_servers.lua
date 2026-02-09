vim.lsp.enable(require('config').get_lsp_names())

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
