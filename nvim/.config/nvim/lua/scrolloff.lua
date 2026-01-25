local M = {}

local map = vim.keymap.set

function M.no_scrolloff(motion, schedule_restore)
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

function M.set_sensible_kemaps()
  map('n', '<C-d>', '<C-d>zz')
  map('n', '<C-u>', '<C-u>zz')
  map('n', 'n', 'nzz')
  map('n', 'N', 'Nzz')
  map('n', 'j', function()
    if vim.v.count > 0 then
      M.no_scrolloff(vim.v.count .. 'j')()
    else
      vim.cmd 'normal! gj'
    end
  end)

  map('n', 'k', function()
    if vim.v.count > 0 then
      M.no_scrolloff(vim.v.count .. 'k')()
    else
      vim.cmd 'normal! gk'
    end
  end)

  for _, key in ipairs { 'zt', 'zb', 'zz' } do
    map('n', key, M.no_scrolloff(key, true)) --delayed restore
  end

  for _, key in ipairs { 'H', 'M', 'L' } do
    map('n', key, M.no_scrolloff(key))
  end

  map('n', 'G', function()
    M.no_scrolloff((vim.v.count > 0 and vim.v.count or '') .. 'G')()
  end)
end

return M
