if !exists("s:init")
    let s:init = 1
    silent! let s:log = logger#getLogger(expand('<sfile>:t'))
endif


if exists('*strcharpart')
    function! hw#misc#Strcharpart(...) abort "{{{3
        return call(function('strcharpart'), a:000)
    endf
else
    function! hw#misc#Strcharpart(...) abort "{{{3
        return call(function('strpart'), a:000)
    endf
endif

fun! s:isOnWord()
    return matchstr(getline('.'), '\%'.col('.').'c.') =~# '\k'
endf

" :display: tlib#selection#GetSelection(mode, ?mbeg="'<", ?mend="'>", ?opmode='selection')
" mode can be one of: selection, lines, block
function! hw#misc#GetSelection(mode, ...) range
    let l:__func__ = "hw#misc#GetSelection() "

    if a:0 >= 2
        let mbeg = a:1
        let mend = a:2
    else
        let mbeg = "'<"
        let mend = "'>"
    endif
    let opmode = a:0 >= 3 ? a:3 : 'selection'
    let l0   = line(mbeg)
    let l1   = line(mend)
    let text = getline(l0, l1)
    let c0   = col(mbeg)
    let c1   = col(mend)

    silent! call s:log.info(l:__func__, "beg=", mbeg, " end=", mend, " mode=", opmode, " l0=", l0, " l1=", l1, " c0=", c0, " c1=", c1)
    silent! call s:log.info(l:__func__, "len=", len(text[-1]), " ", text[-1])

    if opmode == 'block'
        let clen = c1 - c0
        call map(text, 'hw#misc#Strcharpart(v:val, c0, clen)')
    elseif opmode == 'selection'
        if c1 > 1
            "let text[-1] = hw#misc#Strcharpart(text[-1], 0, c1 - (a:mode == 'o' || c1 > len(text[-1]) ? 0 : 1))
            let text[-1] = hw#misc#Strcharpart(text[-1], 0, c1)
        endif
        if c0 > 1
            let text[0] = hw#misc#Strcharpart(text[0], c0 - 1)
        endif
    endif
    return text
endfunction


fun! s:getwordStd(mode, ...) range
    try
        return expand('<cword>')
    catch
        return ""
    endtry
endf



" Example:
" |/\zs|	\zs	\zs	anything, sets start of match
" |/\ze|	\ze	\ze	anything, sets end of match
"
" echo matchstr("Plug 'tpope/vim-sensible'", 'Plug\s\+''\zs[^'']\+\ze''\{-\}')
" echo matchstr("note:z.lua", 'note[.: @]\zs\S\+\ze[\s|$]\{-\}')
" echo matchstr("'@note:z.lua'", '\([''"]\)\zs.\{-}\ze\1')
" echo matchstr("@note:nvim", 'note[.: @]\zs.\{-}\ze[\}\]\) ,;''"]\{-\}$')
"
" echo matchstr("@note readme", '@note\s\+\zs\w\+\ze[\s|$]\{-\}')
" echo matchstr("@note z.lua ", '@note\s\+\zs\S\+\ze[\s|$]\{-\}')
" echo matchstr("@note:z.lua ", '@note\s\+\zs\w\+\ze[\s|$]\{-\}')
fun! s:getwordQuota(from) range
    let curline = getline('.')
    let notename = matchstr(curline, a:from. '\s\+''\zs[^'']\+\ze''\{-\}')
    if empty(notename)
        let notename = matchstr(curline, 'note[.: @]\zs.\{-}\ze[\}\]\) ,;''"]\{-\}$')
        if empty(notename) | return "" | endif
    endif

    let items = split(notename, '/')
    if len(items) < 2
        return notename
    else
        return items[1]
    endif
endf


