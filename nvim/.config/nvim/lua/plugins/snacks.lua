return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = false },
    quickfile = { enabled = true },
    dashboard = { enabled = false },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    styles = {
      notification = {
        wo = { wrap = true },
      },
    },
    picker = {
      enabled = true,
      sources = {
        files = { hidden = true, ignored = true },
        git_files = { hidden = true },
      },
      actions = {
        trouble_open = function(picker) fn('trouble.sources.snacks::actions.trouble_open.action', picker)() end,
      },
      toggles = {
        follow = false,
      },
      win = {
        input = {
          keys = {
            ['<leader>'] = { 'toggle_focus', mode = { 'i', 'n' } },
            ['<F35>'] = { 'toggle_maximize', mode = { 'i', 'n' } },
            ['<F3>'] = { 'toggle_live', mode = { 'i', 'n' } },
            ['/'] = 'toggle_focus',
            ['<c-w>'] = { '<c-s-w>', mode = { 'i' }, expr = true, desc = 'delete word' },
            ['<a-d>'] = { 'inspect', mode = { 'n', 'i' } },
            ['<a-p>'] = false,
            ['<a-w>'] = false,
            ['<c-a>'] = false,
            ['<c-b>'] = false,
            ['<c-d>'] = false,
            ['<c-j>'] = false,
            ['<c-k>'] = false,
            ['<c-p>'] = { 'list_up', mode = { 'i', 'n' } },
            ['<c-q>'] = false,
            ['<c-s>'] = false,
            ['<c-t>'] = false,
            ['<c-u>'] = false,
            ['<c-v>'] = false,
            ['<c-r>#'] = false,
            ['#'] = { 'insert_alt', mode = 'i' },
            ['<c-r>%'] = false,
            ['%'] = { 'insert_filename', mode = 'i' },
            ['<c-r><c-a>'] = false,
            ['*'] = { 'insert_cWORD', mode = 'i' },
            -- TODO: Map it to something more sensible
            ['<c-r><c-f>'] = false, -- { 'insert_file', mode = 'i' },
            ['<c-r><c-l>'] = false, -- { 'insert_line', mode = 'i' },
            ['<c-r><c-p>'] = false, -- { 'insert_file_full', mode = 'i' },
            ['<c-r><c-w>'] = false, -- { 'insert_cword', mode = 'i' },
            ['<c-w>H'] = false,
            ['<c-w>J'] = false,
            ['<c-w>K'] = false,
            ['<c-w>L'] = false,
            ['<m-m>'] = 'layout_left',
            ['<m-n>'] = 'layout_bottom',
            ['<m-e>'] = 'layout_top',
            ['<m-o>'] = 'layout_right',
            j = false,
            k = false,
          },
        },
        list = {
          keys = {
            ['<leader>'] = 'cancel',
            h = { { 'cycle_win', 'cycle_win', 'preview_scroll_down' } },
            gG = 'select_all',
            x = 'trouble_open',
            ['_'] = 'edit_split',
            ['|'] = 'edit_vsplit',
            ['<F35>'] = 'toggle_maximize',
            ['<m-m>'] = 'layout_left',
            ['<m-n>'] = 'layout_bottom',
            ['<m-e>'] = 'layout_top',
            ['<m-o>'] = 'layout_right',
            ['?'] = 'toggle_help_list',
            ['/'] = false,
            j = false,
            k = false,
            zb = false,
            zt = false,
            zz = false,
            ['<a-d>'] = false,
            ['<a-p>'] = false,
            ['<a-w>'] = false,
            ['<c-b>'] = false,
            ['<c-d>'] = false,
            ['<c-f>'] = false,
            ['<c-j>'] = false,
            ['<c-k>'] = false,
            ['<c-t>'] = false,
            ['<c-u>'] = false,
            ['<c-w>H'] = false,
            ['<c-w>J'] = false,
            ['<c-w>K'] = false,
            ['<c-w>L'] = false,
          },
        },
      },
    },
    statuscolumn = { enabled = false },
    words = { enabled = false },
  },
  keys = {
    -- Top Pickers & Explorer
    key { 'grep', fn 'snacks.picker.grep' },
    key { 'find Buffers', fn 'snacks.picker.buffers' },
    key {
      'find dot files',
      function()
        require('snacks').picker.files {
          cwd = vim.fn.stdpath 'config',
          actions = {
            find_keymaps = fn 'snacks.picker.keymaps',
            find_autocmds = fn 'snacks.picker.autocmds',
          },
          win = {
            input = {
              keys = {
                k = 'find_keymaps',
                u = 'find_autocmds',
              },
            },
            list = {
              keys = {
                ['<space>'] = 'close',
              },
            },
          },
        }
      end,
    },
    key {
      'find git files',
      fn {
        {
          'snacks.picker.git_files',
          {
            actions = {
              find_files = function(picker)
                local current_prompt = picker.input:get()
                picker:close()
                require('snacks').picker.files { pattern = current_prompt }
              end,
            },
            win = {
              input = {
                keys = {
                  ['<F3>'] = { 'find_files', mode = 'i' },
                },
              },
            },
          },
        },
        when = function() return vim.fn.finddir('.git', '.;') ~= '' end,
        or_else = 'snacks.picker.files',
      },
    },
    key { 'find projects', fn 'snacks.picker.projects' },
    -- git
    key { 'Git Branches', fn 'snacks.picker.git_branches' },
    key { 'Git Browse', fn 'snacks.gitbrowse' },
    key { 'Git Log', fn 'snacks.picker.git_log' },
    key { 'Git Log line', fn 'snacks.picker.git_log_line' },
    key { 'find in Git Status', fn 'snacks.picker.git_status' },
    key { 'Git Stash', fn 'snacks.picker.git_stash' },
    key { 'Git Hunks', fn 'snacks.picker.git_diff' },
    key { 'Git log File', fn 'snacks.picker.git_log_file' },
    -- Grep
    key { 'grep lines', fn 'snacks.picker.lines' },
    key { 'grep buffers', fn 'snacks.picker.grep_buffers' },
    key { 'grep selection or word', fn 'snacks.picker.grep_word', mode = { 'n', 'x' } },
    -- search
    key { 'find commands', fn 'snacks.picker.commands' },
    key { 'find diagnostics', fn 'snacks.picker.diagnostics' },
    key { 'find diagnostics in buffer', fn 'snacks.picker.diagnostics_buffer' },
    motion { 'find help', fn 'snacks.picker.help' },
    key { 'find jumps', fn 'snacks.picker.jumps' },
    key { 'find man pages', fn 'snacks.picker.man' },
    key { 'find in undo history', fn 'snacks.picker.undo' },
    key { 'find in quickfix list', fn 'snacks.picker.qflist' },
    key { 'resume picker', fn 'snacks.picker.resume' },
    -- Other
    motion { 'zen mode', fn 'snacks.zen' },
    motion { 'zoom', fn 'snacks.zen.zoom' },
    motion { 'scratch buffer', fn 'snacks.scratch' },
    motion { 'select scratch buffer', fn 'snacks.scratch.select' },
    motion { 'notification history', fn 'snacks.notifier.show_history' },
    motion { 'dismiss all Notifications', fn 'snacks.notifier.hide' },
    motion { 'delete buffer', fn 'snacks.bufdelete' },
    key { 'file Rename', fn 'snacks.rename.rename_file' },
    key {
      'reFine search',
      function()
        -- Escape command mode first
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-c>', true, false, true), 'n', false)
        -- Then call the appropriate picker
        if vim.fn.getcmdtype() == '/' or vim.fn.getcmdtype() == '?' then
          require('snacks').picker.search_history()
        else
          require('snacks').picker.command_history()
        end
      end,
      mode = 'c',
    },
    -- { '/', function() Snacks.picker.smart() end, desc = 'Smart Find Files' },
    -- { '<leader>fr', function() Snacks.picker.recent() end, desc = 'Recent' },
  },
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...) Snacks.debug.inspect(...) end
        _G.bt = function() Snacks.debug.backtrace() end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        Snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>us'
        Snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>uw'
        Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map '<leader>uL'
        Snacks.toggle.diagnostics():map '<leader>ud'
        Snacks.toggle.line_number():map '<leader>ul'
        Snacks.toggle
          .option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
          :map '<leader>uc'
        Snacks.toggle.treesitter():map '<leader>uT'
        Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map '<leader>ub'
        Snacks.toggle.inlay_hints():map '<leader>uh'
        Snacks.toggle.indent():map '<leader>ug'
        Snacks.toggle.dim():map '<leader>uD'
      end,
    })
  end,
}
