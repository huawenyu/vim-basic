" ============================================================================
" vim-basic/plugin/config.vim
" NOTE: Migrated to init.lua (lazy.nvim):
"   - Terminal setup (lines 12-19)
"   - formatoptions, fileformats, clipboard (lines 27-30)
"   - GuessLink function and gf/<leader>gf mappings (lines 305-366)
" ============================================================================

if exists('g:loaded_hw_basic_conf') || &compatible
  finish
endif
let g:loaded_hw_basic_conf = 1
silent! let s:log = logger#getLogger(expand('<sfile>:t'))

scriptencoding utf-8
set guifont=Liberation\ Mono\ 13

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

set t_md=
set t_vb=
set hidden
set ttyfast
set lazyredraw
set bs=eol,start,indent

set showmatch
set matchtime=2

set showmode
set linespace=0
set winminheight=0
set completeopt-=preview

syntax on
set synmaxcol=200

set background=dark
if v:lua.HasPlug('jellybeans.vim')
    silent! colorscheme jellybeans
endif

autocmd FileType expect set ft=tcl

if has('mouse')
  set mouse=a
  set mousefocus
endif
set foldmethod=manual

set winaltkeys=no

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
    set encoding=utf-8
    set fileencodings=ucs-bom,utf-8,gbk,gb18030,big5,euc-jp,latin1
endif

set shortmess-=S
set shortmess+=F
set shortmess+=filmnrxoOtT
set cmdheight=2
set splitbelow
set splitright

if exists("g:vim_confi_option") && g:vim_confi_option.auto_chdir
    set autochdir
else
    set noautochdir
endif

set sessionoptions-=options
set ssop-=folds
set ssop+=curdir
set ssop-=sesdir

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
set showbreak=↪
set noshowmatch

if has('nvim')
    set jumpoptions+=stack
endif

if exists("g:vim_confi_option") && g:vim_confi_option.show_number
    set number
else
    set nonumber
endif

set virtualedit=block
set nostartofline

set tabstop=4
set shiftwidth=4
set softtabstop=4
set textwidth=180

set suffixes=.bak,~,.o,.h,.info,.swp,.obj,.pyc,.pyo,.egg-info,.class
set wildignorecase
set wildignore+=*.so,*.swp,*.zip,*/vendor/*,*/\.git/*,*/\.svn/*,objd/**,obj/**,*/tmp/*,*.tmp
set wildignore+=*.o,*.obj,.hg,*.pyc,.git,*.rej,*.orig,*.gcno,*.rbc,*.class,.svn,coverage/*,vendor
set wildignore+=*.gif,*.png,*.map
set wildignore+=*.d
set wildignore=*.o,*.obj,*~,*.exe,*.a,*.pdb,*.lib
set wildignore+=*.so,*.dll,*.swp,*.egg,*.jar,*.class,*.pyc,*.pyo,*.bin,*.dex
set wildignore+=*.zip,*.7z,*.rar,*.gz,*.tar,*.gzip,*.bz2,*.tgz,*.xz
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

" vim:set ft=vim et sw=4:
