if vim.uv.fs_stat(vim.fn.stdpath 'data' .. '/site/pack/core/opt/blink.pairs/target/release/libblink_pairs.so') then
  require('blink.pairs').setup {}
end

require('blink.cmp').setup {
  enabled = function()
    return not vim.tbl_contains({ 'minifiles' }, vim.bo.filetype)
  end,
}
