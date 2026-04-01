require('blink.cmp').setup {
  enabled = function()
    return not vim.tbl_contains({ 'minifiles' }, vim.bo.filetype)
  end,
}