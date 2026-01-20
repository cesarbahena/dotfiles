require("mini.pick").setup()
vim.keymap.set("n", "<leader>f", ":Pick files<cr>")

require("mini.files").setup({
   mappings = {
    go_in       = "",
    go_in_plus  = "<cr>",
    go_out      = "-",
    go_out_plus = "",
  },
})
vim.keymap.set("n", "-", ":lua MiniFiles.open()<cr>")
