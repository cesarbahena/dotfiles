if vim.uv.fs_stat(vim.fn.stdpath 'data' .. '/site/pack/core/opt/blink.pairs/target/release/libblink_pairs.so') then
  require('blink.pairs').setup {}
end

require('blink.cmp').setup {
  enabled = function()
    return not vim.tbl_contains({ 'minifiles' }, vim.bo.filetype)
  end,
  completion = {
    documentation = { auto_show = true },
  },
  sources = {
    default = { 'snippets', 'lsp', 'path', 'buffer' },
    providers = {
      dadbod = {
        name = 'Dadbod',
        module = 'blink.cmp.sources.complete_func',
        opts = {
          complete_func = function()
            if vim.tbl_contains({ 'sql', 'mysql', 'plsql' }, vim.bo.filetype) then
              if vim.bo.omnifunc == '' then
                vim.bo.omnifunc = 'vim_dadbod_completion#omni'
              end
              return vim.bo.omnifunc
            end
            return nil
          end,
        },
      },
    },
    per_filetype = {
      sql = { 'dadbod', 'snippets', 'lsp', 'buffer' },
      mysql = { 'dadbod', 'snippets', 'lsp', 'buffer' },
      plsql = { 'dadbod', 'snippets', 'lsp', 'buffer' },
    },
  },
}
