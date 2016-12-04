" Use Space to open/close folds
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

Plugin 'vim-scripts/hexHighlight.vim'

Plugin 'godlygeek/tabular'

Plugin 'shawncplus/Vim-toCterm'

Plugin 'itchyny/lightline.vim'

Plugin 'scrooloose/syntastic'

Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'

Plugin 'mbbill/undotree'

Plugin 'tpope/vim-fugitive'

Plugin 'yggdroot/indentline'

Plugin 'justinmk/vim-sneak'

Plugin 'tpope/vim-surround'

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
nnoremap <S-tab> gg=G
" }}}
" Leader Commands {{{
" let mapleader = "," " Rebind leader to be comma
let mapleader = "\<Space>"

" Call :noh upon hitting <leader> + space, removing highlighting from search
nnoremap <leader><space> :noh<CR>

" Toggle NERDTree in all tabs
map <leader>n <plug>NERDTreeTabsToggle<CR>

" }}}
" Plugin settings {{{
filetype plugin on
" Syntastic {{{
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:syntastic_cpp_compiler = 'g++' " Set cpp compiler for syntastic to use
let g:syntastic_cpp_compiler_options = '-std=c++11 -Wall -Wextra -pedantic'
" }}}
" }}}
" Text/File Navigation {{{

" Sneak navigation {{{
"remap sneak to f
nmap f <Plug>Sneak_s
nmap F <Plug>Sneak_S
xmap f <Plug>Sneak_s
xmap F <Plug>Sneak_S
omap f <Plug>Sneak_s
omap F <Plug>Sneak_S

"replace <leader>'f' with 1-char Sneak
nmap <leader>f <Plug>Sneak_f
nmap <leader>F <Plug>Sneak_F
xmap <leader>f <Plug>Sneak_f
xmap <leader>F <Plug>Sneak_F
omap <leader>f <Plug>Sneak_f
omap <leader>F <Plug>Sneak_F
"replace 't' with 1-char Sneak
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

au FocusLost * silent! :set nornu " Disable relative number when unfocused
au FocusGained * silent! :set rnu " Enable relative number when focused

autocmd StdinReadPre * let  s:std_in=1
autocmd vimenter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

autocmd InsertEnter * silent! :set nornu " Disable relative number when in insert mode
autocmd InsertLeave * silent! :set rnu " Enable relative number when in any other

" Move in windows with C-<dir> instead of C-w <dir>
map <C-h> <C-w>h  
map <C-l> <C-w>l
map <C-j> <C-w>j
map <C-k> <C-w>k

" Easier line navigation
nnoremap B 0
nnoremap E $
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
set ignorecase "ignore case in searches
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
set nolist " List fucks wrapping up, so lets disable it

" Increase vertical size of split (window)
map <UP> :winc+<CR>
" Decrease vertical size of split (window)
map <DOWN> :winc-<CR>
" Increase horizontal size of split (window)
map <LEFT> :winc<<CR>
" Decrease horizontal size of split (window)
map <RIGHT> :winc><CR>

" Highlight last inserted text
nnoremap gV `[v`]

" Expand the window so it isn't some small shit on startup
if has("gui_running")
    if has("unix")
        set lines=999 columns=999
    elseif has("win32")
        au GUIEnter * simalt ~x
    endif
endif

" Use f9 and f10 to scroll tabs, use <leader>e to open a file in new tab
map <F9> :tabp<CR>
map <F10> :tabn<CR>
map <leader>e :tabedit <c-r>=expand("%:p:h")<cr>/

" }}}
" File settings {{{
au Filetype make set noexpandtab " Turn of expandtab when in makefiles
au Filetype vim set foldmethod=marker " Use different fold method for vimrc
au Filetype vim set foldlevel=0 " Start with everything folded in vimrc
au Filetype tex set linebreak " Don't linebreak in the middle of a word, only certain characters (Can be configured IIRC)
au Filetype tex set nowrap " Don't wrap across lines, break the line instead, tex doesn't care if there's only one linebreak
au Filetype tex set tw=150 " Don't let a line exceed 150 characters
au Filetype python match Underlined '\%<80v.\%>72v' " Underscore characters 72 -> 79(72 is max length for docstr)
au filetype python 2mat ErrorMsg '\%79v.' " Highlight the 79th char in a row (max length in python)
" }}}
" Backups {{{
set backupdir=~/.vim/backup//
set directory=~/.vim/swp//
set undodir=~/.vim/undo//
set undofile
" }}}
" Eventual functionality restoration {{{
set backspace=2 " Forces backspace to function as normal
set backspace=indent,eol,start " Allows backspacing across indents, end of lines and start of insertion
" }}}

