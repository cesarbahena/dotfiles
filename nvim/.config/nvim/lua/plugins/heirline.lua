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
    
    -- Helper function to get all flag levels for a formatter
    local function get_formatter_flag_levels(formatter_name)
      local flag_levels = {}
      
      if formatter_name == 'prettier' then
        -- Check for .prettierrc, .prettierrc.json, package.json
        local config = nil
        local config_files = { '.prettierrc', '.prettierrc.json' }
        for _, config_file in ipairs(config_files) do
          if vim.fn.filereadable(config_file) == 1 then
            local content = vim.fn.readfile(config_file)
            if #content > 0 then
              local ok, parsed = pcall(vim.json.decode, table.concat(content, '\n'))
              if ok then config = parsed; break end
            end
          end
        end
        
        if not config and vim.fn.filereadable('package.json') == 1 then
          local content = vim.fn.readfile('package.json')
          if #content > 0 then
            local ok, pkg = pcall(vim.json.decode, table.concat(content, '\n'))
            if ok and pkg.prettier then config = pkg.prettier end
          end
        end
        
        if config then
          -- Level 1: Full flags
          local full_flags = {}
          if config.singleQuote then table.insert(full_flags, '--single-quote') end
          if config.tabWidth then table.insert(full_flags, '--tab-width=' .. config.tabWidth) end
          if config.printWidth then table.insert(full_flags, '--print-width=' .. config.printWidth) end
          if config.semi == false then table.insert(full_flags, '--no-semi') end
          if config.trailingComma and config.trailingComma ~= 'none' then 
            table.insert(full_flags, '--trailing-comma=' .. config.trailingComma) 
          end
          if config.useTabs then table.insert(full_flags, '--use-tabs') end
          
          -- Level 2: Abbreviated flags
          local abbrev_flags = {}
          if config.singleQuote then table.insert(abbrev_flags, '-sq') end
          if config.tabWidth then table.insert(abbrev_flags, '-tw=' .. config.tabWidth) end
          if config.printWidth then table.insert(abbrev_flags, '-pw=' .. config.printWidth) end
          if config.semi == false then table.insert(abbrev_flags, '-ns') end
          if config.trailingComma and config.trailingComma ~= 'none' then 
            table.insert(abbrev_flags, '-tc=' .. config.trailingComma:sub(1,2)) 
          end
          if config.useTabs then table.insert(abbrev_flags, '-ut') end
          
          -- Level 3: Single letters
          local compact_letters = {}
          if config.singleQuote then table.insert(compact_letters, 's') end
          if config.printWidth then table.insert(compact_letters, 'p') end
          if config.tabWidth then table.insert(compact_letters, 't') end
          if config.trailingComma and config.trailingComma ~= 'none' then table.insert(compact_letters, 'c') end
          if config.semi == false then table.insert(compact_letters, 'n') end
          if config.useTabs then table.insert(compact_letters, 'T') end
          
          flag_levels = {
            table.concat(full_flags, ' '),
            table.concat(abbrev_flags, ' '),
            #compact_letters > 0 and ('-' .. table.concat(compact_letters, '')) or ''
          }
        end
        
      elseif formatter_name == 'stylua' then
        local config_files = { 'stylua.toml', '.stylua.toml' }
        for _, config_file in ipairs(config_files) do
          if vim.fn.filereadable(config_file) == 1 then
            local content = vim.fn.readfile(config_file)
            local full_flags = {}
            local abbrev_flags = {}
            local compact_letters = {}
            
            for _, line in ipairs(content) do
              local trimmed = line:match('^%s*(.-)%s*$')
              if trimmed and not trimmed:match('^#') then
                if trimmed:match('indent_width%s*=%s*(%d+)') then
                  local width = trimmed:match('indent_width%s*=%s*(%d+)')
                  table.insert(full_flags, '--indent-width=' .. width)
                  table.insert(abbrev_flags, '-iw=' .. width)
                  table.insert(compact_letters, 'i')
                elseif trimmed:match('quote_style%s*=%s*"([^"]+)"') then
                  local style = trimmed:match('quote_style%s*=%s*"([^"]+)"')
                  table.insert(full_flags, '--quote-style=' .. style)
                  table.insert(abbrev_flags, '-qs=' .. style:sub(1,2))
                  table.insert(compact_letters, 'q')
                elseif trimmed:match('column_width%s*=%s*(%d+)') then
                  local width = trimmed:match('column_width%s*=%s*(%d+)')
                  table.insert(full_flags, '--column-width=' .. width)
                  table.insert(abbrev_flags, '-cw=' .. width)
                  table.insert(compact_letters, 'c')
                elseif trimmed:match('indent_type%s*=%s*"([^"]+)"') then
                  local indent_type = trimmed:match('indent_type%s*=%s*"([^"]+)"')
                  table.insert(full_flags, '--indent-type=' .. indent_type)
                  table.insert(abbrev_flags, '-it=' .. indent_type:sub(1,2))
                  table.insert(compact_letters, 't')
                end
              end
            end
            
            flag_levels = {
              table.concat(full_flags, ' '),
              table.concat(abbrev_flags, ' '),
              #compact_letters > 0 and ('-' .. table.concat(compact_letters, '')) or ''
            }
            break
          end
        end
      end
      
      return flag_levels
    end
    
    -- Helper function to get best flag level that fits in max_width
    local function get_formatter_flags_progressive(formatter_name, max_width)
      local flag_levels = get_formatter_flag_levels(formatter_name)
      
      -- Find the longest level that fits within max_width
      for _, level in ipairs(flag_levels) do
        if #level <= max_width then
          return level
        end
      end
      
      return flag_levels[#flag_levels] or '' -- Return most compact or empty
    end

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
        
        -- Check for conform.nvim formatters with config flags
        local ok, conform = pcall(require, 'conform')
        if ok then
          local formatters = conform.list_formatters(0)
          
          -- Calculate actual width of other components dynamically
          local total_width = vim.o.columns
          
          -- Calculate actual component widths
          local working_dir_width = #vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
          local branch_width = 0
          if vim.fn.system('git rev-parse --is-inside-work-tree 2>/dev/null'):match 'true' then
            local branch = vim.fn.system('git branch --show-current 2>/dev/null'):gsub('\n', '')
            branch_width = #(' on ' .. branch .. ' ')
          end
          local git_status_width = 10
          
          -- LSP server width
          local lsp_width = 6 -- "  nvim" default
          local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
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
              lsp_width = #('  ' .. client.name)
              break
            end
          end
          
          -- Harpoon width (calculate current harpoon display)
          local harpoon_width = 0
          local harpoon = require 'harpoon'
          local marks = harpoon:list().items
          if #marks > 0 then
            local current_file_path = vim.fn.expand '%:p:.'
            local harpoon_total_length = 0
            for _, item in ipairs(marks) do
              local filename = vim.fn.fnamemodify(item.value, ':t'):gsub('%..*', '')
              harpoon_total_length = harpoon_total_length + #filename + 4
            end
            local harpoon_use_compact = harpoon_total_length > (vim.o.columns * 0.4) or #marks > 4
            if harpoon_use_compact then
              harpoon_width = 2 + #marks -- " -" + letters
            else
              harpoon_width = harpoon_total_length
            end
          end
          
          -- Right side width (icon + filename)
          local rightmost_win = vim.api.nvim_get_current_win() -- simplified for calculation
          local buf = vim.api.nvim_win_get_buf(rightmost_win)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':t')
          local right_side_width = 2 + #(filename ~= '' and filename or '[No Name]') -- icon + filename
          
          -- Progressive compression with real space budget
          -- Calculate actual available space
          local used_width = working_dir_width + branch_width + git_status_width + lsp_width + harpoon_width + right_side_width
          local space_budget = total_width - used_width - 5 -- Use real remaining space
          local space_used = 0
          
          for i, formatter in ipairs(formatters) do
            if formatter.available then
              local formatter_name = formatter.name
              local flag_levels = get_formatter_flag_levels(formatter_name)
              
              local chosen_flags = ''
              local space_remaining = space_budget - space_used
              local separator_cost = (#result > 0) and 3 or 0 -- " | "
              
              -- Try each level to see what fits
              for j, level in ipairs(flag_levels) do
                local full_text = formatter_name .. (level ~= '' and (' ' .. level) or '')
                local total_cost = #full_text + separator_cost
                
                if total_cost <= space_remaining then
                  chosen_flags = level
                  space_used = space_used + total_cost
                  break
                end
              end
              
              local formatter_str = formatter_name .. (chosen_flags ~= '' and (' ' .. chosen_flags) or '')
              table.insert(result, formatter_str)
            end
          end
        end
        
        if #result == 0 then
          return ''
        end
        
        local full_text = ' | ' .. table.concat(result, ' | ')
        return full_text
      end,
      hl = { fg = '#555555' },
    }

    local HarpoonMarks = {
      provider = function()
        local harpoon = require 'harpoon'
        local marks = harpoon:list().items
        local current_file_path = vim.fn.expand '%:p:.'
        local result = {}

        -- Check if we should use compact mode (when there are many marks or long names)
        local total_length = 0
        for _, item in ipairs(marks) do
          local filename = vim.fn.fnamemodify(item.value, ':t'):gsub('%..*', '')
          total_length = total_length + #filename + 4 -- +4 for " -t " or " --"
        end
        
        local use_compact = total_length > (vim.o.columns * 0.4) or #marks > 4

        if use_compact then
          -- Compact mode: -Abc (capital for current, lowercase for others)
          local letters = {}
          for _, item in ipairs(marks) do
            local first_letter = vim.fn.fnamemodify(item.value, ':t'):sub(1,1)
            if item.value == current_file_path then
              table.insert(letters, first_letter:upper()) -- Capital for current
            else
              table.insert(letters, first_letter:lower()) -- Lowercase for others
            end
          end
          return ' -' .. table.concat(letters, '')
        else
          -- Full mode: -t filename --filename
          for _, item in ipairs(marks) do
            local filename = vim.fn.fnamemodify(item.value, ':t'):gsub('%..*', '')
            if item.value == current_file_path then
              table.insert(result, ' -t ' .. filename) -- Active: -t filename
            else
              table.insert(result, ' --' .. filename) -- Inactive: --filename
            end
          end
          return table.concat(result, '')
        end
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
    
    -- Left side components 
    local LeftSide = {
      WorkingDir,
      GitBranch,
      GitStatus,
      LspServer,
      HarpoonMarks,
      LintersFormatters,
    }

    -- Setup heirline with complete tabline and statusline
    heirline.setup {
      statusline = {
        StatusAlign,
        Diagnostics,
      },
      tabline = {
        LeftSide,
        Align,
        RightmostIcon,
        RightmostFilename,
      },
    }
  end,
}

