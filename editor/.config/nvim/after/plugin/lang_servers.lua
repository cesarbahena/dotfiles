local config = require 'config'

vim.lsp.enable(vim.tbl_map(function(lsp) return lsp.name end, config.lsps))
