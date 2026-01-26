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
let &fillchars = 'eob: '
set foldmethod=expr nofoldenable foldcolumn=0
set laststatus=0 cmdheight=0 noshowcmd noshowmode
set statusline=\  showtabline=2

" Scrolloff helper
function! s:no_scrolloff(motion)
  set scrolloff=0
  execute 'normal! ' . a:motion
  call timer_start(0, {-> execute('set scrolloff=8')})
endfunction

" Mappings
let mapleader = ' '
nnoremap <silent> > j.
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

xnoremap s y:s/\(<C-R>=substitute(@", '\n$', '', '')<CR>\)/

nnoremap <A-n> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==

nnoremap ; :
xnoremap ; :
nnoremap <silent> : @:
xnoremap <silent> : @:

cnoremap <expr> ; getcmdline()[getcmdpos()-2] == '\' ? "\b;" : "\<CR>"
cnoremap <expr> <C-s> getcmdpos() > 1 ? '\1' . getcmdline()[getcmdpos()-2] . "\<CR>" : ''

nnoremap <silent> , ;
xnoremap <silent> , ;
nnoremap <silent> < ,

inoremap <C-c> <Esc>
xnoremap < <gv
xnoremap > >gv

inoremap , ,<C-g>u
inoremap . .<C-g>u
inoremap ; ;<C-g>u

nnoremap <leader>e :Ex<CR>
nnoremap <leader>f :find **/*<Left>

" Scrolloff-aware motions
nnoremap <silent> <C-d> <C-d>zz
nnoremap <silent> <C-u> <C-u>zz
nnoremap <silent> n nzz
nnoremap <silent> N Nzz

nnoremap <silent> j :<C-u>execute v:count ? 'call <SID>no_scrolloff('.v:count.'."j")' : 'normal! gj'<CR>
nnoremap <silent> k :<C-u>execute v:count ? 'call <SID>no_scrolloff('.v:count.'."k")' : 'normal! gk'<CR>

nnoremap <silent> zt :call <SID>no_scrolloff('zt')<CR>
nnoremap <silent> zb :call <SID>no_scrolloff('zb')<CR>
nnoremap <silent> zz :call <SID>no_scrolloff('zz')<CR>
nnoremap <silent> H :call <SID>no_scrolloff('H')<CR>
nnoremap <silent> M :call <SID>no_scrolloff('M')<CR>
nnoremap <silent> L :call <SID>no_scrolloff('L')<CR>
nnoremap <silent> G :<C-u>call <SID>no_scrolloff((v:count ? v:count : '').'G')<CR>
