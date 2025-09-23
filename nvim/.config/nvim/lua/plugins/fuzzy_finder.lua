return {
  'folke/snacks.nvim',
  ---@type snacks.Config
  opts = {
    picker = {
      enabled = true,
      sources = {
        files = { hidden = true, ignored = true },
        git_files = { hidden = true },
      },
      actions = {
        trouble_open = function(picker) fn { 'trouble.sources.snacks::actions.trouble_open.action', picker }() end,
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
        when = { fn { vim.fn.finddir, '.git', '.;' }, ne = '' },
        fn {
          'snacks.picker.git_files',
          {
            actions = {
              find_files = function(picker)
                local current_prompt = picker.input:get()
                picker:close()
                fn { 'snacks.picker.files', { pattern = current_prompt } }()
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
        or_else = fn 'snacks.picker.files',
      },
    },
    key { 'find projects', fn 'snacks.picker.projects' },
    -- git
    key { 'Git Branches', fn 'snacks.picker.git_branches' },
    key { 'Git Browse', fn 'snacks.gitbrowse' },
    key { 'Git Log', fn 'snacks.picker.git_log' },
    key { 'Git Log line', fn 'snacks.picker.git_log_line' },
    key { 'find in Git Status', fn 'snacks.picker.git_status' },
    key { 'Git Hunks', fn 'snacks.picker.git_diff' },
    key { 'Git log File', fn 'snacks.picker.git_log_file' },
    -- Grep
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
    key {
      'reFine search',
      proc {
        feed '<c-c>',
        fn {
          when = { vim.fn.getcmdtype, eq = '/' },
          fn 'snacks.picker.search_history',
          or_else = fn 'snacks.picker.command_history',
        },
      },
      mode = 'c',
    },
  },
}
