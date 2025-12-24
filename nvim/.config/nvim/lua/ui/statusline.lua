return {
  {
    'rebelot/heirline.nvim',
    lazy = false,
    dependencies = { 'echasnovski/mini.icons' },
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
          'Type',
        }

        local colors = {}
        for _, hl_group in ipairs(hl_groups) do
          local hl = fn { 'heirline.utils.get_highlight', hl_group }()
          if hl and hl.fg then colors[hl_group] = string.format('#%06x', hl.fg) end
        end
        return colors
      end

      -- Helper function to get target window (focused or rightmost based on context)
      local function get_target_window()
        local current_win = vim.api.nvim_get_current_win()
        local current_buf = vim.api.nvim_win_get_buf(current_win)
        local buf_ft = vim.api.nvim_get_option_value('filetype', { buf = current_buf })
        local is_diff = vim.api.nvim_get_option_value('diff', { win = current_win })

        -- Use first window for terminal buffers or diff mode
        if buf_ft == 'snacks_terminal' or is_diff then
          local windows = vim.api.nvim_tabpage_list_wins(0)
          for _, win in ipairs(windows) do
            if vim.api.nvim_win_get_config(win).relative == '' then
              return win -- Return the first normal window (1,1)
            end
          end
          return current_win
        else
          -- Normal case: use focused window
          return current_win
        end
      end

      local RightmostIcon = {
        init = fn { 'ui.components.file.icon_init', args = 1 },
        provider = function(self) return self.icon end,
        hl = fn { 'ui.components.file.icon_hl', args = 1 },
        update = { 'BufEnter', 'FileType' },
      }

      local TargetFilename = {
        init = function(self)
          local target_win = get_target_window()
          local buf = vim.api.nvim_win_get_buf(target_win)
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
        provider = function(self) return self.filename ~= '' and self.filename or '' end,
        hl = function(self)
          local target_win = get_target_window()
          local buf = vim.api.nvim_win_get_buf(target_win)
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
          local target_win = get_target_window()
          local buf = vim.api.nvim_win_get_buf(target_win)
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
          local target_win = get_target_window()
          local buf = vim.api.nvim_win_get_buf(target_win)
          local fileformat = vim.api.nvim_get_option_value('fileformat', { buf = buf })
          return fileformat ~= self.system_format
        end,
        hl = { fg = 'ErrorMsg' },
        update = { 'BufEnter', 'BufWritePost' },
      }

      -- Spacer to push rightmost components to the right
      local Align = { provider = '%=' }

      vim.o.showtabline = 2 -- Always show tabline
      vim.o.laststatus = 0 -- Hide statusline

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
              provider = function()
                local diagnostics = vim.diagnostic.get(0)
                local has_errors = false
                for _, diag in ipairs(diagnostics) do
                  if diag.severity == vim.diagnostic.severity.ERROR then
                    has_errors = true
                    break
                  end
                end
                return '❯'
              end,
              hl = function()
                local diagnostics = vim.diagnostic.get(0)
                local has_errors = false
                for _, diag in ipairs(diagnostics) do
                  if diag.severity == vim.diagnostic.severity.ERROR then
                    has_errors = true
                    break
                  end
                end
                return { fg = has_errors and '#E82424' or '#87C563' }
              end,
              update = { 'DiagnosticChanged', 'BufEnter' },
            },
            {
              static = {
                excluded = { 'copilot', 'efm', 'null-ls', 'conform' },
                -- Cache colors for zsh-style syntax highlighting using theme palette
                colors = {
                  working = 'GitSignsAdd', -- Valid LSP server (green like valid commands)
                  error = 'ErrorMsg', -- LSP with errors (red like unknown tokens)
                  fallback = 'Type', -- nvim fallback (blue like shell functions)
                },
              },
              init = function(self)
                -- Cache LSP status for color coding
                local buf_clients = vim.lsp.get_clients { bufnr = 0 }
                local active_servers = {}
                for _, client in ipairs(buf_clients) do
                  local is_excluded = false
                  for _, excluded_name in ipairs(self.excluded) do
                    if client.name:lower():find(excluded_name:lower()) then
                      is_excluded = true
                      break
                    end
                  end
                  if not is_excluded then table.insert(active_servers, client) end
                end

                -- Check if current filetype should have an LSP server and find expected server name
                local current_ft = vim.bo.filetype
                local expected_server = nil

                if current_ft and current_ft ~= '' then
                  -- Check enabled LSP configs for this filetype
                  for server_name, config in pairs(vim.lsp._enabled_configs or {}) do
                    if config.resolved_config and config.resolved_config.filetypes then
                      for _, ft in ipairs(config.resolved_config.filetypes) do
                        if ft == current_ft then
                          expected_server = server_name
                          break
                        end
                      end
                      if expected_server then break end
                    end
                  end
                end

                -- Store expected server name for the provider to use
                self.expected_server = expected_server

                -- Determine status for color coding
                local has_lsp_server_errors = false

                -- Check for LSP server/client issues only
                for _, client in ipairs(active_servers) do
                  if vim.lsp.client_is_stopped(client.id) or not client.initialized then
                    has_lsp_server_errors = true
                    break
                  end
                end

                local has_lsp_servers = #active_servers > 0

                if has_lsp_server_errors then
                  self.status = 'error' -- Red for LSP server errors only
                elseif expected_server and not has_lsp_servers then
                  self.status = 'error' -- Red for missing expected LSP
                elseif has_lsp_servers then
                  self.status = 'working' -- Green for working LSP servers
                else
                  self.status = 'fallback' -- Blue for nvim fallback
                end
              end,
              provider = function(self)
                -- If we expect an LSP but don't have one, show the expected server name
                if self.status == 'error' and self.expected_server then
                  return self.expected_server
                else
                  -- Use the normal LSP component logic
                  return require('ui.components.lsp').server()
                end
              end,
              update = { 'LspAttach', 'LspDetach', 'BufEnter' },
              hl = function(self)
                -- Use cached status for zsh-style color coding
                if self.status == 'error' then
                  return { fg = self.colors.error }
                elseif self.status == 'working' then
                  return { fg = self.colors.working }
                else
                  return { fg = self.colors.fallback }
                end
              end,
            },
            {
              init = fn { 'ui.components.harpoon.cache', args = 1 },
              provider = function(self) return self.display_text end,
              update = { 'BufEnter' },
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
            Align,
            RightmostIcon,
            TargetFilename,
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
  -- Disabled: spinner removed from statusline
  -- {
  --   'linrongbin16/lsp-progress.nvim',
  --   opts = {},
  -- },
}
