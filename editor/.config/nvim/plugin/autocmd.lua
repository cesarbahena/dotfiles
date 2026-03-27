au = vim.api.nvim_create_autocmd

au('ColorScheme', { callback = require('hl_groups').apply_all })
