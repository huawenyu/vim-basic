if exists('g:loaded_hw_basic_conf') || &compatible
  finish
endif
let g:loaded_hw_basic_conf = 1
silent! let s:log = logger#getLogger(expand('<sfile>:t'))

if has("nvim")
    "let base16colorspace=256
    "let $NVIM_TUI_ENABLE_TRUE_COLOR=0
    "set synmaxcol=2048

    augroup terminal_setup | au!
        " auto enter insert mode when enter by mouse
        autocmd TermOpen * nnoremap <buffer><LeftRelease> <LeftRelease>i
        " auto enter insert mode when enter by key
        autocmd BufEnter term://* startinsert
        autocmd TermOpen * tnoremap <Esc><Esc> <c-\><c-n>
        autocmd FileType fzf tunmap <Esc><Esc>
    augroup end
else
    "set term=xterm-256color
endif

if WINDOWS()
    set guifont=Courier:h10:cANSI
else
    set guifont=Liberation\ Mono\ 13
endif

scriptencoding utf-8

set formatoptions+=m
set formatoptions+=B
set ffs=unix,dos,mac
set clipboard^=unnamed,unnamedplus

if exists("g:vim_confi_option") && g:vim_confi_option.view_folding
    if has('folding')
        set foldenable
        set fdm=indent
        set foldlevel=99
    endif
endif

if has('autocmd')
  filetype plugin indent on
endif
if has('syntax') && !exists('g:syntax_on')
    syntax enable
endif

" Disable any use of bold fonts
set t_md=
set t_vb=
set hidden
set ttyfast     | " u got a fast terminal
set lazyredraw  | " to avoid scrolling problems
"set autoread
set bs=eol,start,indent     | " set backspace pass another line

set showmatch
set matchtime=2     | " set match's seconds

set showmode
set linespace=0
set winminheight=0
" Disable preview window in neosnippet candidates.
set completeopt-=preview

" " Vim status bar prediction/completion
" "set wildmode=longest,list,full
" set wildmode=longest:full,full
" set wildmenu

" syntax enable
syntax on
" Vim slow reading very long lines
set synmaxcol=200
syntax on
set synmaxcol=200

"Set by
"  :colorscheme <enter>
"Check-Current-Color
"  :echo g:colors_name
"
" default colorscheme
set background=dark
if HasPlug('jellybeans.vim')
    "set t_Co=256
    silent! colorscheme jellybeans

    "====status bar colors===
    " au InsertEnter * hi statusline guifg=black guibg=#d7afff ctermfg=black ctermbg=magenta
    " au InsertLeave * hi statusline guifg=black guibg=#8fbfdc ctermfg=black ctermbg=cyan
    " hi statusline guifg=black guibg=#8fbfdc ctermfg=black ctermbg=cyan

    " hi Statusline   guifg==#444444 guibg=#dadada ctermfg=238 ctermbg=253
    " hi StatusLineNC guifg=#808080  guibg=#080808 ctermfg=244 ctermbg=232
endif

"different colorscheme for ruby and markdown
" if HasPlug('material.nvim')
"     autocmd FileType markdown colorscheme material-deep-ocean
" endif

autocmd FileType expect set ft=tcl
" if HasPlug('holokai')
"     autocmd FileType tcl colorscheme holokai
" endif

if has('mouse')
  set mouse=a
  set mousefocus
endif
set foldmethod=manual

" C indent {
"set smartindent
"set cindent
"set cinoptions=:0,l1,t0,g0,(0
"}

set winaltkeys=no   " Vim will use Alt, so disable windows ALT trigger menu

set ignorecase
set smartcase
set hlsearch
set incsearch

if &history < 1000
    set history=1000
endif
if &undolevels < 1000
    set undolevels=1000
endif

if has('multi_byte')
    set encoding=utf-8      " set inner code
    "set fileencoding=utf-8  " set file default encode
    set fileencodings=ucs-bom,utf-8,gbk,gb18030,big5,euc-jp,latin1      " open file decode orders
endif

"set shortmess+=a
"set shortmess=atI
"set shortmess-=oO
"set shortmess=aoOtTI
set shortmess-=S
" Disable echomsg filename
set shortmess+=F
set shortmess+=filmnrxoOtT  " Abbrev. of messages (avoids 'hit enter')
"set paste           " conflict with auto-pairs, delimitmate, auto-close plugin
"set showcmd
set cmdheight=2    " fix: Vim asks me 'Press Enter or type command to continue' at startup.
set splitbelow
set splitright

