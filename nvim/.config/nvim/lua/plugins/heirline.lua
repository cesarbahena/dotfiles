return {
  'rebelot/heirline.nvim',
  lazy = false,
  dependencies = { 'echasnovski/mini.icons', 'linrongbin16/lsp-progress.nvim' },
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
      hl = { fg = '#957FB8' },
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
      hl = { fg = '#E6C384', bold = true },
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

        -- Get LSP progress spinner
        local lsp_indicator = '  '
        local ok, lsp_progress = pcall(require, 'lsp-progress')
        if ok then
          local progress = lsp_progress.progress()
          lsp_indicator = progress ~= '' and (progress .. ' ') or '  '
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
      hl = { fg = '#DCD7BA' },
    }

    -- Cached formatter config parsing
    local formatter_cache = {}
    local function get_formatter_flag_levels(formatter_name)
      local cwd = vim.fn.getcwd()
      local cache_key = formatter_name .. ':' .. cwd

      -- Return cached result if available
      if formatter_cache[cache_key] then return formatter_cache[cache_key] end

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
              if ok then
                config = parsed
                break
              end
            end
          end
        end

        if not config and vim.fn.filereadable 'package.json' == 1 then
          local content = vim.fn.readfile 'package.json'
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
            table.insert(abbrev_flags, '-tc=' .. config.trailingComma:sub(1, 2))
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
            #compact_letters > 0 and ('-' .. table.concat(compact_letters, '')) or '',
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
              local trimmed = line:match '^%s*(.-)%s*$'
              if trimmed and not trimmed:match '^#' then
                if trimmed:match 'indent_width%s*=%s*(%d+)' then
                  local width = trimmed:match 'indent_width%s*=%s*(%d+)'
                  table.insert(full_flags, '--indent-width=' .. width)
                  table.insert(abbrev_flags, '-iw=' .. width)
                  table.insert(compact_letters, 'i')
                elseif trimmed:match 'quote_style%s*=%s*"([^"]+)"' then
                  local style = trimmed:match 'quote_style%s*=%s*"([^"]+)"'
                  table.insert(full_flags, '--quote-style=' .. style)
                  table.insert(abbrev_flags, '-qs=' .. style:sub(1, 2))
                  table.insert(compact_letters, 'q')
                elseif trimmed:match 'column_width%s*=%s*(%d+)' then
                  local width = trimmed:match 'column_width%s*=%s*(%d+)'
                  table.insert(full_flags, '--column-width=' .. width)
                  table.insert(abbrev_flags, '-cw=' .. width)
                  table.insert(compact_letters, 'c')
                elseif trimmed:match 'indent_type%s*=%s*"([^"]+)"' then
                  local indent_type = trimmed:match 'indent_type%s*=%s*"([^"]+)"'
                  table.insert(full_flags, '--indent-type=' .. indent_type)
                  table.insert(abbrev_flags, '-it=' .. indent_type:sub(1, 2))
                  table.insert(compact_letters, 't')
                end
              end
            end

            flag_levels = {
              table.concat(full_flags, ' '),
              table.concat(abbrev_flags, ' '),
              #compact_letters > 0 and ('-' .. table.concat(compact_letters, '')) or '',
            }
            break
          end
        end
      end

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
      init = function(self)
        -- Compute all expensive operations once per evaluation
        self.current_cwd = vim.fn.getcwd()
        self.total_width = vim.o.columns
        self.working_dir_width = #vim.fn.fnamemodify(self.current_cwd, ':~')

        -- Get git info from GitBranch component if available
        local git_branch = self.parent and self.parent[2] -- GitBranch is index 2 in LeftSide
        if git_branch and git_branch.git_info then
          self.branch_width = git_branch.git_info.branch ~= '' and #(' on ' .. git_branch.git_info.branch .. ' ') or 0
        else
          self.branch_width = 0
        end

        self.git_status_width = 10

        -- Calculate LSP width
        local buf_clients = vim.lsp.get_clients { bufnr = 0 }
        self.lsp_width = 6 -- "  nvim" default
        for _, client in ipairs(buf_clients) do
          local is_excluded = false
          for _, excluded_name in ipairs(self.excluded or { 'copilot', 'efm', 'null-ls', 'conform' }) do
            if client.name:lower():find(excluded_name:lower()) then
              is_excluded = true
              break
            end
          end
          if not is_excluded then
            self.lsp_width = #('  ' .. client.name)
            break
          end
        end

        -- Calculate harpoon width
        local harpoon = require 'harpoon'
        local marks = harpoon:list().items
        self.harpoon_width = 0
        if #marks > 0 then
          local harpoon_total_length = 0
          for _, item in ipairs(marks) do
            local filename = vim.fn.fnamemodify(item.value, ':t'):gsub('%..*', '')
            harpoon_total_length = harpoon_total_length + #filename + 4
          end
          local harpoon_use_compact = harpoon_total_length > (self.total_width * 0.4) or #marks > 4
          if harpoon_use_compact then
            self.harpoon_width = 2 + #marks -- " -" + letters
          else
            self.harpoon_width = harpoon_total_length
          end
        end

        -- Calculate right side width
        local rightmost_win = vim.api.nvim_get_current_win()
        local buf = vim.api.nvim_win_get_buf(rightmost_win)
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':t')
        self.right_side_width = 2 + #(filename ~= '' and filename or '[No Name]')

        -- Calculate available space budget
        local used_width = self.working_dir_width
          + self.branch_width
          + self.git_status_width
          + self.lsp_width
          + self.harpoon_width
          + self.right_side_width
        self.space_budget = self.total_width - used_width - 5
      end,
      provider = function(self)
        local result = {}

        -- Check for LSP-based linters/formatters
        local buf_clients = vim.lsp.get_clients { bufnr = 0 }

        for _, client in ipairs(buf_clients) do
          for _, lf_name in ipairs(self.lf_names) do
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
          local space_used = 0

          for i, formatter in ipairs(formatters) do
            if formatter.available then
              local formatter_name = formatter.name
              local flag_levels = get_formatter_flag_levels(formatter_name)

              local chosen_flags = ''
              local space_remaining = self.space_budget - space_used
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
      hl = { fg = '#555555' },
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
      update = { 'BufEnter', 'User' }, -- User event for harpoon changes
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
      init = function(self)
        local rightmost_win = get_rightmost_window()
        local buf = vim.api.nvim_win_get_buf(rightmost_win)
        self.filepath = vim.api.nvim_buf_get_name(buf)
        self.filename = vim.fn.fnamemodify(self.filepath, ':t')
        self.modified = vim.api.nvim_get_option_value('modified', { buf = buf })

        -- Compute git status color
        self.color = '#C0C0C0' -- default muted white for clean files

        if self.filepath ~= '' then
          local git_status = vim.fn
            .system('git status --porcelain ' .. vim.fn.shellescape(self.filepath) .. ' 2>/dev/null')
            :gsub('\n', '')

          if git_status == '' then
            -- File is tracked and clean
            self.color = '#C0C0C0' -- muted white
          elseif git_status:match 'UU' or git_status:match 'AA' or git_status:match 'DD' then
            -- Merge conflicts - immediate attention needed
            self.color = '#f38ba8' -- red
          elseif git_status:match 'AU' or git_status:match 'UA' or git_status:match 'UD' or git_status:match 'DU' then
            -- Conflict states - immediate attention needed
            self.color = '#f38ba8' -- red
          elseif git_status:match '^%?%?' then
            -- File is untracked
            self.color = '#a6e3a1' -- green
          elseif git_status:match '[AM]' then
            -- Modified/added files
            self.color = '#fab387' -- orange
          else
            -- Unknown status, default to muted white
            self.color = '#C0C0C0' -- muted white
          end
        end
      end,
      provider = function(self) return self.filename ~= '' and (' ' .. self.filename) or ' [No Name]' end,
      hl = function(self)
        if self.modified then return { fg = self.color, italic = true } end
        return { fg = self.color }
      end,
      update = { 'BufEnter', 'BufWritePost', 'BufModifiedSet' },
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

    -- Trouble statusline component
    local TroubleStatusline = {
      provider = function()
        local trouble = require 'trouble'
        local symbols = trouble.statusline {
          mode = 'lsp_document_symbols',
          groups = {},
          title = false,
          filter = { range = true },
          format = '{kind_icon}{symbol.name:Normal}',
        }
        return symbols.get()
      end,
      condition = function()
        local trouble = require 'trouble'
        local symbols = trouble.statusline {
          mode = 'lsp_document_symbols',
          groups = {},
          title = false,
          filter = { range = true },
          format = '{kind_icon}{symbol.name:Normal}',
        }
        return symbols.has()
      end,
      hl = { fg = '#938AA9' },
    }

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
        Diagnostics, -- Use basic diagnostics instead of trouble statusline
        StatusAlign,
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
