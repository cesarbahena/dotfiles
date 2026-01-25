local map = vim.keymap.set
local q = { silent = true }

map('n', '>', 'j.', q) -- Repeat over multiple lines (S-.)

map('n', 'Q', function() -- Repeat macro
  local count = vim.v.count > 0 and vim.v.count or 1
  for _ = 1, count do
    if not pcall(vim.cmd, 'normal! @@') then
      -- if you forgot to call it (asuming its q)
      pcall(vim.cmd, 'normal! @q')
    end
  end
end, q)

-- Vim surround at home
map('x', 's', [[y:s/\(<C-R>=substitute(@", '\n$', '', '')<cr>\)/]])

-- Quick line move (use yank and paste for complex cases)
map('n', '<A-n>', ':m .+1<CR>==')
map('n', '<A-k>', ':m .-2<CR>==')

-- Cmdline mode
map({ 'n', 'x' }, ';', ':') -- ; faster than :
map({ 'n', 'x' }, ':', '@:', q) -- S-;

map('c', ';', function() -- smart ; also to execute
  local cmd = vim.fn.getcmdline()
  local pos = vim.fn.getcmdpos()
  if pos > 1 and cmd:sub(pos - 1, pos - 1) == '\\' then
    return '\b;' -- backspace to remove \, then insert literal ;
  else
    return '<CR>'
  end
end, { expr = true })

map('c', '<c-s>', function() -- to use with custom visual mode s
  local line = vim.fn.getcmdline()
  local pos = vim.fn.getcmdpos()
  if pos <= 1 then
    return ''
  end
  local c = line:sub(pos - 1, pos - 1)
  return vim.api.nvim_replace_termcodes('\\1' .. c .. '<cr>', true, false, true)
end, { expr = true })

-- But then we need to move ; to ,
map({ 'n', 'x' }, ',', ';', q)
map('n', '<', ',', q) -- and S-, for backwards

-- Sensible defaults
map('i', '<c-c>', '<esc>') -- Saves block mode edits
map('x', '<', '<gv')
map('x', '>', '>gv')
require('scrolloff').set_sensible_kemaps()

-- Undo breakpoints
map('i', ',', ',<C-g>u')
map('i', '.', '.<C-g>u')
map('i', ';', ';<C-g>u')

-- Fallbacks
map('n', '<leader>e', ':Ex<cr>') -- file explorer
map('n', '<leader>f', ':find **/*<left>') -- picker
