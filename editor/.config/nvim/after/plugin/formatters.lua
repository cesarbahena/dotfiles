local config = require 'config'

require('conform').setup {
  formatters_by_ft = config.get_formatters_by_ft(),
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}
