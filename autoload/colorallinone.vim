if exists('g:loaded_color_all_in_one')
    finish
endif
let g:loaded_color_all_in_one=1

let s:is_win = has('win32') || has('win64')

if s:is_win && &shellslash
    set noshellslash
    let s:caio_base = expand('<sfile>:p:h:h:h')
    set shellslash
else
    let s:caio_base = expand('<sfile>:p:h:h:h')
endif

function! colorallinone#base_dir() abort
    return s:caio_base
  endfunction
