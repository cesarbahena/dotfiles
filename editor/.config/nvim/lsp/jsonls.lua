return {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  root_markers = { 'package.json', '.git' },
  single_file_support = true,
  settings = {
    json = {
      validate = { enable = true },
    },
  },
}