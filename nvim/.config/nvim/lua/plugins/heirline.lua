return {
  'rebelot/heirline.nvim',
  lazy = false,
  dependencies = { 'echasnovski/mini.icons' },
  config = function()
    require('mini.icons').mock_nvim_web_devicons()

    local heirline = require 'heirline'
    local utils = require 'heirline.utils'

    -- Define colors
    local colors = {
      bright_bg = '#313244',
      bright_fg = '#cdd6f4',
      red = '#f38ba8',
      dark_red = '#e6194b',
      green = '#a6e3a1',
      blue = '#89b4fa',
      gray = '#6c7086',
      orange = '#fab387',
      purple = '#cba6f7',
      cyan = '#94e2d5',
      diag_warn = '#ffd700',
      diag_error = '#ff6b6b',
      diag_hint = '#4169e1',
      diag_info = '#00ffff',
      git_del = '#f38ba8',
      git_add = '#a6e3a1',
      git_change = '#fab387',
    }

    -- CLI Theme Components
    local WorkingDir = {
      provider = function() return vim.fn.fnamemodify(vim.fn.getcwd(), ':~') end,
      hl = { fg = '#7E9CD8' },
    }

    local GitBranch = {
      condition = function() return vim.fn.system('git rev-parse --is-inside-work-tree 2>/dev/null'):match 'true' end,
      provider = function()
        local branch = vim.fn.system('git branch --show-current 2>/dev/null'):gsub('\n', '')
        return branch ~= '' and (' on ' .. branch .. ' ') or ''
      end,
      hl = { fg = '#957FB8' },
    }

    local GitStatus = {
      condition = function() return vim.fn.system('git rev-parse --is-inside-work-tree 2>/dev/null'):match 'true' end,
      provider = fn 'components.file_info.git_status',
      hl = { fg = '#E6C384', bold = true },
    }

    local LspServer = {
      provider = function()
        local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
        
        -- Filter for main language servers only
        local language_servers = {}
        local excluded = { 'copilot', 'efm', 'null-ls', 'conform' }
        
        for _, client in ipairs(buf_clients) do
          local is_excluded = false
          for _, excluded_name in ipairs(excluded) do
            if client.name:lower():find(excluded_name:lower()) then
              is_excluded = true
              break
            end
          end
          if not is_excluded then
            table.insert(language_servers, client)
          end
        end
        
        if #language_servers == 0 then
          return '  nvim'
        end
        
        -- Get the main LSP server (first language server)
        local client = language_servers[1]
        return '  ' .. client.name
      end,
      hl = { fg = '#DCD7BA' },
    }
    
    local LintersFormatters = {
      provider = function()
        local result = {}
        
        -- Check for LSP-based linters/formatters
        local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
        local lf_names = { 'efm', 'null-ls' }
        
        for _, client in ipairs(buf_clients) do
          for _, lf_name in ipairs(lf_names) do
            if client.name:lower():find(lf_name:lower()) then
              table.insert(result, client.name)
              break
            end
          end
        end
        
        -- Check for conform.nvim formatters
        local ok, conform = pcall(require, 'conform')
        if ok then
          local formatters = conform.list_formatters(0)
          for _, formatter in ipairs(formatters) do
            if formatter.available then
              table.insert(result, formatter.name)
            end
          end
        end
        
        if #result == 0 then
          return ''
        end
        
        return ' | ' .. table.concat(result, ' | ')
      end,
      hl = { fg = '#DCD7BA' },
    }

    local HarpoonMarks = {
      provider = function()
        local harpoon = require 'harpoon'
        local marks = harpoon:list().items
        local current_file_path = vim.fn.expand '%:p:.'
        local result = {}

        for _, item in ipairs(marks) do
          local filename = vim.fn.fnamemodify(item.value, ':t'):gsub('%..*', '')

          if item.value == current_file_path then
            table.insert(result, ' -t ' .. filename) -- Active: -t filename
          else
            table.insert(result, ' --' .. filename) -- Inactive: --filename
          end
        end

        return table.concat(result, '')
      end,
      hl = { fg = '#DCD7BA' },
    }

    -- Helper function to get rightmost window
    local function get_rightmost_window()
      local windows = vim.api.nvim_tabpage_list_wins(0)
      local normal_windows = {}
      for _, win in ipairs(windows) do
        if vim.api.nvim_win_get_config(win).relative == '' then table.insert(normal_windows, win) end
      end

      if #normal_windows == 0 then return vim.api.nvim_get_current_win() end

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

      return rightmost_win
    end

    local RightmostIcon = {
      provider = function()
        local rightmost_win = get_rightmost_window()
        local buf = vim.api.nvim_win_get_buf(rightmost_win)
        local filetype = vim.api.nvim_get_option_value('filetype', { buf = buf })
        local icon, hl = require('mini.icons').get('filetype', filetype)
        return icon
      end,
      hl = function()
        local rightmost_win = get_rightmost_window()
        local buf = vim.api.nvim_win_get_buf(rightmost_win)
        local filetype = vim.api.nvim_get_option_value('filetype', { buf = buf })
        local icon, hl_group = require('mini.icons').get('filetype', filetype)
        
        -- Get the color from the highlight group
        local hl_attrs = vim.api.nvim_get_hl(0, { name = hl_group })
        local color = hl_attrs.fg and string.format('#%06x', hl_attrs.fg) or '#C0C0C0'
        
        return { fg = color }
      end,
    }

    local RightmostFilename = {
      provider = function()
        local rightmost_win = get_rightmost_window()
        local buf = vim.api.nvim_win_get_buf(rightmost_win)
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':t')
        return filename ~= '' and (' ' .. filename) or ' [No Name]'
      end,
      hl = function()
        local rightmost_win = get_rightmost_window()
        local buf = vim.api.nvim_win_get_buf(rightmost_win)
        local filepath = vim.api.nvim_buf_get_name(buf)
        local modified = vim.api.nvim_get_option_value('modified', { buf = buf })

        local color = '#C0C0C0' -- default muted white for clean files
        local gui = nil

        if filepath ~= '' then
          local git_status = vim.fn.system('git status --porcelain ' .. vim.fn.shellescape(filepath) .. ' 2>/dev/null'):gsub('\n', '')
          
          -- Debug: show what git status returns
          -- vim.notify('File: ' .. vim.fn.fnamemodify(filepath, ':t') .. ' | Status: "' .. git_status .. '"')
          
          if git_status == '' then
            -- File is tracked and clean
            color = '#C0C0C0' -- muted white
          elseif git_status:match 'UU' or git_status:match 'AA' or git_status:match 'DD' then
            -- Merge conflicts - immediate attention needed
            color = '#f38ba8' -- red
          elseif git_status:match 'AU' or git_status:match 'UA' or git_status:match 'UD' or git_status:match 'DU' then
            -- Conflict states - immediate attention needed
            color = '#f38ba8' -- red
          elseif git_status:match '^%?%?' then
            -- File is untracked
            color = '#a6e3a1' -- green
          elseif git_status:match '[AM]' then
            -- Modified/added files
            color = '#fab387' -- orange
          else
            -- Unknown status, default to muted white
            color = '#C0C0C0' -- muted white
          end
        end

        if modified then 
          return { fg = color, italic = true }
        end

        return { fg = color }
      end,
    }

    -- Spacer to push rightmost components to the right
    local Align = { provider = '%=' }

    -- Statusline Components
    local Diagnostics = {
      condition = function() return #vim.diagnostic.get(0) > 0 end,
      static = {
        error_icon = ' ',
        warn_icon = ' ',
        info_icon = ' ',
        hint_icon = ' ',
      },
      provider = function(self)
        local count = {}
        local diagnostics = vim.diagnostic.get(0)

        for _, diagnostic in ipairs(diagnostics) do
          local severity = diagnostic.severity
          count[severity] = (count[severity] or 0) + 1
        end

        local result = {}
        if count[vim.diagnostic.severity.ERROR] then
          table.insert(result, self.error_icon .. count[vim.diagnostic.severity.ERROR])
        end
        if count[vim.diagnostic.severity.WARN] then
          table.insert(result, self.warn_icon .. count[vim.diagnostic.severity.WARN])
        end
        if count[vim.diagnostic.severity.INFO] then
          table.insert(result, self.info_icon .. count[vim.diagnostic.severity.INFO])
        end
        if count[vim.diagnostic.severity.HINT] then
          table.insert(result, self.hint_icon .. count[vim.diagnostic.severity.HINT])
        end

        return table.concat(result, ' ')
      end,
      hl = { fg = '#938AA9' },
    }

    -- Center diagnostics in statusline
    local StatusAlign = { provider = '%=' }

    -- Enable tabline
    vim.o.showtabline = 2 -- Always show tabline
    
    -- Setup heirline with complete tabline and statusline
    heirline.setup {
      statusline = {
        StatusAlign,
        Diagnostics,
      },
      tabline = {
        WorkingDir,
        GitBranch,
        GitStatus,
        LspServer,
        HarpoonMarks,
        LintersFormatters,
        Align,
        RightmostIcon,
        RightmostFilename,
      },
    }
  end,
}

