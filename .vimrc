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

call plug#begin()
Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
Plug 'townk/vim-autoclose'
Plug 'mattn/emmet-vim'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'tpope/vim-commentary'

call plug#end()
