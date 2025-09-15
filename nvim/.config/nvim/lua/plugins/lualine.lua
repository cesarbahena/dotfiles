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
  lazy = false,
  dependencies = { 'echasnovski/mini.icons' },
  opts = {
    options = {
      theme = minimal_theme,
      component_separators = '',
      section_separators = '',
      globalstatus = true,
      disabled_filetypes = {
        winbar = { 'dap-repl' },
      },
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
            -- Find the top-right window (same logic as incline)
            local current_tab = vim.api.nvim_get_current_tabpage()
            local wins_in_tab = vim.api.nvim_tabpage_list_wins(current_tab)
            
            -- Filter out floating windows
            local normal_wins = {}
            for _, w in ipairs(wins_in_tab) do
              local config = vim.api.nvim_win_get_config(w)
              if config.relative == '' and vim.api.nvim_win_is_valid(w) then 
                table.insert(normal_wins, w) 
              end
            end
            
            -- If no normal windows, don't show anything
            if #normal_wins == 0 then return '' end
            
            local function get_file_display(buf)
              local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':t')
              if filename == '' then filename = '[No Name]' end

              -- Get icon using mini.icons
              local ft_icon = require('mini.icons').get('file', filename)
              
              return (ft_icon and (ft_icon .. ' ') or '') .. filename
            end

            -- If only one window, show its info
            if #normal_wins == 1 then
              return get_file_display(vim.api.nvim_win_get_buf(normal_wins[1]))
            end

            -- Find the rightmost window in the top row
            local top_right_window = nil
            local rightmost_col_in_top_row = -1
            local top_row = math.huge
            
            -- First find what the top row is
            for _, w in ipairs(normal_wins) do
              local pos = vim.api.nvim_win_get_position(w)
              local row = pos[1]
              if row < top_row then
                top_row = row
              end
            end
            
            -- Then find the rightmost window in that top row
            for _, w in ipairs(normal_wins) do
              local pos = vim.api.nvim_win_get_position(w)
              local col = pos[2]
              local row = pos[1]
              if row == top_row and col > rightmost_col_in_top_row then
                rightmost_col_in_top_row = col
                top_right_window = w
              end
            end

            if not top_right_window then return '' end

            -- Get buffer info for the top-right window
            return get_file_display(vim.api.nvim_win_get_buf(top_right_window))
          end,
          color = { fg = '#ffffff' },
          padding = { left = 1, right = 1 },
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
