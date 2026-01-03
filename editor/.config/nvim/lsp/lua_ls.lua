return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      semantic = { enable = false },
      diagnostics = {
        -- globals = {
        --   'vim',
        --   'KeyboardLayout',
        --   'try',
        --   'keymap',
        --   'autocmd',
        --   'key',
        --   'on_selection',
        --   'auto_select',
        --   'insert',
        --   'motion',
        --   'operator',
        --   'edit',
        --   'fn',
        --   'proc',
        --   'cmd',
        --   'bang',
        --   'feed',
        --   'global',
        --   'Snacks',
        -- },
      },
    },
  },
}
