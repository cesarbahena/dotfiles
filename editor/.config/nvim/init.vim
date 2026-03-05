" Basic config in vimscript for portability in over ssh
" The bash s function loads this into a variable and sets 
" the vi function that executes vim or nvim with this config

" Options
set tabstop=2 shiftwidth=2 expandtab smartindent
set relativenumber signcolumn=no foldcolumn=0
set splitright splitbelow equalalways splitkeep=screen
set nohlsearch incsearch ignorecase smartcase wildignorecase
set completeopt=menu,menuone,noselect pumheight=10
set termguicolors updatetime=100 timeoutlen=300 ttimeoutlen=10 synmaxcol=240
set clipboard=unnamedplus autoread noswapfile nobackup nowritebackup undofile
let &fillchars = 'eob: '

" Mappings
nnoremap <space> <nop>
let mapleader = ' '

function! s:repeat_macro()
  let l:count = v:count > 0 ? v:count : 1
  for i in range(l:count)
    try
      execute 'normal! @@'
    catch
      execute 'normal! @q'
    endtry
  endfor
endfunction
nnoremap <silent> Q :<C-u>call <SID>repeat_macro()<CR>

" Quick line move (use yank and paste for complex cases)
nnoremap <A-m> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==

" Sensible defaults
xnoremap < <gv
xnoremap > >gv
nnoremap <silent> <C-d> <C-d>zz
nnoremap <silent> <C-u> <C-u>zz
nnoremap <silent> n nzz
nnoremap <silent> N Nzz

" Undo breakpoints
inoremap , ,<C-g>u
inoremap . .<C-g>u
inoremap ; ;<C-g>u

" Fallbacks
nnoremap <leader>e :Ex<CR>
" file explorer
nnoremap <leader>f :find **/*<Left>
" picker

" Custom commands
command! DelMacros for r in range(char2nr('a'), char2nr('z')) | call setreg(nr2char(r), '') | endfor | for r in range(char2nr('A'), char2nr('Z')) | call setreg(nr2char(r), '') | endfor

