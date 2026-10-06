" Shared by Vim (~/.vimrc) and Neovim (nvim/init.lua sources it) — install.sh
" symlinks this to ~/.vimrc.
syntax on
set relativenumber
set number
set autoread
autocmd FocusGained,BufEnter,CursorHold * checktime

filetype plugin indent on

set textwidth=80
set colorcolumn=80
" re-apply after every :colorscheme (a colorscheme resets highlights)
autocmd ColorScheme * highlight ColorColumn ctermbg=darkgrey guibg=#3c3c3c
colorscheme habamax
"set mouse=a

" netrw (file explorer)
let g:netrw_winsize = 25        " :Lex takes 25% of the window width
let g:netrw_banner = 0          " hide the header
let g:netrw_liststyle = 3       " tree view
let g:netrw_browse_split = 4    " open files in the previous window
