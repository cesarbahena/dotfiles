" Basic config in vimscript for portability in over ssh
" The bash s function loads this into a variable and sets
" the vi function that executes vim or nvim with this config

set relativenumber signcolumn=no foldcolumn=0 colorcolumn=80
set tabstop=2 shiftwidth=2 expandtab smartindent
set incsearch ignorecase smartcase wildignorecase
set completeopt=menu,menuone,noselect pumheight=10
set clipboard=unnamedplus undofile autoread noswapfile
set laststatus=0 cmdheight=0 shortmess+=S
set termguicolors nohlsearch noshowcmd noruler
hi ColorColumn guibg=#1f1f1f
let &fillchars = "eob: "
let mapleader="\<C-k>"

nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap n nzz
nnoremap N Nzz
nnoremap J mzJ`z
nnoremap =ap ma=ap'a
xnoremap < <gv
xnoremap > >gv
inoremap , ,<C-g>u
inoremap . .<C-g>u
inoremap ; ;<C-g>u
nnoremap <leader>e :Ex<CR>
nnoremap <leader>f :find **/*<Left>

augroup core
  autocmd!

  " Restore cursor position
  autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   execute "normal! g`\"" |
        \ endif

  " Close with q
  autocmd FileType help,qf nnoremap <buffer> q :close<CR>

  " Update current file in tmux statusline
  autocmd BufEnter *
        \ call system(
        \ 'tmux setenv -g TMUX_NVIM_FILE ' .
        \ shellescape(expand('%:t') == '' ? '[No Name]' : expand('%:t'))
        \ )

augroup END
