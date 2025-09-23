return {
  {
    'rebelot/heirline.nvim',
    lazy = false,
    dependencies = { 'echasnovski/mini.icons', 'linrongbin16/lsp-progress.nvim' },
    config = function()
      require('mini.icons').mock_nvim_web_devicons()

      local heirline = require 'heirline'
      local utils = require 'heirline.utils'

      -- Theme-aware color system - just use highlight group names directly
      local function get_theme_colors()
        local function fg(group) return string.format('#%06x', utils.get_highlight(group).fg) end
        local function bg(group) return string.format('#%06x', utils.get_highlight(group).bg) end

        return {
          -- Only the highlight groups actually used
          Directory = fg 'Directory',
          Statement = fg 'Statement',
          WarningMsg = fg 'WarningMsg',
          Normal = fg 'Normal',
          Comment = fg 'Comment',
          ErrorMsg = fg 'ErrorMsg',
          GitSignsAdd = fg 'GitSignsAdd',
          GitSignsChange = fg 'GitSignsChange',
          NonText = fg 'NonText',
        }
      end

      -- Colors will be loaded via heirline.load_colors() and available as color aliases

      -- CLI Theme Components
      local WorkingDir = {
        provider = function() return vim.fn.fnamemodify(vim.fn.getcwd(), ':~') end,
        hl = { fg = 'Directory' },
      }

      local GitBranch = {
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
          return self.git_info.is_git_repo
        end,
        provider = function(self) return self.git_info.branch ~= '' and (' on ' .. self.git_info.branch .. ' ') or '' end,
        update = { 'DirChanged', 'BufEnter' },
        hl = { fg = 'Statement' },
      }

      local GitStatus = {
        condition = function(self)
          -- Reuse git info from GitBranch if available
          local git_branch = self.parent and self.parent[2] -- GitBranch is index 2 in LeftSide
          if git_branch and git_branch.git_info then return git_branch.git_info.is_git_repo end
          return vim.fn.system('git rev-parse --is-inside-work-tree 2>/dev/null'):match 'true'
        end,
        provider = fn 'components.file_info.git_status',
        update = { 'BufWritePost', 'BufEnter' },
        hl = { fg = 'GitSignsChange', bold = true },
      }

      local LspServer = {
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
        provider = function(self)
          local buf_clients = vim.lsp.get_clients { bufnr = 0 }

          -- Filter for main language servers only using static excluded list
          local language_servers = {}
          for _, client in ipairs(buf_clients) do
            local is_excluded = false
            for _, excluded_name in ipairs(self.excluded) do
              if client.name:lower():find(excluded_name:lower()) then
                is_excluded = true
                break
              end
            end
            if not is_excluded then table.insert(language_servers, client) end
          end

          -- Get LSP progress spinner or error indicator
          local lsp_indicator
          if _G.Errors and type(_G.Errors) == 'table' and #_G.Errors > 0 then
            lsp_indicator = 'E '
          else
            local ok, lsp_progress = pcall(require, 'lsp-progress')
            if ok then
              local progress = lsp_progress.progress()
              lsp_indicator = progress ~= '' and (progress .. ' ') or '  '
            else
              lsp_indicator = '  '
            end
          end

          if #language_servers == 0 then return lsp_indicator .. 'nvim' end

          -- Get the main LSP server (first language server)
          local client = language_servers[1]
          return lsp_indicator .. client.name
        end,
        update = {
          'User',
          pattern = 'LspProgressStatusUpdated',
        },
        hl = { fg = 'Normal' },
      }

      -- Fully dynamic formatter flag discovery
      local function discover_config_files(formatter_name)
        -- Common config file patterns
        local patterns = {
          -- Dotfiles in root
          '.'
            .. formatter_name
            .. 'rc',
          '.' .. formatter_name .. 'rc.json',
          '.' .. formatter_name .. 'rc.js',
          '.' .. formatter_name .. 'rc.yaml',
          '.' .. formatter_name .. 'rc.yml',
          -- Config files
          formatter_name .. '.config.js',
          formatter_name .. '.config.json',
          -- TOML files
          formatter_name .. '.toml',
          '.' .. formatter_name .. '.toml',
          -- Package.json
          'package.json',
          -- Pyproject.toml for Python tools
          'pyproject.toml',
        }

        local found = {}
        for _, pattern in ipairs(patterns) do
          if vim.fn.filereadable(pattern) == 1 then table.insert(found, pattern) end
        end
        return found
      end

      local function parse_config_file(filepath, formatter_name)
        local content = vim.fn.readfile(filepath)
        if #content == 0 then return nil end

        local full_content = table.concat(content, '\n')

        -- Try JSON first
        local ok, config = pcall(vim.json.decode, full_content)
        if ok then
          -- For package.json, look for formatter-specific key
          if filepath:match 'package%.json$' then return config[formatter_name] or config.prettier or config.eslint end
          return config
        end

        -- Try TOML parsing (simple key=value)
        config = {}
        for _, line in ipairs(content) do
          local trimmed = line:match '^%s*(.-)%s*$'
          if trimmed and not trimmed:match '^[#%[]' and trimmed:find '=' then
            -- key = value
            local key, value = trimmed:match '^([^=]+)%s*=%s*(.+)$'
            if key and value then
              key = key:gsub('%s+', ''):gsub('%-', '_')
              value = value:gsub('^["\']', ''):gsub('["\']$', '') -- Remove quotes
              -- Try to convert numbers
              local num = tonumber(value)
              if num then
                config[key] = num
              elseif value:lower() == 'true' then
                config[key] = true
              elseif value:lower() == 'false' then
                config[key] = false
              else
                config[key] = value
              end
            end
          end
        end

        return next(config) and config or nil
      end

      local function generate_flag_variants(key, value)
        -- Convert camelCase/snake_case to kebab-case for flags
        local flag_name = key:gsub('([a-z])([A-Z])', '%1-%2'):gsub('_', '-'):lower()

        -- Generate full flag
        local full_flag
        if type(value) == 'boolean' then
          if value then
            full_flag = '--' .. flag_name
          else
            -- Handle negative boolean (like semi: false -> --no-semi)
            full_flag = '--no-' .. flag_name:gsub('^no%-', '')
          end
        else
          full_flag = '--' .. flag_name .. '=' .. tostring(value)
        end

        -- Generate abbreviated flag (first letter of each word)
        local abbrev_letters = {}
        for word in flag_name:gmatch '[^-]+' do
          table.insert(abbrev_letters, word:sub(1, 1))
        end
        local abbrev = '-' .. table.concat(abbrev_letters, '')
        if type(value) ~= 'boolean' then abbrev = abbrev .. '=' .. tostring(value) end

        -- Generate compact form (just the letters)
        local compact = table.concat(abbrev_letters, '')

        return full_flag, abbrev, compact
      end

      local formatter_cache = {}
      local function get_formatter_flag_levels(formatter_name)
        local cwd = vim.fn.getcwd()
        local cache_key = formatter_name .. ':' .. cwd

        -- Return cached result if available
        if formatter_cache[cache_key] then return formatter_cache[cache_key] end

        local flag_levels = { '', '', '' }

        -- Discover config files
        local config_files = discover_config_files(formatter_name)
        if #config_files == 0 then
          formatter_cache[cache_key] = flag_levels
          return flag_levels
        end

        -- Try to parse config from any found file
        local config = nil
        for _, config_file in ipairs(config_files) do
          config = parse_config_file(config_file, formatter_name)
          if config then break end
        end

        if not config then
          formatter_cache[cache_key] = flag_levels
          return flag_levels
        end

        local full_flags = {}
        local abbrev_flags = {}
        local compact_letters = {}

        -- Generate flags for all config options
        for key, value in pairs(config) do
          -- Skip nil/false values (except explicit false for boolean toggles)
          if value ~= nil and (type(value) ~= 'boolean' or value ~= false or key:match 'semi') then
            local full, abbrev, compact = generate_flag_variants(key, value)
            table.insert(full_flags, full)
            table.insert(abbrev_flags, abbrev)
            table.insert(compact_letters, compact)
          end
        end

        flag_levels = {
          table.concat(full_flags, ' '),
          table.concat(abbrev_flags, ' '),
          #compact_letters > 0 and ('-' .. table.concat(compact_letters, '')) or '',
        }

        -- Cache the result
        formatter_cache[cache_key] = flag_levels
        return flag_levels
      end

      -- Clear cache when directory changes
      vim.api.nvim_create_autocmd('DirChanged', {
        callback = function() formatter_cache = {} end,
      })

      -- Helper function to get best flag level that fits in max_width
      local function get_formatter_flags_progressive(formatter_name, max_width)
        local flag_levels = get_formatter_flag_levels(formatter_name)

        -- Find the longest level that fits within max_width
        for _, level in ipairs(flag_levels) do
          if #level <= max_width then return level end
        end

        return flag_levels[#flag_levels] or '' -- Return most compact or empty
      end

      local LintersFormatters = {
        static = {
          lf_names = { 'efm', 'null-ls' },
        },
        provider = function(self)
          -- Calculate space budget dynamically for responsive behavior
          local current_cwd = vim.fn.getcwd()
          local total_width = vim.o.columns
          local working_dir_width = #vim.fn.fnamemodify(current_cwd, ':~')

          -- Get git info from GitBranch component if available
          local branch_width = 0
          local git_branch = self.parent and self.parent[2] -- GitBranch is index 2 in LeftSide
          if git_branch and git_branch.git_info then
            branch_width = git_branch.git_info.branch ~= '' and #(' on ' .. git_branch.git_info.branch .. ' ') or 0
          end

          local git_status_width = 10

          -- Calculate LSP width
          local buf_clients = vim.lsp.get_clients { bufnr = 0 }
          local lsp_width = 6 -- "  nvim" default
          for _, client in ipairs(buf_clients) do
            local is_excluded = false
            for _, excluded_name in ipairs { 'copilot', 'efm', 'null-ls', 'conform' } do
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

          -- Calculate harpoon width
          local harpoon = require 'harpoon'
          local marks = harpoon:list().items
          local harpoon_width = 0
          if #marks > 0 then
            local harpoon_total_length = 0
            for _, item in ipairs(marks) do
              local filename = vim.fn.fnamemodify(item.value, ':t'):gsub('%..*', '')
              harpoon_total_length = harpoon_total_length + #filename + 4
            end
            local harpoon_use_compact = harpoon_total_length > (total_width * 0.4) or #marks > 4
            if harpoon_use_compact then
              harpoon_width = 2 + #marks -- " -" + letters
            else
              harpoon_width = harpoon_total_length
            end
          end

          -- Calculate right side width
          local rightmost_win = vim.api.nvim_get_current_win()
          local buf = vim.api.nvim_win_get_buf(rightmost_win)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':t')
          local right_side_width = 2 + #(filename ~= '' and filename or '[No Name]')

          -- Calculate available space budget
          local used_width = working_dir_width
            + branch_width
            + git_status_width
            + lsp_width
            + harpoon_width
            + right_side_width
          local space_budget = total_width - used_width - 5

          local result = {}

          -- Check for LSP-based linters/formatters
          for _, client in ipairs(buf_clients) do
            for _, lf_name in ipairs(self.lf_names) do
              if client.name:lower():find(lf_name:lower()) then
                table.insert(result, client.name)
                break
              end
            end
          end

          -- Check for conform.nvim formatters with config flags (using cached config parsing)
          local ok, conform = pcall(require, 'conform')
          if ok then
            local formatters = conform.list_formatters(0)
            local space_used = 0

            for i, formatter in ipairs(formatters) do
              if formatter.available then
                local formatter_name = formatter.name
                local flag_levels = get_formatter_flag_levels(formatter_name) -- Uses cached config parsing

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

          if #result == 0 then return '' end

          local full_text = ' | ' .. table.concat(result, ' | ')
          return full_text
        end,
        update = { 'DirChanged', 'BufEnter', 'LspAttach', 'LspDetach' },
        hl = { fg = 'Comment' },
      }

      local HarpoonMarks = {
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
        end,
        provider = function(self)
          if #self.marks == 0 then return '' end

          if self.use_compact then
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
            return ' -' .. table.concat(letters, '')
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
            return table.concat(result, '')
          end
        end,
        update = { 'BufEnter' },
        hl = { fg = 'Normal' },
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
          local color = hl_attrs.fg and string.format('#%06x', hl_attrs.fg) or 'NonText'

          return { fg = color }
        end,
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

      -- Statusline Components
      local Diagnostics = {
        condition = function() return #vim.diagnostic.get(0) > 0 end,
        static = {
          error_icon = ' ',
          warn_icon = '󱈸 ',
          info_icon = ' ',
          hint_icon = ' ',
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
        hl = { fg = 'Comment' },
      }

      -- Center diagnostics in statusline
      local StatusAlign = { provider = '%=' }

      -- Enable tabline
      vim.o.showtabline = 2 -- Always show tabline

      vim.o.laststatus = 0 -- Global statusline

      -- Left side components
      local LeftSide = {
        WorkingDir,
        GitBranch,
        GitStatus,
        LspServer,
        HarpoonMarks,
        LintersFormatters,
      }

      -- Load colors using heirline's proper theming system
      heirline.load_colors(get_theme_colors)

      -- Setup heirline once
      heirline.setup {
        statusline = {
          -- StatusAlign,
          -- Diagnostics, -- Use basic diagnostics instead of trouble statusline
          -- StatusAlign,
        },
        tabline = {
          LeftSide,
          Align,
          RightmostIcon,
          RightmostFilename,
          FileFormat,
        },
      }

      -- Proper theme refresh using heirline's API
      vim.api.nvim_create_augroup('Heirline', { clear = true })
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = 'Heirline',
        callback = function()
          utils.on_colorscheme(get_theme_colors)

          -- Reapply transparent.nvim settings
          local ok, transparent = pcall(require, 'transparent')
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
