" Initialization {{{
set nocompatible " Should be disabled upon finding ~/.vimrc, but better safe than sorry
filetype off " Disable for Vundle
" Vundle & Plugins {{{

if has("unix")
    set rtp+=~/.vim/bundle/Vundle.vim
    call vundle#begin()
elseif has("win32")
    set rtp+=~/vimfiles/bundle/Vundle.vim
    let path='~/vimfiles/bundle'
    call vundle#begin(path)
endif

Plugin 'gmarik/Vundle.vim'

Plugin 'flazz/vim-colorschemes'

"Plugin 'vim-scripts/hexHighlight.vim'

"Plugin 'godlygeek/tabular'

"Plugin 'shawncplus/Vim-toCterm'

Plugin 'itchyny/lightline.vim'

"Plugin 'scrooloose/syntastic'
Plugin 'w0rp/ale'

Plugin 'Valloric/YouCompleteMe'
Plugin 'rdnetto/YCM-Generator'

Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'

Plugin 'majutsushi/tagbar'

Plugin 'mbbill/undotree'

Plugin 'tpope/vim-fugitive'

Plugin 'yggdroot/indentline'

Plugin 'justinmk/vim-sneak'

"Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-repeat'

Plugin 'lervag/vimtex'

"Javascript highligting
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'

call vundle#end()
" }}}
filetype plugin indent on
" }}}
" Colors and Font {{{
syntax enable " Turn on syntax highlighting

silent! colorscheme molokai " Sets colorscheme

if has('gui_running')
    if has("win32")
        set guifont=consolas:h12 " Change to your liking
    elseif has("unix")
        set guifont=Source\ Code\ Pro\ Medium\ 10 " Change to your liking
    endif
endif

set background=dark " Sets background to be dark (noshitsherlock)
set encoding=utf-8 " Set utf-8 to support more characters
set t_Co=256 " Set terminal-vi to use 256 colors

"Set bgcolor to termina color to remove padding
"highlight normal ctermbg=NONE 

let g:lightline = {
            \ 'colorscheme': 'wombat',
            \ } " Change color of lightline to match with colorscheme
" }}}
" Indentation {{{
set autoindent " Copy indentation from previous line
set expandtab " Make a tab be spaces
set shiftwidth=4 " Make an indent be 4 spaces
set softtabstop=4 " Remove 4 spaces in sequence if found while backspacing
set tabstop=4 " Set a tab to be 4 spaces large

" Tab can be used anywhere on line to change indent
nnoremap <tab> ==
" }}}
" Leader Commands {{{
" let mapleader = "," " Rebind leader to be comma
let mapleader = "\<Space>"
let maplocalleader = ","

" Call :noh upon hitting <leader> + space, removing highlighting from search
nnoremap <leader><space> :noh<CR>

" Toggle NERDTree in all tabs
map <leader>n <plug>NERDTreeTabsToggle<CR>

" Toggle tagbar
map <leader>b :TagbarToggle<CR>

" Goto tag
nnoremap <leader>gd <C-]> 
" Goto tag in new tab
nnoremap <leader>gD :tab split<CR>:exec("tag ".expand("<cword>"))<CR>

" }}}
" Plugin settings {{{
" vimtex {{{
let g:vimtex_view_general_viewer = 'okular'
let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
let g:vimtex_view_general_options_latexmk = '--unique'
" }}}
" }}}
" Text/File Navigation {{{

" Sneak navigation {{{
"replace f with 1-char Sneak
nmap f <Plug>Sneak_f
nmap F <Plug>Sneak_F
xmap f <Plug>Sneak_f
xmap F <Plug>Sneak_F
omap f <Plug>Sneak_f
omap F <Plug>Sneak_F
"replace t with 1-char Sneak
nmap t <Plug>Sneak_t
nmap T <Plug>Sneak_T
xmap t <Plug>Sneak_t
xmap T <Plug>Sneak_T
omap t <Plug>Sneak_t
omap T <Plug>Sneak_T

" }}}

