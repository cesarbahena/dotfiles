-- Minimal theme to fix component spacing
local minimal_theme = {
  normal = {
    c = { bg = 'NONE' },
    x = { bg = 'NONE' },
  },
  inactive = {
    c = { bg = 'NONE' },
    x = { bg = 'NONE' },
  },
}

-- Add custom colors to theme
minimal_theme.normal.StatuslineError = { fg = '#f38ba8', gui = 'bold' }
minimal_theme.inactive.StatuslineError = { fg = '#f38ba8' }

return {
  'nvim-lualine/lualine.nvim',
  enabled = false, -- Disabled in favor of heirline
  lazy = false,
  dependencies = { 'echasnovski/mini.icons' },
  config = function(_, opts)
    require('mini.icons').mock_nvim_web_devicons()
    require('lualine').setup(opts)
  end,
  opts = {
    options = {
      theme = minimal_theme,
      component_separators = '',
      section_separators = '',
      globalstatus = true,
    },
    tabline = {
      lualine_a = {
        {
          '%{fnamemodify(getcwd(), ":~")}',
          color = { fg = '#7FB4CA' },
          padding = { left = 0 },
        },
        {
          'branch',
          icon = 'on',
          color = { fg = '#938AA9' },
          padding = { left = 1, right = 0 },
        },
        {
          fn 'components.file_info.git_status',
          color = { fg = '#E6C384', gui = 'bold' },
        },
        {
          function()
            local mode = vim.fn.mode()
            local mode_map = {
              n = 'nvim',
              i = 'vi',
              v = 'vim',
              V = 'vim',
              ['\22'] = 'vim', -- visual block
              c = 'sh',
              s = 'sed',
              S = 'sed',
              ['\19'] = 'sed', -- select block
              R = 'nano',
              r = 'nano',
              ['!'] = 'bash',
              t = 'zsh',
            }
            return mode_map[mode] or 'nvim'
          end,
          color = { fg = '#666666' },
          padding = { left = 0, right = 0 },
        },
        {
          function()
            local harpoon = require 'harpoon'
            local marks = harpoon:list().items
            local current_file_path = vim.fn.expand '%:p:.'
            local result = {}

            for _, item in ipairs(marks) do
              local filename = vim.fn.fnamemodify(item.value, ':t'):gsub('%..*', '')

              if item.value == current_file_path then
                table.insert(result, '-t ' .. filename) -- Active: -t filename
              else
                table.insert(result, ' --' .. filename) -- Inactive: --filename
              end
            end

            return table.concat(result, ' ')
          end,
          color = { fg = '#666666' },
        },
      },
      lualine_z = {
        {
          function()
            local windows = vim.api.nvim_tabpage_list_wins(0)
            local normal_windows = {}
            for _, win in ipairs(windows) do
              if vim.api.nvim_win_get_config(win).relative == '' then table.insert(normal_windows, win) end
            end

            if #normal_windows == 0 then return require('mini.icons').get('filetype', vim.bo.filetype) end

            -- Get the rightmost window of the top row
            local top_row_y = vim.api.nvim_win_get_position(normal_windows[1])[1]
            local rightmost_win = normal_windows[1]
            local rightmost_x = vim.api.nvim_win_get_position(normal_windows[1])[2]

            for _, win in ipairs(normal_windows) do
              local pos = vim.api.nvim_win_get_position(win)
              if pos[1] == top_row_y and pos[2] > rightmost_x then
                rightmost_win = win
                rightmost_x = pos[2]
              end
            end

            local buf = vim.api.nvim_win_get_buf(rightmost_win)
            local filetype = vim.api.nvim_get_option_value('filetype', { buf = buf })
            local icon, hl = require('mini.icons').get('filetype', filetype)
            return icon
          end,
          padding = { right = 0 },
        },
        {
          function()
            local windows = vim.api.nvim_tabpage_list_wins(0)
            local normal_windows = {}
            for _, win in ipairs(windows) do
              if vim.api.nvim_win_get_config(win).relative == '' then table.insert(normal_windows, win) end
            end

            -- Get the rightmost window of the top row
            local top_row_y = vim.api.nvim_win_get_position(normal_windows[1])[1]
            local rightmost_win = normal_windows[1]
            local rightmost_x = vim.api.nvim_win_get_position(normal_windows[1])[2]

            for _, win in ipairs(normal_windows) do
              local pos = vim.api.nvim_win_get_position(win)
              if pos[1] == top_row_y and pos[2] > rightmost_x then
                rightmost_win = win
                rightmost_x = pos[2]
              end
            end

            local buf = vim.api.nvim_win_get_buf(rightmost_win)
            return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':t')
          end,
          padding = { left = 1 },
        },
      },
    },
    sections = {
      lualine_c = {
        '%=',
        {
          'diagnostics',
          sources = { 'nvim_workspace_diagnostic' },
          symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
        },
      },
      lualine_a = {},
      lualine_b = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
  },
}
