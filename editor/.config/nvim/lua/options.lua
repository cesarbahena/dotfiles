for k, v in pairs({
  -- Editing
  tabstop = 2,
  shiftwidth = 2,
  expandtab = true,
  smartindent = true,
  wrap = true,
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
  relativenumber = true,
  signcolumn = "no",
  foldcolumn = "0",
  splitright = true,
  splitbelow = true,
  equalalways = false,
  splitkeep = "screen",
  termguicolors = true,
  laststatus = 0,
  showtabline = 2,
  cmdheight = 0,
  showcmd = false,
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
