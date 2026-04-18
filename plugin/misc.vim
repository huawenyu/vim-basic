if exists('g:loaded_basic_misc') || &cp
    finish
endif
let g:loaded_basic_misc = 1

"autocmd BufWinEnter,WinEnter term://* startinsert
autocmd BufEnter * if &buftype == 'terminal' | silent! normal A | endif
autocmd BufWinEnter,WinEnter * if &buftype == 'terminal' | silent! normal A | endif

""command! -bang -nargs=* -complete=file Make AsyncRun -program=make @ <args>
"command! -nargs=+ -bang -complete=shellcmd
"      \ NeoMake execute ':NeomakeCmd make '. <q-args>

command! -nargs=1 Silent
  \ | execute ':silent !'.<q-args>
  \ | execute ':redraw!'


