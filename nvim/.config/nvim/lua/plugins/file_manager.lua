return {
  'nvim-mini/mini.files',
  -- No need to copy this inside `setup()`. Will be used automatically.
  opts = {
    mappings = {
      close = 'q',
      go_in_plus = 'o',
      go_in = '<cr>',
      go_out = 'k',
      go_out_plus = '',
      mark_goto = "'",
      mark_set = 'm',
      reset = '<BS>',
      reveal_cwd = '@',
      show_help = 'g?',
      synchronize = 'w',
      trim_left = '<',
      trim_right = '>',
    },
    -- Customization of explorer windows
    windows = {
      -- Whether to show preview of file/directory under cursor
      preview = true,
    },
  },
  keys = {
    key {
      'file explorer',
      function() fn('mini.files.open', vim.fn.expand '%:p:h', true)() end,
    },
  },
}
