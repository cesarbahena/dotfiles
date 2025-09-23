return {
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
      },
      routes = {
        {
          filter = {
            event = 'msg_show',
            any = {
              { find = '%d+L, %d+B' },
              { find = '; after #%d+' },
              { find = '; before #%d+' },
            },
          },
          view = 'mini',
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
    },
    keys = {
      { '<leader>sn', '', desc = '+noice' },
      {
        '<S-Enter>',
        function() require('noice').redirect(vim.fn.getcmdline()) end,
        mode = 'c',
        desc = 'Redirect Cmdline',
      },
      { '<leader>snl', function() require('noice').cmd 'last' end, desc = 'Noice Last Message' },
      { '<leader>snh', function() require('noice').cmd 'history' end, desc = 'Noice History' },
      { '<leader>sna', function() require('noice').cmd 'all' end, desc = 'Noice All' },
      { '<leader>snd', function() require('noice').cmd 'dismiss' end, desc = 'Dismiss All' },
      { '<leader>snt', function() require('noice').cmd 'pick' end, desc = 'Noice Picker (Telescope/FzfLua)' },
      {
        '<c-f>',
        function()
          if not require('noice.lsp').scroll(4) then return '<c-f>' end
        end,
        silent = true,
        expr = true,
        desc = 'Scroll Forward',
        mode = { 'i', 'n', 's' },
      },
      {
        '<c-b>',
        function()
          if not require('noice.lsp').scroll(-4) then return '<c-b>' end
        end,
        silent = true,
        expr = true,
        desc = 'Scroll Backward',
        mode = { 'i', 'n', 's' },
      },
    },
    config = function(_, opts)
      -- HACK: noice shows messages from before it was enabled,
      -- but this is not ideal when Lazy is installing plugins,
      -- so clear the messages in this case.
      if vim.o.filetype == 'lazy' then vim.cmd [[messages clear]] end
      require('noice').setup(opts)
    end,
  },

  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      dashboard = { enabled = false },
      indent = { enabled = true },
      input = { enabled = true },
      statuscolumn = { enabled = false },
      words = { enabled = false },
      notifier = {
        enabled = true,
        timeout = 3000,
      },
      styles = {
        notification = {
          wo = { wrap = true },
        },
      },
    },
    keys = {
      motion { 'zen mode', fn 'snacks.zen' },
      motion { 'zoom', fn 'snacks.zen.zoom' },
      motion { 'scratch buffer', fn 'snacks.scratch' },
      motion { 'select scratch buffer', fn 'snacks.scratch.select' },
      motion { 'notification history', fn 'snacks.notifier.show_history' },
      motion { 'dismiss all Notifications', fn 'snacks.notifier.hide' },
      motion { 'delete buffer', fn 'snacks.bufdelete' },
      key { 'file Rename', fn 'snacks.rename.rename_file' },
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
          Snacks.toggle.diagnostics():map '<leader>ud'
          Snacks.toggle
            .option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
            :map '<leader>uc'
          Snacks.toggle.treesitter():map '<leader>uT'
          Snacks.toggle.inlay_hints():map '<leader>uh'
          Snacks.toggle.indent():map '<leader>ug'
          Snacks.toggle.dim():map '<leader>uD'
        end,
      })
    end,
  },
}
