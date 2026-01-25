for k, v in pairs {
  -- Editing
  tabstop = 2,
  shiftwidth = 2,
  expandtab = true,
  smartindent = true,
  scrolloff = 8,
  fillchars = { eob = ' ' },
  colorcolumn = nil,
  foldmethod = 'expr',
  foldexpr = 'v:lua.vim.treesitter.foldexpr()',
  foldenable = false,

  -- UI
  relativenumber = true,
  signcolumn = 'no',
  foldcolumn = '0',
  splitright = true,
  splitbelow = true,
  equalalways = true,
  splitkeep = 'screen',
  tabline = [[%!v:lua.require'components'.tabline()]],
  showtabline = 2,
  statusline = ' ',
  laststatus = 0,
  cmdheight = 0,
  showcmd = false,
  showmode = false,

  -- Searching
  hlsearch = false,
  incsearch = true,
  ignorecase = true,
  smartcase = true,
  wildignorecase = true,
  completeopt = { 'menu', 'menuone', 'noselect' },
  pumheight = 10,

  -- Performance
  termguicolors = true,
  updatetime = 100,
  timeoutlen = 300,
  ttimeoutlen = 10,
  lazyredraw = true,
  synmaxcol = 240,

  -- Persistence
  clipboard = 'unnamedplus',
  autoread = true,
  swapfile = false,
  backup = false,
  writebackup = false,
  undofile = true,
} do
  vim.opt[k] = v
end
