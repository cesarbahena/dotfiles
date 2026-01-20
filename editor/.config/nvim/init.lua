for k, v in pairs({
  -- Editing
  tabstop = 2,
  shiftwidth = 2,
  expandtab = true,
  smartindent = true,
  wrap = false,
  number = true,
  relativenumber = true,
  scrolloff = 8,
  fillchars = { eob = " " },
  colorcolumn = nil,

  -- Searching
  hlsearch = false,
  incsearch = true,
  ignorecase = true,
  smartcase = true,
  wildignorecase = true,
  completeopt = { "menu", "menuone", "noselect" },
  pumheight = 10,

  -- UI
  splitright = true,
  splitbelow = true,
  equalalways = false,
  splitkeep = "screen",
  termguicolors = true,
  laststatus = 3,
  cmdheight = 0,
  showcmd = false,
  showcmdloc = "statusline",
  showmode = false,
  foldmethod = "expr",
  foldexpr = "v:lua.vim.treesitter.foldexpr()",
  foldenable = false,

  -- Responsiveness
  updatetime = 100,
  timeoutlen = 300,
  ttimeoutlen = 10,
  lazyredraw = true,
  synmaxcol = 240,

  -- Persistence
  clipboard = "unnamedplus",
  autoread = true,
  swapfile = false,
  undofile = true,
}) do vim.opt[k] = v end

vim.g.mapleader = " "

local map = vim.keymap.set

local function no_scrolloff(motion, schedule_restore)
  return function()
    vim.o.scrolloff = 0
    vim.cmd("normal! " .. motion)
    if schedule_restore then
      vim.schedule(function() vim.o.scrolloff = 8 end)
    else
      vim.o.scrolloff = 8
    end
  end
end

map("n", "j", function()
  if vim.v.count > 0 then
    no_scrolloff(vim.v.count .. "j")()
  else
    vim.cmd("normal! gj")
  end
end)

map("n", "k", function()
  if vim.v.count > 0 then
    no_scrolloff(vim.v.count .. "k")()
  else
    vim.cmd("normal! gk")
  end
end)

-- Positioning commands (delayed scrolloff restore)
for _, key in ipairs({"zt", "zb", "zz"}) do
  map("n", key, no_scrolloff(key, true))
end

-- Screen and file motions
for _, key in ipairs({"H", "M", "L"}) do
  map("n", key, no_scrolloff(key))
end

map("n", "gg", function()
  no_scrolloff((vim.v.count > 0 and vim.v.count or "") .. "gg")()
end)

map("n", "G", function()
  no_scrolloff((vim.v.count > 0 and vim.v.count or "") .. "G")()
end)

map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzz")
map("n", "N", "Nzz")
map("i", ",", ",<C-g>u")
map("i", ".", ".<C-g>u")
map("i", ";", ";<C-g>u")
map("c", "<C-a>", "<Home>")
map("c", "<C-e>", "<End>")
map("c", ";", function()
  local cmd = vim.fn.getcmdline()
  local pos = vim.fn.getcmdpos()
  if pos > 1 and cmd:sub(pos-1, pos-1) == "\\" then
    return "\b;"  -- backspace to remove \, then insert literal ;
  else
    return "<CR>"
  end
end, { expr = true })
map("v", "<", "<gv")
map("v", ">", ">gv")
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")
map("n", "Y", "yyp")
map("n", "<", ",",  { silent = true })
map("n", ">", ".j", { silent = true })
map("n", ":", "@:", { silent = true })
map("n", ";", ":")
map("n", ",", ";",  { silent = true })

map("n", "Q", function()
  local count = vim.v.count > 0 and vim.v.count or 1
  for _ = 1, count do
    if not pcall(vim.cmd, "normal! @@") then
      pcall(vim.cmd, "normal! @q")
    end
  end
end, { silent = true })

-- LSP
vim.lsp.enable("lua_ls")

-- Plugin management
vim.pack.add({
  "https://github.com/ellisonleao/gruvbox.nvim",
})

-- Colorscheme
require("gruvbox").setup({
  transparent_mode = true,
})
vim.cmd("colorscheme gruvbox")

-- Statusline
vim.o.statusline = "%!v:lua.require'statusline'.render()"

vim.api.nvim_set_hl(0, "StatusLine", {bg = "NONE"})
vim.api.nvim_set_hl(0, "StatusLineNC", {bg = "NONE"})
vim.api.nvim_set_hl(0, "BashGray", {ctermfg = 240, fg = "#585858"})
vim.api.nvim_set_hl(0, "BashBold", {bold = true})
vim.api.nvim_set_hl(0, "BashGreen", {ctermfg = 46, fg = "#00ff5f"})
vim.api.nvim_set_hl(0, "BashYellow", {ctermfg = 226, fg = "#ffff00"})
vim.api.nvim_set_hl(0, "BashRed", {ctermfg = 196, fg = "#ff0000"})
vim.api.nvim_set_hl(0, "BashBlue", {ctermfg = 39, fg = "#00afff"})
