return {
  'mistweaverco/kulala.nvim',
  ft = 'http',
  keys = {
    auto_select { 'request pad', fn 'kulala.scratchpad' },
    key { 'Request Yank', fn 'kulala.copy', ft = 'http' },
    key { 'Request Paste', fn 'kulala.from_curl', ft = 'http' },
    key { 'next Request', fn 'kulala.jump_next', ft = 'http' },
    key { 'prev Request', fn 'kulala.jump_prev', ft = 'http' },
    key { 'clean', fn 'kulala.close', ft = 'http' },
    key { 'close Request', fn 'kulala.close' },
    key { 'redo', fn 'kulala.replay', ft = { 'json.kulala_ui' }, details = 'request' },
    auto_select { 'run request', fn 'kulala.run', ft = 'http' },
    key { 'Request Stats', fn 'kulala.show_stats' },
    key { 'Request Body/headers', fn 'kulala.toggle_view' },
  },
  opts = {
    ui = {
      split_direction = 'horizontal',
    },
  },
}
