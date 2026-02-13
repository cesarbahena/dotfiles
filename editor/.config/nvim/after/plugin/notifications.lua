local function calc_cwd_col()
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
        col = calc_cwd_col(),
      },
      size = {
        width = vim.o.columns - calc_cwd_col(),
      },
    },
  },
}
