autocmd vimenter * NERDTree
set relativenumber
nmap <F6> :NERDTreeToggle<CR>

syntax on
colorscheme monokai
let g:user_emmet_leader_key=','

set ts=2
set sw=4
" set sts=2
set et     "expand tabs to spaces

set ignorecase

autocmd FileType javascript.jsx setlocal commentstring={/*\ %s\ */}

execute "set <M-j>=\ej"
execute "set <M-k>=\ek"
nnoremap <M-j> j
nnoremap <M-k> k

nmap <M-j> [e
nmap <M-k> ]e

vmap <M-j> ]egv
vmap <M-k> [egv

call plug#begin()
Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
Plug 'townk/vim-autoclose'
Plug 'mattn/emmet-vim'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-unimpaired'

call plug#end()
