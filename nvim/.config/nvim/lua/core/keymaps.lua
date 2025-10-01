keymap {
  motion { 'Next line', "v:count == 0 ? 'gj' : 'j'", expr = true, silent = true },
  motion { 'next page', '<C-d>zz' },
  motion { 'prEv line', "v:count == 0 ? 'gk' : 'k'", expr = true, silent = true },
  motion { 'prev page', '<C-u>zz' },
  motion { 'prev word', 'b' },
  motion { 'end of word', 'e' },
  motion { 'move left', 'h' },
  motion { 'move right', 'l' },
  motion { 'eOl', '$' },
  motion { 'beginning of line', '^' },
  motion { 'next whiteSPACE', 'W' },
  motion { 'prev whitespace', 'B' },
  key { 'Quit!', cmd 'q!' },
  key { 'Replace', 'r' },
  key { 'Delete character', [["_x]], details = '(no yank)' },
  key { 'Find', '/' },
  key { 'next match', 'n' },
  key { 'add argument', fn 'actions.treesitter.add_argument' },
  key { 'swapcase', '~' },

  auto_select { 'Substitute', [["_c]] },
  auto_select { 'Command line mode', ':' },
  key { 'execute command', '<cr>', mode = 'c' },
  key { 'literal ;', ';', mode = 'c' },

  key { 'Yank line', 'yy' },
  key { 'copy down', 'Yp' },
  key {
    'Unundo',
    fn {
      when = { vim.fn.undotree, at = 'seq_cur', lt = { vim.fn.undotree, at = 'seq_last' } },
      feed '<c-r>',
      or_else = feed '.',
    },
  },
  -- key { "Insert comma at the end", "mzA,<Esc>`z" },
  -- key { "Insert semicolon at the end", "mzA;<Esc>`z" },
  -- key { "Delete comma or semicolon at the end", "mz$x`z" },
  key { 'Join/Merge lines (pretty)', 'mzJ`z' },
  key { 'Join/Merge lines (raw)', 'mzgJ`z' },
  key { 'Insert mode', fn 'actions.insert_mode_indent_blankline', expr = true, details = '(indent blankline)' },
  key {
    'Delete line ',
    fn 'actions.delete_line_no_yank_blankline',
    expr = true,
    details = [[(don't yank blankline)]],
  },
  key { 'indent', '>>' },
  key { 'deindent', '<<' },
  key { 'open Line below', 'o' },
  key { 'open Line above', 'O' },
  key { 'add Line below', 'o<esc>' },
  key { 'add Line above', 'O<esc>' },
  key { 'Toggle macro recording', fn 'actions.toggle_macro_recording' },
  key { 'Repeat macro', '@q' },

  on_selection { 'Yank', 'y`>' },
  on_selection { 'indent', '>gv' },
  on_selection { 'deindent', '<gv' },
  on_selection { 'Uppercase', 'U' },
  on_selection { 'Lowercase', 'u' },
  on_selection { 'Move line down', ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv" },
  on_selection { 'Move line up', ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv" },
  on_selection { 'Change visual mode', fn 'actions.change_visual_mode', expr = true },
  on_selection { 'escape to normal mode', '<Esc>' },
  key {
    'escape to normal mode',
    '<c-\\><c-n>?><cr>2l',
    mode = 't',
  },
  key { 'refresh file', cmd 'e!' },

  insert { 'Comma with auto undo breakpoints', ',<C-g>u' },
  insert { 'Semicolon with auto undo breakpoints', ';<C-g>u' },
  insert { 'Dot with auto undo breakpoints', '.<C-g>u' },
  insert { 'escape to normal mode', fn 'actions.treesitter.clean_exit' },
  insert { 'one of', '<c-o>' },

  key { 'Move line down', cmd [[execute 'move .+' . v:count1]] .. '==' },
  key { 'Move line up', cmd [[execute 'move .-' . (v:count1 + 1)]] .. '==' },
  key { 'hover', fn 'actions.hover_overload.hover_handler' },

  motion { '1', '1' },
  motion { '2', '2' },
  motion { '3', '3' },
  motion { '4', '4' },
  motion { '5', '5' },
  motion { '6', '6' },
  motion { '7', '7' },
  motion { '8', '8' },
  motion { '9', '9' },
  motion { '0', '0' },

  key {
    'hover 2',
    proc {
      fn {
        when = { fn 'dap.session', ne = nil },
        fn {
          when = { 'ft', in_this = 'buffer', ne = 'dap-float' },
          fn { 'dap.ui.widgets.hover', nil, { border = 'rounded' } },
        },
      },

      fn {
        -- when = fn 'utils.is_diagnostic',
        when = require('utils').is_diagnostic,
        vim.diagnostic.open_float,
      },
    },
  },
}

-- Setup numeric keymaps
-- require('utils.numeric_keymaps').setup()

local mappings_to_disable = {
  x = {
    'u',
    'U',
  },
}

for mode, keys in pairs(mappings_to_disable) do
  for _, key in ipairs(keys) do
    vim.keymap.set(mode, key, '<nop>')
  end
end

-- Conditional keymap using fn in_any
vim.keymap.set(
  'n',
  '<leader>g1',
  fn {
    when = { 'gitsigns_preview', eq = 'blame', in_any = 'window' },
    fn 'gitsigns.blame',
    or_else = proc {
      fn { 'gitsigns.blame_line', { full = true } },
      fn { vim.cmd, 'wincmd p' },
    },
  }
)

vim.keymap.set(
  'n',
  'g0',
  fn {
    when = { fn 'gitsigns.get_actions', contains = 'stage_hunk' },
    fn 'gitsigns.preview_hunk_inline',
    or_else = fn { 'gitsigns.blame_line', { full = true } },
  }
)
