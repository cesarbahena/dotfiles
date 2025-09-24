return {
  {
    'rebelot/heirline.nvim',
    lazy = false,
    dependencies = { 'echasnovski/mini.icons', 'linrongbin16/lsp-progress.nvim' },
    config = function()
      fn 'mini.icons.mock_nvim_web_devicons'()

      -- Theme-aware color system
      local function get_theme_colors()
        local hl_groups = {
          'Normal',
          'Comment',
          'NonText',
          'Directory',
          'Statement',
          'ErrorMsg',
          'WarningMsg',
          'GitSignsAdd',
          'GitSignsChange',
        }

        local colors = {}
        for _, hl_group in ipairs(hl_groups) do
          local hl = fn { 'heirline.utils.get_highlight', hl_group }()
          if hl and hl.fg then
            colors[hl_group] = string.format('#%06x', hl.fg)
          end
        end
        return colors
      end

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
        init = function(self)
          local rightmost_win = get_rightmost_window()
          local buf = vim.api.nvim_win_get_buf(rightmost_win)
          local filetype = vim.api.nvim_get_option_value('filetype', { buf = buf })
          local icon, hl_group = require('mini.icons').get('filetype', filetype)

          self.icon = icon
          self.hl_group = hl_group
        end,
        provider = function(self) return self.icon end,
        hl = function(self)
          -- Get the color from the highlight group
          local hl_attrs = vim.api.nvim_get_hl(0, { name = self.hl_group })
          local color = hl_attrs.fg and string.format('#%06x', hl_attrs.fg) or 'NonText'

          return { fg = color }
        end,
        update = { 'BufEnter', 'FileType' },
      }

      local RightmostFilename = {
        init = function(self)
          local rightmost_win = get_rightmost_window()
          local buf = vim.api.nvim_win_get_buf(rightmost_win)
          self.filepath = vim.api.nvim_buf_get_name(buf)
          self.filename = vim.fn.fnamemodify(self.filepath, ':t')
          self.modified = vim.api.nvim_get_option_value('modified', { buf = buf })

          -- Compute git status color
          self.color = 'Normal' -- default for clean files

          if self.filepath ~= '' then
            local git_status = vim.fn
              .system('git status --porcelain ' .. vim.fn.shellescape(self.filepath) .. ' 2>/dev/null')
              :gsub('\n', '')

            if git_status == '' then
              -- File is tracked and clean
              self.color = 'Normal'
            elseif git_status:match 'UU' or git_status:match 'AA' or git_status:match 'DD' then
              -- Merge conflicts - immediate attention needed
              self.color = 'ErrorMsg'
            elseif git_status:match 'AU' or git_status:match 'UA' or git_status:match 'UD' or git_status:match 'DU' then
              -- Conflict states - immediate attention needed
              self.color = 'ErrorMsg'
            elseif git_status:match '^%?%?' then
              -- File is untracked
              self.color = 'GitSignsAdd'
            elseif git_status:match '[AM]' then
              -- Modified/added files
              self.color = 'GitSignsChange'
            else
              -- Unknown status, default to clean
              self.color = 'Normal'
            end
          end
        end,
        provider = function(self) return self.filename ~= '' and (' ' .. self.filename) or '' end,
        hl = function(self)
          local rightmost_win = get_rightmost_window()
          local buf = vim.api.nvim_win_get_buf(rightmost_win)
          local has_diagnostics = #vim.diagnostic.get(buf) > 0

          local hl_attrs = { fg = self.color }
          if self.modified then hl_attrs.italic = true end
          if has_diagnostics then hl_attrs.underline = true end

          return hl_attrs
        end,
        update = { 'BufEnter', 'BufWritePost', 'BufModifiedSet', 'DiagnosticChanged' },
      }

      local FileFormat = {
        static = {
          system_format = (function()
            -- Check for WSL first (reports as unix, not windows)
            if vim.fn.has 'wsl' == 1 then
              return 'unix'
            elseif vim.fn.has 'win32' == 1 or vim.fn.has 'win64' == 1 then
              return 'dos'
            elseif vim.fn.has 'mac' == 1 then
              return 'mac'
            else
              return 'unix'
            end
          end)(),
        },
        init = function(self)
          -- Get current buffer's format
          local rightmost_win = get_rightmost_window()
          local buf = vim.api.nvim_win_get_buf(rightmost_win)
          local fileformat = vim.api.nvim_get_option_value('fileformat', { buf = buf })

          -- Set icon based on the file's actual format
          if fileformat == 'dos' then
            self.format_icon = ' ' -- Windows CRLF
          elseif fileformat == 'mac' then
            self.format_icon = ' ' -- Mac CR
          else
            self.format_icon = ' ' -- Unix LF
          end
        end,
        provider = function(self) return self.format_icon end,
        condition = function(self)
          -- Only show if different from system default
          local rightmost_win = get_rightmost_window()
          local buf = vim.api.nvim_win_get_buf(rightmost_win)
          local fileformat = vim.api.nvim_get_option_value('fileformat', { buf = buf })
          return fileformat ~= self.system_format
        end,
        hl = { fg = 'ErrorMsg' },
        update = { 'BufEnter', 'BufWritePost' },
      }

      -- Spacer to push rightmost components to the right
      local Align = { provider = '%=' }

      vim.o.showtabline = 2 -- Always show tabline
      vim.o.laststatus = 0 -- Global statusline

      -- Left side components
      local LeftSide = {
        GitBranch,
        GitStatus,
        LspServer,
        HarpoonMarks,
        LintersFormatters,
      }

      -- Load colors using heirline's proper theming system  
      fn { 'heirline.load_colors', get_theme_colors }()

      -- Setup heirline once
      fn {
        'heirline.setup',
        {
          statusline = {},
          tabline = {
            {
              provider = function() return vim.fn.fnamemodify(vim.fn.getcwd(), ':~') end,
              hl = { fg = 'Directory' },
            },
            {
              provider = function(self) return ' on ' .. self.git_info.branch .. ' ' end,
              static = {
                git_info = nil,
                last_cwd = '',
              },
              condition = function(self)
                local cwd = vim.fn.getcwd()
                if cwd ~= self.last_cwd or not self.git_info then
                  local is_git_repo = vim.fn.system('git rev-parse --is-inside-work-tree 2>/dev/null'):match 'true'
                  local branch = ''
                  if is_git_repo then branch = vim.fn.system('git branch --show-current 2>/dev/null'):gsub('\n', '') end
                  self.git_info = { is_git_repo = is_git_repo, branch = branch }
                  self.last_cwd = cwd
                end
                return self.git_info.is_git_repo and self.git_info.branch ~= ''
              end,
              update = { 'DirChanged', 'BufEnter' },
              hl = { fg = 'Statement' },
            },
            {
              provider = fn 'ui.components.git.status_icons',
              condition = function(self)
                -- Reuse git info from GitBranch if available
                local git_branch = self.parent and self.parent[2] -- GitBranch is index 2 in LeftSide
                if git_branch and git_branch.git_info then return git_branch.git_info.is_git_repo end
                return vim.fn.system('git rev-parse --is-inside-work-tree 2>/dev/null'):match 'true'
              end,
              update = { 'BufWritePost', 'BufEnter' },
              hl = { fg = 'GitSignsChange', bold = true },
            },
            {
              static = {
                excluded = { 'copilot', 'efm', 'null-ls', 'conform' },
                is_refreshing = false,
                refresh_timer = nil,
                start_refresh_cycle = function(self)
                  if self.refresh_timer then self.refresh_timer:stop() end

                  local function refresh()
                    if self.is_refreshing then
                      vim.cmd 'redrawtabline'
                      self.refresh_timer = vim.defer_fn(refresh, 200) -- 200ms refresh rate
                    end
                  end

                  refresh()
                end,
                stop_refresh_cycle = function(self)
                  if self.refresh_timer then
                    self.refresh_timer:stop()
                    self.refresh_timer = nil
                  end
                  vim.cmd 'redrawtabline' -- Final redraw to show completion
                end,
              },
              init = function(self)
                -- Check if LSP work is happening and manage refresh cycle
                local ok, lsp_progress = pcall(require, 'lsp-progress')
                if ok then
                  local progress = lsp_progress.progress()
                  local has_progress = progress ~= ''

                  if has_progress and not self.is_refreshing then
                    -- Start refresh cycle when LSP work begins
                    self.is_refreshing = true
                    self:start_refresh_cycle()
                  elseif not has_progress and self.is_refreshing then
                    -- Stop refresh cycle when LSP work is done
                    self.is_refreshing = false
                    self:stop_refresh_cycle()
                  end
                end
              end,
              provider = function(self) return require('ui.components.lsp').server() end,
              update = {
                'User',
                pattern = 'LspProgressStatusUpdated',
              },
              hl = { fg = 'Normal' },
            },
            {
              static = {
                lf_names = { 'efm', 'null-ls' },
              },
              init = function(self) self.display_text = require('ui.components.formatter').display() end,
              provider = function(self) return self.display_text or '' end,
              update = { 'DirChanged', 'BufEnter', 'LspAttach', 'LspDetach' },
              hl = { fg = 'Comment' },
            },
            {
              init = function(self)
                local harpoon = require 'harpoon'
                self.marks = harpoon:list().items
                self.current_file_path = vim.fn.expand '%:p:.'

                -- Calculate total length for compact mode decision
                local total_length = 0
                for _, item in ipairs(self.marks) do
                  local filename = vim.fn.fnamemodify(item.value, ':t'):gsub('%..*', '')
                  total_length = total_length + #filename + 4 -- +4 for " -t " or " --"
                end

                self.use_compact = total_length > (vim.o.columns * 0.4) or #self.marks > 4

                -- Pre-calculate the display text
                if #self.marks == 0 then
                  self.display_text = ''
                elseif self.use_compact then
                  -- Compact mode: -Abc (capital for current, lowercase for others)
                  local letters = {}
                  for _, item in ipairs(self.marks) do
                    local first_letter = vim.fn.fnamemodify(item.value, ':t'):sub(1, 1)
                    if item.value == self.current_file_path then
                      table.insert(letters, first_letter:upper()) -- Capital for current
                    else
                      table.insert(letters, first_letter:lower()) -- Lowercase for others
                    end
                  end
                  self.display_text = ' -' .. table.concat(letters, '')
                else
                  -- Full mode: -t filename --filename
                  local result = {}
                  for _, item in ipairs(self.marks) do
                    local filename = vim.fn.fnamemodify(item.value, ':t'):gsub('%..*', '')
                    if item.value == self.current_file_path then
                      table.insert(result, ' -t ' .. filename) -- Active: -t filename
                    else
                      table.insert(result, ' --' .. filename) -- Inactive: --filename
                    end
                  end
                  self.display_text = table.concat(result, '')
                end
              end,
              provider = function(self) return self.display_text end,
              update = { 'BufEnter' },
              hl = { fg = 'Normal' },
            },
            Align,
            RightmostIcon,
            RightmostFilename,
            FileFormat,
          },
        },
      }()

      -- Proper theme refresh using heirline's API
      vim.api.nvim_create_augroup('Heirline', { clear = true })
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = 'Heirline',
        callback = function()
          fn { 'heirline.utils.on_colorscheme', get_theme_colors }()

          -- Reapply transparent.nvim settings
          local transparent, ok = try(require, 'transparent')
          if ok then
            transparent.clear_prefix 'heirline'
            vim.cmd 'TransparentEnable'
          end
        end,
      })
    end,
  },
  {
    'b0o/incline.nvim',
    event = 'VeryLazy',
    opts = {
      render = function(props)
        -- Get window position info
        local win = props.win
        local tab = vim.api.nvim_win_get_tabpage(win)
        local wins_in_tab = vim.api.nvim_tabpage_list_wins(tab)

        -- Filter out floating windows and ensure we only work with normal windows
        local normal_wins = {}
        for _, w in ipairs(wins_in_tab) do
          local config = vim.api.nvim_win_get_config(w)
          if config.relative == '' and vim.api.nvim_win_is_valid(w) then table.insert(normal_wins, w) end
        end

        -- If no normal windows, don't show incline
        if #normal_wins == 0 then return nil end

        -- If only one window, it's both rightmost and topmost, so hide it
        if #normal_wins == 1 then return nil end

        -- Find the rightmost window in the top row only
        local top_right_window = nil
        local rightmost_col_in_top_row = -1
        local top_row = math.huge

        -- First find what the top row is
        for _, w in ipairs(normal_wins) do
          local pos = vim.api.nvim_win_get_position(w)
          local row = pos[1]
          if row < top_row then top_row = row end
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

        -- Don't show anything for the top-right window
        if win == top_right_window then return nil end

        -- Get filename and icon
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
        if filename == '' then filename = '[No Name]' end

        -- Get icon and color using mini.icons
        local ft_icon, ft_hl_group = require('mini.icons').get('file', filename)
        local hl_attrs = vim.api.nvim_get_hl(0, { name = ft_hl_group })
        local ft_color = hl_attrs.fg and string.format('#%06x', hl_attrs.fg)

        -- Helper function to get highlight group colors (matches heirline approach)
        local function get_hl_color(group)
          local hl = vim.api.nvim_get_hl(0, { name = group })
          return hl.fg and string.format('#%06x', hl.fg) or nil
        end

        -- Get git status color
        local function get_git_status_color()
          local filepath = vim.api.nvim_buf_get_name(props.buf)
          if filepath == '' then return get_hl_color 'Normal' end

          local handle = io.popen('git status --porcelain ' .. vim.fn.shellescape(filepath) .. ' 2>/dev/null')
          if not handle then return nil end

          local result = handle:read '*a'
          handle:close()

          if result == '' then return get_hl_color 'Normal' end

          local status = result:sub(1, 2)

          -- Check for serious git states (red - immediate attention needed)
          if status:match 'UU' or status:match 'AA' or status:match 'DD' then
            return get_hl_color 'ErrorMsg' -- Red for merge conflicts
          elseif status:match 'AU' or status:match 'UA' or status:match 'UD' or status:match 'DU' then
            return get_hl_color 'ErrorMsg' -- Red for conflict states
          end

          -- Regular git states
          if status:match '^%?%?' then
            return get_hl_color 'GitSignsAdd' -- Green for untracked
          elseif status:match '[AM]' then
            return get_hl_color 'GitSignsChange' -- Orange for modified/added
          end

          return get_hl_color 'Normal'
        end

        local git_color = get_git_status_color()
        local has_diagnostics = #vim.diagnostic.get(props.buf) > 0

        local gui_style = 'none'
        if vim.bo[props.buf].modified then gui_style = 'italic' end
        if has_diagnostics then gui_style = vim.bo[props.buf].modified and 'italic,underline' or 'underline' end

        -- File format detection
        local fileformat = vim.api.nvim_get_option_value('fileformat', { buf = props.buf })

        local system_format = 'unix' -- default
        -- Check for WSL first (reports as unix, not windows)
        if vim.fn.has 'wsl' == 1 then
          system_format = 'unix'
        elseif vim.fn.has 'win32' == 1 or vim.fn.has 'win64' == 1 then
          system_format = 'dos'
        elseif vim.fn.has 'mac' == 1 then
          system_format = 'mac'
        end

        local function get_format_icon()
          if fileformat == 'dos' then
            return ' ' -- Windows CRLF
          elseif fileformat == 'mac' then
            return ' ' -- Mac CR
          elseif fileformat == 'unix' then
            return 'F0311 ' -- Unix LF
          end
          return ''
        end

        local format_icon = get_format_icon()

        local result = {}
        table.insert(result, { ft_icon and (ft_icon .. ' ') or '', guifg = ft_color })
        table.insert(result, {
          filename,
          guifg = git_color or get_hl_color 'Normal',
          gui = gui_style,
        })

        -- Show format icon only when different from system (matches heirline)
        if fileformat ~= system_format then
          table.insert(result, { format_icon, guifg = get_hl_color 'ErrorMsg' }) -- ErrorMsg color
        end

        return result
      end,
      window = {
        padding = 0,
        margin = { horizontal = 0, vertical = 0 },
      },
    },
  },
  {
    'linrongbin16/lsp-progress.nvim',
    opts = {
      spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
      spin_update_time = 100,
      decay = 700,
      series_format = function(title, message, percentage, done) return title end,
      client_format = function(client_name, spinner, series_messages)
        if #series_messages == 0 then return nil end
        return {
          name = client_name,
          body = spinner,
        }
      end,
      format = function(client_messages)
        if #client_messages > 0 then return client_messages[1].body end
        return ''
      end,
    },
  },
}
