local function cwd_len()
  local path = vim.fn.getcwd()
  local home = vim.env.HOME
  if path:sub(1, #home) == home then
    path = '~' .. path:sub(#home + 1)
  end
  return vim.fn.strdisplaywidth(path) + 1
end

require('noice').setup {
  cmdline = {
    view = 'cmdline',
    format = {
      cmdline = { icon = '$', icon_hl_group = 'MyGreen' },
      search_down = { icon = '/', icon_hl_group = 'MyGreen' },
      search_up = { icon = '?', icon_hl_group = 'MyGreen' },
      filter = { icon = '!', icon_hl_group = 'MyGreen' },
      lua = { icon = '>', icon_hl_group = 'MyGreen' },
      help = { icon = 'Æ', icon_hl_group = 'MyGreen' },
    },
  },
  views = {
    cmdline = {
      position = {
        row = 0,
        col = cwd_len(),
      },
      size = {
        width = vim.o.columns - cwd_len(),
      },
    },
  },
  presets = {
    long_message_to_split = true,
    lsp_doc_border = true,
  },
  routes = {
    {
      filter = {
        event = 'msg_show',
        kind = 'search_count',
      },
      opts = { skip = true },
    },
  },
}
