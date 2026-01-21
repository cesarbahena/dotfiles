local map = vim.keymap.set
local q = { silent = true }

vim.g.mapleader = ' '

local function no_scrolloff(motion, schedule_restore)
  return function()
    vim.o.scrolloff = 0
    vim.cmd('normal! ' .. motion)
    if schedule_restore then
      vim.schedule(function()
        vim.o.scrolloff = 8
      end)
    else
      vim.o.scrolloff = 8
    end
  end
end

map('n', 'j', function()
  if vim.v.count > 0 then
    no_scrolloff(vim.v.count .. 'j')()
  else
    vim.cmd 'normal! gj'
  end
end)

map('n', 'k', function()
  if vim.v.count > 0 then
    no_scrolloff(vim.v.count .. 'k')()
  else
    vim.cmd 'normal! gk'
  end
end)

for _, key in ipairs { 'zt', 'zb', 'zz' } do
  map('n', key, no_scrolloff(key, true)) --delayed restore
end

for _, key in ipairs { 'H', 'M', 'L' } do
  map('n', key, no_scrolloff(key))
end

map('n', 'G', function()
  no_scrolloff((vim.v.count > 0 and vim.v.count or '') .. 'G')()
end)

map('c', ';', function()
  local cmd = vim.fn.getcmdline()
  local pos = vim.fn.getcmdpos()
  if pos > 1 and cmd:sub(pos - 1, pos - 1) == '\\' then
    return '\b;' -- backspace to remove \, then insert literal ;
  else
    return '<CR>'
  end
end, { expr = true })

map('n', 'Q', function()
  local count = vim.v.count > 0 and vim.v.count or 1
  for _ = 1, count do
    if not pcall(vim.cmd, 'normal! @@') then
      pcall(vim.cmd, 'normal! @q')
    end
  end
end, q)

map('c', '<c-s>', function()
  local line = vim.fn.getcmdline()
  local pos = vim.fn.getcmdpos()
  if pos <= 1 then
    return ''
  end
  local c = line:sub(pos - 1, pos - 1)
  return vim.api.nvim_replace_termcodes('\\1' .. c .. '<cr>', true, false, true)
end, { expr = true })

map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')
map('n', 'n', 'nzz')
map('n', 'N', 'Nzz')
map('i', ',', ',<C-g>u')
map('i', '.', '.<C-g>u')
map('i', ';', ';<C-g>u')
map('c', '<C-a>', '<Home>')
map('c', '<C-e>', '<End>')
map('x', '<', '<gv')
map('x', '>', '>gv')
map('n', 'Y', 'yyp')
map('n', '<', ',', q)
map('n', '>', 'j.', q)
map('n', ':', '@:', q)
map({ 'n', 'v' }, ';', ':')
map({ 'n', 'v' }, ',', ';', q)
map('n', '<leader>e', ':Ex<cr>')
map('n', '<leader>f', ':find **/*<left>')
map('x', 's', [[y:s/\(<C-R>=substitute(@", '\n$', '', '')<cr>\)/]])