" Example:
" echomsg "hello"
" let text = "Plug 'habamax/vim-evalvim', Cond(Mode(['editor',]))"
" echo match(text, "[\'\"/.,;: \t]", (getpos('.'))[2])
" echo match(text, "'", (getpos('.'))[2])
" echo getpos('.')
" echo match("testing", "..", 0, 2)
" @param strp  the split chars list, '[.,;: \t]'
" @param mode
fun! s:getwordVimplug(text, strpS, strpE) range
    if len(a:strpS) == 0 | return ''| endif
    if len(a:strpE) == 0 | return ''| endif
    let l:__func__ = "hw#misc s:getwordVimplug() "

    silent! call s:log.info(l:__func__, 'enter')
    let strpS = a:strpS
    let strpE = a:strpE
    let text = a:text
    let cpos = (getpos('.'))[2]

    " let text = ":display: tlib#selection#GetSelection(mode, ?mbeg=\"'<\", ?mend=\"'>\", ?opmode='selection')"
    " echo match(text, "[\?=\'\"/.,;: \t]", 10)

    " @evalStart
    " let text = "Plug 'habamax/vim-evalvim', Cond(Mode(['editor',]))"
    " let strpS = a:strpS
    " let strpE = "[\'\"/.,;: \t$]"
    " let text = "```graph-easy"
    let end = match(text, strpE, cpos)
    " echo end
    " echo 'plug='. text[14:end-1]
    " let strpS = a:strpS
    " let strpE = "[\'\"/.,;: \t]"
    " let cpos = 20
    if end < 1
        return '' |
    endif

    let start = 0
    let start2 = 0
    let c = 1
    while c < 100
        let c += 1
        let start2 = match(text, strpS, start)
        if start2 >= end | break | endif
        " echo "debug start2=". start2
        let start = start2 + 1
    endwhile

    if c == 100
        "echo "find fail: reach end"
        return '' |
    endif
    " echo 'plug-'. start. ':'. end. '='. text[start:(end-1)]
    " @evalEnd
    silent! call s:log.info(l:__func__, 'plug-'. start. ':'. end. '='. text[start:(end-1)])

    return text[start:(end-1)]
endf


" :display: tlib#selection#GetSelection(mode, ?mbeg="'<", ?mend="'>", ?opmode='selection')
" mode can be one of: selection, lines, block
fun! hw#misc#GetCursorWord()
    if ! s:isOnWord() | return '' | endif
    let l:__func__ = "hw#misc#GetCursorWord() "

    silent! call s:log.info(l:__func__, "enter ft=", &ft)
    if &ft=='vim'
        return s:getwordVimplug(getline('.')..' ', "[\?=\'\"/,;: \t]", "[\?=\'\",;: \t]")
    elseif &ft=='markdown' || &ft=='presenting_markdown'
        return s:getwordVimplug(getline('.')..' ', "[\?=`\'\"/,;: \t]", "[\?=`\'\",;: \t]")
    else
        try
            return expand('<cword>')
        catch
            return ""
        endtry
    endif
endf


" Example:
" nnoremap <leader>rr :<c-u>echo hw#misc#GetWord('n')<cr>
" vnoremap <leader>rr :<c-u>echo hw#misc#GetWord('v')<cr>
" @param mode: 'n' normal, 'v' selection
function! hw#misc#GetWord(mode)
    if a:mode is# 'v'
        let sel_str = hw#misc#GetSelection('')
        if !empty(sel_str)
            let sel_str = sel_str[0]
            if !empty(sel_str)
                return sel_str
            endif
        endif
    elseif a:mode is# 'http'
        let wordStr = s:getwordVimplug(getline('.')..' ', "[\(\'\" \t]", "[\)\'\" \t]")
        silent! call s:log.info(l:__func__, "debug:", wordStr)
        if wordStr =~ "^http"
            return wordStr
        endif
        return ""
    endif

    return hw#misc#GetCursorWord()
endfunction


" Example:
" let your_saved_mappings = Save_mappings(['<C-a>', '<C-b>', '<C-c>'], 'n', 1)
" ...
" call Restore_mappings(your_saved_mappings)
"
fu! hw#misc#SaveMaps(keys, mode, global) abort
    let mappings = {}

    if a:global
        for l:key in a:keys
            let buf_local_map = maparg(l:key, a:mode, 0, 1)

            sil! exe a:mode.'unmap <buffer> '.l:key

            let map_info        = maparg(l:key, a:mode, 0, 1)
            let mappings[l:key] = !empty(map_info)
                                \     ? map_info
                                \     : {
                                        \ 'unmapped' : 1,
                                        \ 'buffer'   : 0,
                                        \ 'lhs'      : l:key,
                                        \ 'mode'     : a:mode,
                                        \ }

            call hw#misc#RestoreMaps({l:key : buf_local_map})
        endfor

    else
        for l:key in a:keys
            let map_info        = maparg(l:key, a:mode, 0, 1)
            let mappings[l:key] = !empty(map_info)
                                \     ? map_info
                                \     : {
                                        \ 'unmapped' : 1,
                                        \ 'buffer'   : 1,
                                        \ 'lhs'      : l:key,
                                        \ 'mode'     : a:mode,
                                        \ }
        endfor
    endif

    return mappings
endfu


fu! hw#misc#RestoreMaps(mappings) abort

    for mapping in values(a:mappings)
        if !has_key(mapping, 'unmapped') && !empty(mapping)
            exe     mapping.mode
               \ . (mapping.noremap ? 'noremap   ' : 'map ')
               \ . (mapping.buffer  ? ' <buffer> ' : '')
               \ . (mapping.expr    ? ' <expr>   ' : '')
               \ . (mapping.nowait  ? ' <nowait> ' : '')
               \ . (mapping.silent  ? ' <silent> ' : '')
               \ .  mapping.lhs
               \ . ' '
               \ . substitute(mapping.rhs, '<SID>', '<SNR>'.mapping.sid.'_', 'g')

        elseif has_key(mapping, 'unmapped')
            sil! exe mapping.mode.'unmap '
                                \ .(mapping.buffer ? ' <buffer> ' : '')
                                \ . mapping.lhs
        endif
    endfor
endfu


if HasPlug('vim-floaterm') | " {{{1
fu! hw#misc#Execute(sel_mode, cmd, defaultCmd) abort
    if len(a:cmd) == 0 | return | endif

    silent execute ':FloatermKill! hwcmd'

    let sel_str = hw#misc#GetWord(a:sel_mode)
    if len(sel_str) > 0
        "let l:args = input(a:cmd. " ", sel_str)
        let l:title = a:cmd..":"..sel_str
        let l:command=':FloatermNew --name=hwcmd --position=bottom --autoclose=0 --height=0.4 --width=0.7 --title='. l:title
        let l:command= l:command. printf(" %s %s", a:cmd, sel_str)
        silent execute l:command
        stopinsert
    elseif len(a:defaultCmd) > 0
        execute a:defaultCmd
        return
    else
        echomsg "hw#misc#Execute(): Empty command!"
        return
    endif
endfu
endif


" Merge two dictionaries, also recursively merging nested keys.
" https://vi.stackexchange.com/questions/20842/how-can-i-merge-two-dictionaries-in-vim
" Use extend() if you don't need to merge nested keys.
fun! hw#misc#merge(defaults, override) abort
    let l:new = copy(a:defaults)
    for [l:k, l:v] in items(a:override)
        let l:new[l:k] = (type(l:v) is v:t_dict && type(get(l:new, l:k)) is v:t_dict)
                    \ ? hw#misc#merge(l:new[l:k], l:v)
                    \ : l:v
    endfor
    return l:new
endfun