if exists("g:vim_confi_option") && g:vim_confi_option.auto_chdir
    set autochdir       " if work with shell or cscope, please not change work-dir
else
    set noautochdir
end

set sessionoptions-=options    " do not store global and local values in a session
set ssop-=folds      " do not store folds
set ssop+=curdir     " do not store absolute path
set ssop-=sesdir     " work under current dir as relative path

" Check: verbose set modeline?
" Maybe it's better to enable the modeline
if exists("g:vim_confi_option")
    if g:vim_confi_option.modeline
        set modeline
    else
        set nomodeline
    endif
endif

set visualbell
set noerrorbells

if exists("g:vim_confi_option") && g:vim_confi_option.wrapline
    set wrap linebreak nolist
else
    set list nowrap nolinebreak
endif

set nobackup
set noswapfile
set nowritebackup
set noshowmode
set nowrapscan
set showbreak=↪ |"⇇
set noshowmatch

" Maybe only neovim support:
"   https://vi.stackexchange.com/questions/18344/how-to-change-jumplist-behavior/23117
if has('nvim')
    set jumpoptions+=stack
endif

if exists("g:vim_confi_option") && g:vim_confi_option.show_number
    set number
else
    set nonumber
endif

" Stay in same column while navigating up and down
"set virtualedit=all    | " shouldn't set, for it disable the left move when in start-of-line
set virtualedit=block
set nostartofline

" Check which script change the config value
"   :verbose set tabstop sw softtabstop expandtab ?
set tabstop=4
set shiftwidth=4
set softtabstop=4
set textwidth=180
"set noexpandtab    | " editorconfig-vim in charge of it

"set iskeyword-=.                    " '.' is an end of word designator
"set iskeyword-=#                    " '#' is an end of word designator
"set iskeyword-=-                    " '-' is an end of word designator

set suffixes=.bak,~,.o,.h,.info,.swp,.obj,.pyc,.pyo,.egg-info,.class
set wildignorecase
" vimgrep ignore
set wildignore+=*.so,*.swp,*.zip,*/vendor/*,*/\.git/*,*/\.svn/*,objd/**,obj/**,*/tmp/*,*.tmp
set wildignore+=*.o,*.obj,.hg,*.pyc,.git,*.rej,*.orig,*.gcno,*.rbc,*.class,.svn,coverage/*,vendor
set wildignore+=*.gif,*.png,*.map
set wildignore+=*.d
set wildignore=*.o,*.obj,*~,*.exe,*.a,*.pdb,*.lib "stuff to ignore when tab completing
set wildignore+=*.so,*.dll,*.swp,*.egg,*.jar,*.class,*.pyc,*.pyo,*.bin,*.dex
set wildignore+=*.zip,*.7z,*.rar,*.gz,*.tar,*.gzip,*.bz2,*.tgz,*.xz    " MacOSX/Linux
set wildignore+=*DS_Store*,*.ipch
set wildignore+=*.gem
set wildignore+=*.png,*.jpg,*.gif,*.bmp,*.tga,*.pcx,*.ppm,*.img,*.iso
set wildignore+=*.so,*.swp,*.zip,*/.Trash/**,*.pdf,*.dmg,*/.rbenv/**
set wildignore+=*/.nx/**,*.app,*.git,.git
set wildignore+=*.wav,*.mp3,*.ogg,*.pcm
set wildignore+=*.mht,*.suo,*.sdf,*.jnlp
set wildignore+=*.chm,*.epub,*.pdf,*.mobi,*.ttf
set wildignore+=*.mp4,*.avi,*.flv,*.mov,*.mkv,*.swf,*.swc
set wildignore+=*.ppt,*.pptx,*.docx,*.xlt,*.xls,*.xlsx,*.odt,*.wps
set wildignore+=*.msi,*.crx,*.deb,*.vfd,*.apk,*.ipa,*.bin,*.msu
set wildignore+=*.gba,*.sfc,*.078,*.nds,*.smd,*.smc
set wildignore+=*.linux2,*.win32,*.darwin,*.freebsd,*.linux,*.android


let g:vim_basic_map = get(g:, 'vim_basic_map', 1)
if g:vim_basic_map

    " URL encode a string. ie. Percent-encode characters as necessary.
    function! s:urlEncode(string)
        let result = ""
        let characters = split(a:string, '.\zs')
        for character in characters
            if character == " "
                let result = result . "+"
            elseif <SID>urlCharNeedEncoding(character)
                let i = 0
                while i < strlen(character)
                    let byte = strpart(character, i, 1)
                    let decimal = char2nr(byte)
                    let result = result . "%" . printf("%02x", decimal)
                    let i += 1
                endwhile
            else
                let result = result . character
            endif
        endfor

        return result
    endfunction

    " Returns 1 if the given character should be percent-encoded in a URL encoded
    " string.
    function! s:urlCharNeedEncoding(character)
        let ascii_code = char2nr(a:character)
        if ascii_code >= 48 && ascii_code <= 57
            return 0
        elseif ascii_code >= 65 && ascii_code <= 90
            return 0
        elseif ascii_code >= 97 && ascii_code <= 122
            return 0
        elseif a:character == "-" || a:character == "_" || a:character == "." || a:character == "~"
            return 0
        endif

        return 1
    endfunction

    " Function to check if a string is a valid file path format
    function! s:IsValidFilePath(path)
        " Extract the directory part from the path
        let l:dir = fnamemodify(a:path, ':h')

        " Check if the directory exists
        if isdirectory(l:dir)
            return 1
        else
            return 0
        endif
    endfunction

    function! s:IsValidTldrFilePath(words)
        let l:__func__ = "IsValidTldrFilePath() "
        let results = system('tldr -l | grep "' .. a:words .. '"')
        if v:shell_error
            return ""
        endif

        let output = system('tldr -m "' .. a:words .. '"')
        let first_line = split(output, '\n')[0]
        let strArr = split(first_line, '\s\+')
        silent! call s:log.info(l:__func__, "split ", strArr)
        if len(strArr) > 1 && filereadable(expand(strArr[1]))
            silent! call s:log.info(l:__func__, "file ", strArr[1])
            return expand(strArr[1])
        endif

        silent! call s:log.info(l:__func__, "not a file")
        return ""
    endfunction

    function! s:GuessLink(mode)
        let l:__func__ = "GuessLink() "
        let urlLink = hw#misc#GetWord('http')
        if len(urlLink) > 0
            exec 'W3mTab '..urlLink
            return
        endif

        let file_info = utils#GetFileFrmCursor()
        if len(file_info) > 0
            let fname = file_info[0]
            if fname[0:0] !=  '/'
                let fname = getcwd() .. '/' .. fname
            endif

            let l:bn = bufnr(fname)
            if l:bn > 0
                call utils#PreviewTheCmd("buffer " .. l:bn .. "|" .. file_info[2] .. "|normal " .. "mO")
                return
            elseif filereadable(fname)
                call utils#PreviewTheCmd("edit " .. file_info[0] .. "|normal " .. "mO")
                return
            endif
        endif

        if &ft == "markdown" || &ft == "vim"
            " file -> tldr local file -> word search
            if len(file_info) > 0 && s:IsValidFilePath(fname)
                call utils#PreviewTheCmd("edit " .. file_info[0] .. "|normal " .. "mO")
                return
            else
                let words = hw#misc#GetWord(a:mode)
                let tldrFile = s:IsValidTldrFilePath(words)
                if len(tldrFile) > 0
                    call utils#PreviewTheCmd("edit " .. tldrFile .. "|normal " .. "mO")
                    return
                endif

                silent! call s:log.info(l:__func__, "words=", words)
                if len(words) > 0
                    let searchUrl = 'http://www.google.com/search?q='..words
                    " let searchUrl = <SID>urlEncode(searchUrl)
                    silent! call s:log.info(l:__func__, "url=", searchUrl)
                    exec 'FloatermNew w3m '..searchUrl
                    return
                endif
            endif
        else
            silent! call s:log.info(l:__func__, "filePreview")

            if len(file_info) > 0
                call utils#PreviewTheCmd("edit " .. file_info[0] .. "|normal " .. "mO")
                return
            endif
        endif
    endfun

    nnoremap <silent>          gf :"open File:number          "<c-U>call utils#GotoFileWithLineNum(0)<CR>
    "nnoremap <silent> <leader>gf :"open File in preview window   "<c-U>call utils#PreviewTheCmd()<CR>
    nnoremap <silent>  <leader>gf     :"(tool)Goto file       "<c-U>call <SID>GuessLink('n')<cr>
    vnoremap <silent>  <leader>gf     :"(tool)Goto file       "<c-U>call <SID>GuessLink('v')<cr>

    if HasPlug('w3m.vim') | " {{{1
    endif
endif

" vim:set ft=vim et sw=4:
