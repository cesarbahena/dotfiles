-- Pyright for type checking and hover documentation
-- Works alongside Ruff for linting/formatting
return {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'pyrightconfig.json', '.git' },
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'openFilesOnly', -- or 'workspace' for full project analysis
        typeCheckingMode = 'basic', -- 'off', 'basic', or 'strict'
      },
    },
  },
}
