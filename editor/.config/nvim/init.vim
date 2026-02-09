" Basic config in vimscript for portability in over ssh
" The bash s function loads this into a variable and sets 
" the vi function that executes vim or nvim with this config

" Options
set tabstop=2 shiftwidth=2 expandtab smartindent
set scrolloff=8
set relativenumber
set signcolumn=no
set splitright splitbelow equalalways splitkeep=screen
set nohlsearch incsearch ignorecase smartcase wildignorecase
set completeopt=menu,menuone,noselect pumheight=10
set termguicolors
set updatetime=100 timeoutlen=300 ttimeoutlen=10
set lazyredraw synmaxcol=240
set clipboard=unnamedplus autoread noswapfile nobackup nowritebackup undofile
set nofoldenable foldcolumn=0
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
nnoremap <silent> > j.
" Repeat over multiple lines (S-.)

" Vim surround at home
xnoremap s y:s/\(<C-R>=substitute(@", '\n$', '', '')<CR>\)/

" Quick line move (use yank and paste for complex cases)
nnoremap <A-n> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==

" Cmdline mode
nnoremap ; :
xnoremap ; :
" ; faster than :
nnoremap <silent> : @:
xnoremap <silent> : @:
" S-;
cnoremap <expr> ; getcmdline()[getcmdpos()-2] == '\' ? "\b;" : "\<CR>"
" smart ; also to execute
cnoremap <expr> <C-s> getcmdpos() > 1 ? '\1' . getcmdline()[getcmdpos()-2] . "\<CR>" : ''
" to use with custom visual mode s

" But then we need to move ; to ,
nnoremap <silent> , ;
xnoremap <silent> , ;
nnoremap <silent> < ,
" and S-, for backwards

" Sensible defaults
inoremap <C-c> <Esc>
" Saves block mode edits
xnoremap < <gv
xnoremap > >gv

" Undo breakpoints
inoremap , ,<C-g>u
inoremap . .<C-g>u
inoremap ; ;<C-g>u

" Fallbacks
nnoremap <leader>e :Ex<CR>
" file explorer
nnoremap <leader>f :find **/*<Left>
" picker

" Better scrolloff
function! s:no_scrolloff(motion)
  set scrolloff=0
  execute 'normal! ' . a:motion
  call timer_start(0, {-> execute('set scrolloff=8')})
endfunction

nnoremap <silent> <C-d> <C-d>zz
nnoremap <silent> <C-u> <C-u>zz
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> zt :call <SID>no_scrolloff('zt')<CR>
nnoremap <silent> zb :call <SID>no_scrolloff('zb')<CR>
nnoremap <silent> zz :call <SID>no_scrolloff('zz')<CR>
nnoremap <silent> H :call <SID>no_scrolloff('H')<CR>
nnoremap <silent> M :call <SID>no_scrolloff('M')<CR>
nnoremap <silent> L :call <SID>no_scrolloff('L')<CR>
nnoremap <silent> j :<C-u>execute v:count ? 'call <SID>no_scrolloff('.v:count.'."j")' : 'normal! gj'<CR>
nnoremap <silent> k :<C-u>execute v:count ? 'call <SID>no_scrolloff('.v:count.'."k")' : 'normal! gk'<CR>
nnoremap <silent> G :<C-u>call <SID>no_scrolloff((v:count ? v:count : '').'G')<CR>

" Custom commands
command! DelMacros for r in range(char2nr('a'), char2nr('z')) | call setreg(nr2char(r), '') | endfor | for r in range(char2nr('A'), char2nr('Z')) | call setreg(nr2char(r), '') | endfor

