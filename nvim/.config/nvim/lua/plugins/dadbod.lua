return {
  -- Core database interface
  {
    'tpope/vim-dadbod',
    cmd = 'DB',
  },

  -- Visual database UI
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = { 'tpope/vim-dadbod' },
    cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
    keys = {
      auto_select {
        'database',
        function()
          -- Find DBUI tab and switch to it, or open new DBUI tab
          local function find_dbui_tab()
            for _, tabnr in ipairs(vim.api.nvim_list_tabpages()) do
              for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(tabnr)) do
                local bufnr = vim.api.nvim_win_get_buf(winid)
                local ft = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
                if ft == 'dbui' then return tabnr end
              end
            end
            return nil
          end

          local function switch_to_dbui_tab()
            local dbui_tab = find_dbui_tab()
            if dbui_tab then
              vim.api.nvim_set_current_tabpage(dbui_tab)
              return true
            end
            return false
          end

          local function open_dbui_in_new_tab()
            vim.cmd 'tabnew'
            vim.cmd 'DBUI'
          end

          local function get_dbui_buffers_not_in_visible_tabs()
            local visible_buffers = {}
            -- Get all buffers in visible tabs (not the last tab)
            local tabs = vim.api.nvim_list_tabpages()
            for i = 1, #tabs - 1 do -- Skip last tab (hidden area)
              for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(tabs[i])) do
                visible_buffers[vim.api.nvim_win_get_buf(winid)] = true
              end
            end
            
            -- Find DBUI buffers not in visible tabs
            local hidden_dbui = {}
            for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_loaded(bufnr) and not visible_buffers[bufnr] then
                local ft = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
                if ft == 'dbui' then table.insert(hidden_dbui, bufnr) end
              end
            end
            return hidden_dbui
          end

          local function hide_dbui_tab()
            local dbui_tab = find_dbui_tab()
            if dbui_tab then
              -- Move tab to end to "hide" it (preserves layout)
              vim.api.nvim_set_current_tabpage(dbui_tab)
              vim.cmd('tabmove $')
              -- Switch to previous tab to exit the hidden DBUI tab
              vim.cmd('tabprevious')
              return true
            end
            return false
          end

          local function restore_dbui_tab(hidden_buffers)
            vim.cmd('tabnew')
            if #hidden_buffers > 0 then
              -- Restore first valid DBUI buffer
              for _, bufnr in ipairs(hidden_buffers) do
                if vim.api.nvim_buf_is_valid(bufnr) then
                  vim.cmd('buffer ' .. bufnr)
                  break
                end
              end
            else
              -- Open fresh DBUI
              vim.cmd('DBUI')
            end
          end

          -- Main cycling logic
          local dbui_tab = find_dbui_tab()
          local current_tab = vim.api.nvim_get_current_tabpage()
          local hidden_dbui = get_dbui_buffers_not_in_visible_tabs()
          
          if dbui_tab and dbui_tab ~= current_tab then
            -- DBUI tab exists but we're not in it, switch to it
            vim.api.nvim_set_current_tabpage(dbui_tab)
          elseif dbui_tab and dbui_tab == current_tab then
            -- We're in DBUI tab, hide it
            hide_dbui_tab()
          elseif #hidden_dbui > 0 then
            -- DBUI buffers exist but hidden, restore them
            restore_dbui_tab(hidden_dbui)
          else
            -- No DBUI anywhere, create fresh
            restore_dbui_tab({})
          end
        end,
      },
      -- { '<leader>df', '<cmd>DBUIFindBuffer<cr>', desc = 'Find Database Buffer' },
      -- { '<leader>dr', '<cmd>DBUIRenameBuffer<cr>', desc = 'Rename Database Buffer' },
      -- { '<leader>dq', '<cmd>DBUILastQueryInfo<cr>', desc = 'Last Query Info' },
      {
        '<leader>dT',
        '<cmd>tabnew | terminal ssh -L 9207:localhost:9207 meindev1@docker-1.mein.com.mx<cr>',
        desc = 'Manual SSH Tunnel',
      },
    },
    config = function()
      -- Load database connections
      local ok, connections = pcall(require, 'config.dadbod_connections')
      if ok then connections.setup() end

      -- Database UI configuration
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1
      vim.g.db_ui_win_position = 'left'
      vim.g.db_ui_winwidth = 40

      -- Save queries in project directory
      vim.g.db_ui_save_location = vim.fn.stdpath 'data' .. '/dadbod_ui'

      -- Auto-execute table helpers
      vim.g.db_ui_auto_execute_table_helpers = 1

      -- Use vertical splits for query results
      vim.g.db_ui_use_nvim_notify = 1

      -- Custom icons (using mini.icons compatible)
      -- vim.g.db_ui_icons = {
      --   expanded = {
      --     db = '▾ ',
      --     buffers = '▾ ',
      --     saved_queries = '▾ ',
      --     schemas = '▾ ',
      --     schema = '▾ פּ',
      --     tables = '▾ 藺',
      --     table = '▾ ',
      --   },
      --   collapsed = {
      --     db = '▸ ',
      --     buffers = '▸ ',
      --     saved_queries = '▸ ',
      --     schemas = '▸ ',
      --     schema = '▸ פּ',
      --     tables = '▸ 藺',
      --     table = '▸ ',
      --   },
      --   saved_query = '',
      --   new_query = '璘',
      --   tables = '離',
      --   buffers = '﬘',
      --   add_connection = '',
      --   connection_ok = '✓',
      --   connection_error = '✕',
      -- }
    end,
  },

  -- SQL autocompletion for blink.cmp
  {
    'kristijanhusak/vim-dadbod-completion',
    dependencies = { 'tpope/vim-dadbod', 'kristijanhusak/vim-dadbod-ui' },
    ft = { 'sql', 'mysql', 'plsql' },
    config = function()
      -- Configure vim-dadbod-completion for SQL files
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'sql', 'mysql', 'plsql' },
        callback = function()
          -- Set up dadbod completion for the buffer
          vim.opt_local.omnifunc = 'vim_dadbod_completion#omni'
        end,
      })

      -- Override LSP omnifunc for SQL files to use dadbod
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and vim.tbl_contains({ 'sql', 'mysql', 'plsql' }, vim.bo.filetype) then
            -- Prioritize dadbod completion over LSP for SQL files
            vim.opt_local.omnifunc = 'vim_dadbod_completion#omni'
          end
        end,
      })
    end,
  },

  -- Enhanced SQL language server
  {
    'nanotee/sqls.nvim',
    ft = { 'sql' },
    config = function()
      require('sqls').setup {
        picker = 'telescope',
      }
    end,
  },

  -- SQL snippets for common queries
  {
    'L3MON4D3/LuaSnip',
    optional = true,
    opts = function(_, opts)
      -- Add SQL snippets
      require('luasnip.loaders.from_vscode').lazy_load {
        paths = { vim.fn.stdpath 'data' .. '/lazy/friendly-snippets' },
      }
    end,
  },
}
