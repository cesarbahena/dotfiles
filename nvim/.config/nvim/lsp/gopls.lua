-- Official Go language server from Google
-- Built-in support for gofumpt formatting and import organization
return {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_markers = { 'go.work', 'go.mod', '.git' },
  settings = {
    gopls = {
      -- Code analyses
      analyses = {
        unusedparams = true,
        shadow = true,
      },
      staticcheck = true,

      -- Use gofumpt for stricter formatting (gopls built-in)
      gofumpt = true,

      -- Inlay hints
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },

      -- Code lenses
      codelenses = {
        gc_details = false,
        generate = true,
        regenerate_cgo = true,
        run_govulncheck = true,
        test = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
      },

      -- Semantic tokens
      semanticTokens = true,
    },
  },
}
