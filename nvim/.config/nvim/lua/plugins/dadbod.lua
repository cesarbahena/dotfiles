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
      { '<leader>db', '<cmd>DBUIToggle<cr>', desc = 'Toggle Database UI' },
      { '<leader>df', '<cmd>DBUIFindBuffer<cr>', desc = 'Find Database Buffer' },
      { '<leader>dr', '<cmd>DBUIRenameBuffer<cr>', desc = 'Rename Database Buffer' },
      { '<leader>dq', '<cmd>DBUILastQueryInfo<cr>', desc = 'Last Query Info' },
      { '<leader>dt', function()
          local script_path = vim.fn.stdpath('config') .. '/scripts/db_tunnel.sh'
          local choice = vim.fn.confirm('SSH Tunnel Management:', '&Start\n&Stop\n&Status\n&Test\n&Cancel', 3)
          if choice == 1 then
            -- Open in terminal for interactive input
            vim.cmd('tabnew | terminal ' .. script_path .. ' start')
          elseif choice == 2 then
            vim.cmd('!' .. script_path .. ' stop')
          elseif choice == 3 then
            vim.cmd('!' .. script_path .. ' status')
          elseif choice == 4 then
            vim.cmd('!' .. script_path .. ' test')
          end
        end, desc = 'Manage SSH Tunnel' },
      { '<leader>dT', '<cmd>tabnew | terminal ssh -L 9207:localhost:9207 meindev1@docker-1.mein.com.mx<cr>', desc = 'Manual SSH Tunnel' },
    },
    config = function()
      -- Load database connections
      local ok, connections = pcall(require, 'config.dadbod_connections')
      if ok then
        connections.setup()
      end
      
      -- Database UI configuration
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1
      vim.g.db_ui_win_position = 'left'
      vim.g.db_ui_winwidth = 40
      
      -- Save queries in project directory
      vim.g.db_ui_save_location = vim.fn.stdpath('data') .. '/dadbod_ui'
      
      -- Auto-execute table helpers
      vim.g.db_ui_auto_execute_table_helpers = 1
      
      -- Use vertical splits for query results
      vim.g.db_ui_use_nvim_notify = 1
      
      -- Custom icons (using mini.icons compatible)
      vim.g.db_ui_icons = {
        expanded = {
          db = '▾ ',
          buffers = '▾ ',
          saved_queries = '▾ ',
          schemas = '▾ ',
          schema = '▾ פּ',
          tables = '▾ 藺',
          table = '▾ ',
        },
        collapsed = {
          db = '▸ ',
          buffers = '▸ ',
          saved_queries = '▸ ',
          schemas = '▸ ',
          schema = '▸ פּ',
          tables = '▸ 藺',
          table = '▸ ',
        },
        saved_query = '',
        new_query = '璘',
        tables = '離',
        buffers = '﬘',
        add_connection = '',
        connection_ok = '✓',
        connection_error = '✕',
      }
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
      require('sqls').setup({
        picker = 'telescope',
      })
    end,
  },
  
  -- Database schema browser in Telescope
  {
    'nvim-telescope/telescope.nvim',
    optional = true,
    opts = function(_, opts)
      if not opts.extensions then opts.extensions = {} end
      opts.extensions.dadbod = {
        -- telescope-dadbod extension config
      }
    end,
  },
  
  -- SQL snippets for common queries
  {
    'L3MON4D3/LuaSnip',
    optional = true,
    opts = function(_, opts)
      -- Add SQL snippets
      require('luasnip.loaders.from_vscode').lazy_load({
        paths = { vim.fn.stdpath('data') .. '/lazy/friendly-snippets' }
      })
    end,
  },
}