set nu
set relativenumber " Have line numbers relative to your position
set showmatch " Show opening and closing braces
set wildmenu " Tab completion will show what other files there are
set wrap " Wrap visually but not in buffer
set linebreak " Only wraps at appropriate characters
set nolist " List fucks wrapping up, so lets disable it

"TODO: Make movement with wraps not retarded

autocmd StdinReadPre * let  s:std_in=1
autocmd vimenter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" Move in windows with C-<dir> instead of C-w <dir>
map <C-h> <C-w>h  
map <C-l> <C-w>l
map <C-j> <C-w>j
map <C-k> <C-w>k

" }}}
" Normal Commands {{{
command! W :w " :W will work as :w

:command! Hex :call HexHighlight()
:command! Nerd :NERDTreeToggle " Open NERDTree, so big
:command! Undo :UndotreeToggle " Open Undotree, so nice
:command! Vimrc :tabe $HOME/.vimrc " Open .vimrc with a command, so much
" }}}
" Searching {{{
set hlsearch " Highlight search matches
set smartcase "ignore case in searches with lowercase letters
set incsearch " Search while entering word
" }}}
" Folding {{{
set foldenable " Enable folding
set foldlevelstart=10 " Open most folds upon start
set foldmethod=indent " Fold based on indentation
set foldnestmax=10 " Maximum of 10 nested folds
" }}}
" Quality of Life {{{
set cursorline " Make current line stand out
set guioptions=i " Remove toolbar on top, preserve icon in alt-tab
set laststatus=2
set lazyredraw " Redraw only when needed
set noshowmode " Dont show which mode is active, lightline does that
set showcmd " Show the command being entered

" Increase vertical size of split (window)
map <C-UP> :winc+<CR>
" Decrease vertical size of split (window)
map <C-DOWN> :winc-<CR>
" Increase horizontal size of split (window)
map <C-LEFT> :winc<<CR>
" Decrease horizontal size of split (window)
map <C-RIGHT> :winc><CR>

" Expand the window so it isn't some small shit on startup
if has("gui_running")
    if has("unix")
        set lines=999 columns=999
    elseif has("win32")
        au GUIEnter * simalt ~x
    endif
endif

" Use shift + j/k  to scroll tabs, use <leader>e to open a file in new tab
map <F9> :tabp<CR>
map <F10> :tabn<CR>
map <leader>e :tabedit <c-r>=expand("%:p:h")<cr>/

" find tagfiles
set tags=./tags;/
au Filetype python set tags+=$VIRTUAL_ENV/tags

" }}}
" File settings {{{
au Filetype make set noexpandtab " Turn of expandtab when in makefiles

au Filetype vim set foldmethod=marker " Use different fold method for vimrc
au Filetype vim set foldlevel=0 " Start with everything folded in vimrc

au Filetype tex set linebreak " Don't linebreak in the middle of a word, only certain characters (Can be configured IIRC)
au Filetype tex set nowrap " Don't wrap across lines, break the line instead, tex doesn't care if there's only one linebreak
au Filetype tex setlocal conceallevel=0 "This stupid ass standard vim thing makes wrtiting latex impossible
au Filetype tex set tw=80 " Don't let a line exceed 80 characters

" frontend dev uses to many tabs for a 4 space tab
au Filetype html,javascript,jsx setlocal shiftwidth=2
au Filetype html,javascript,jsx setlocal softtabstop=2
au Filetype html,javascript,jsx setlocal tabstop=2
" }}}
" Backups {{{
if has("unix")
    set backupdir=~/.vim/backup//
    set directory=~/.vim/swp//
    set undodir=~/.vim/undo//
elseif has("win32")
    set backupdir=~/vimfiles/backup/
    set directory=~/vimfiles/swp/
    set undodir=~/vimfiles/undo/
endif
set undofile
" }}}
" Eventual functionality restoration {{{
set backspace=2 " Forces backspace to function as normal
set backspace=indent,eol,start " Allows backspacing across indents, end of lines and start of insertion
" }}}

