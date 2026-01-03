return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  lazy = false,
  config = function()
    local harpoon = require 'harpoon'
    harpoon:setup()

    -- Trigger heirline update when harpoon list changes
    harpoon:extend {
      ADD = function() vim.api.nvim_exec_autocmds('BufEnter', {}) end,
      REMOVE = function() vim.api.nvim_exec_autocmds('BufEnter', {}) end,
      REORDER = function() vim.api.nvim_exec_autocmds('BufEnter', {}) end,
      LIST_CHANGE = function() vim.api.nvim_exec_autocmds('BufEnter', {}) end,
    }
  end,
  keys = {
    motion { 'harpoon 1', function() require('harpoon'):list():select(1) end },
    motion { 'harpoon 2', function() require('harpoon'):list():select(2) end },
    motion { 'harpoon 3', function() require('harpoon'):list():select(3) end },
    motion { 'harpoon 4', function() require('harpoon'):list():select(4) end },
    motion {
      'harpoon Menu',
      function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end,
    },
    motion {
      'harpoon Mark file',
      function() require('harpoon'):list():add() end,
    },
  },
}
