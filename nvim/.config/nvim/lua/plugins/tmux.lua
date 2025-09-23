return {
  {
    'aserowy/tmux.nvim',
    keys = {
      key { 'left window', fn 'tmux.move_left', mode = { 'n', 't' } },
      key { 'right window', fn 'tmux.move_right', mode = { 'n', 't' } },
      -- I my config this overlaps with escape to normal mode in terminal
      key { 'top window', fn 'tmux.move_top', mode = 'n' },
      key { 'bottom window', fn 'tmux.move_bottom', mode = { 'n', 't' } },
      key { 'resize left', fn 'tmux.resize_left', mode = { 'n', 't' } },
      key { 'resize right', fn 'tmux.resize_right', mode = { 'n', 't' } },
      key { 'resize top', fn 'tmux.resize_top', mode = { 'n', 't' } },
      key { 'resize botom', fn 'tmux.resize_bottom', mode = { 'n', 't' } },
    },
    opts = {
      copy_sync = {
        enable = false,
      },
      navigation = {
        enable_default_keybindings = false,
        cycle_navigation = false,
      },
      resize = {
        enable_default_keybindings = false,
        resize_step_x = 5,
        resize_step_y = 5,
      },
    },
  },
}
