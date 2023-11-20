if exists('g:loaded_colorbox')
    finish
endif
let g:loaded_colorbox=1

let s:is_win = has('win32') || has('win64')

if s:is_win && &shellslash
    set noshellslash
    let s:cb_base = expand('<sfile>:p:h:h')
    set shellslash
else
    let s:cb_base = expand('<sfile>:p:h:h')
endif

function! colorbox#base_dir() abort
    return s:cb_base
  endfunction
