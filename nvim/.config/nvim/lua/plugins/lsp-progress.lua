return {
  'linrongbin16/lsp-progress.nvim',
  config = function()
    require('lsp-progress').setup {
      spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
      spin_update_time = 100,
      decay = 700,
      series_format = function(title, message, percentage, done) return title end,
      client_format = function(client_name, spinner, series_messages)
        if #series_messages == 0 then return nil end
        return {
          name = client_name,
          body = spinner,
        }
      end,
      format = function(client_messages)
        if #client_messages > 0 then return client_messages[1].body end
        return ''
      end,
    }
  end,
}
