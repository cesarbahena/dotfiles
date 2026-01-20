local dap = require 'dap'
local map = vim.keymap.set
local q = { silent = true }

dap.adapters.python = {
  type = 'executable',
  command = 'python',
  args = { '-m', 'debugpy.adapter' },
}

dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = 'Launch file',
    program = '${file}',
    pythonPath = function()
      return vim.fn.exepath 'python'
    end,
  },
}

map('n', '<F5>', dap.continue, q)
map('n', '<F10>', dap.step_over, q)
map('n', '<F11>', dap.step_into, q)
map('n', '<F12>', dap.step_out, q)
map('n', '<leader>b', dap.toggle_breakpoint, q)
map('n', '<leader>B', function()
  dap.set_breakpoint(vim.fn.input 'Condition: ')
end, q)
map('n', '<leader>dr', dap.repl.toggle, q)
