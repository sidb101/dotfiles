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

" Re-list netrw trees on terminal focus (needs tmux focus-events) or tree entry.
" Workarounds: zero browse_split/chgwin so the refresh can't overwrite the open
" file; re-point t:netrw_lexbufnr so :Lex still toggles.
function! s:NetrwAutoRefresh() abort
  if get(s:, 'refreshing', 0)
    return
  endif
  let s:refreshing = 1
  let l:orig = win_getid()
  let l:split = get(g:, 'netrw_browse_split', 0)
  let l:chgwin = get(g:, 'netrw_chgwin', -1)
  let g:netrw_browse_split = 0
  let g:netrw_chgwin = -1
  try
    for l:win in getwininfo()
      if l:win.tabnr != tabpagenr() || getbufvar(l:win.bufnr, '&filetype') !=# 'netrw'
        continue
      endif
      noautocmd call win_gotoid(l:win.winid)
      let l:old_buf = bufnr('%')
      silent! execute "normal \<Plug>NetrwRefresh"
      if get(t:, 'netrw_lexbufnr', -1) == l:old_buf
        let t:netrw_lexbufnr = bufnr('%')
      endif
    endfor
  finally
    let g:netrw_browse_split = l:split
    let g:netrw_chgwin = l:chgwin
    noautocmd call win_gotoid(l:orig)
    let s:refreshing = 0
  endtry
endfunction
augroup netrw_autorefresh
  autocmd!
  autocmd FocusGained * call s:NetrwAutoRefresh()
  autocmd BufEnter * if &filetype ==# 'netrw' | call s:NetrwAutoRefresh() | endif
augroup END
