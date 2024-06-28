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

"Plugin 'miyakogi/seiya.vim'

Plugin 'gmarik/Vundle.vim'

Plugin 'Valloric/YouCompleteMe'
Plugin 'rdnetto/YCM-Generator'

Plugin 'godlygeek/csapprox'

"Plugin 'flazz/vim-colorschemes'
Plugin 'chriskempson/base16-vim'

"Plugin 'vim-scripts/hexHighlight.vim'

"Plugin 'godlygeek/tabular'

"Plugin 'shawncplus/Vim-toCterm'

"Plugin 'itchyny/lightline.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

"Plugin 'scrooloose/syntastic'
"Plugin 'w0rp/ale'
Plugin 'dense-analysis/ale'

Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'

Plugin 'preservim/tagbar'

Plugin 'mbbill/undotree'

Plugin 'tpope/vim-fugitive'

Plugin 'yggdroot/indentline'

Plugin 'justinmk/vim-sneak'

"Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-repeat'

"Writing stuff
Plugin 'lervag/vimtex'
Plugin 'JamshedVesuna/vim-markdown-preview'

"Javascript highligting
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'

" C# and unity3d thingies
Plugin 'OmniSharp/omnisharp-vim'

" Local vimrcs for projects
Plugin 'krisajenkins/vim-projectlocal'

" fuzzy finding
Plugin 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plugin 'junegunn/fzf.vim'

"Grammar checking
Plugin 'rhysd/vim-grammarous'

" Python
Plugin 'jmcantrell/vim-virtualenv'

call vundle#end()
" }}}
filetype plugin indent on
" }}}
" Colors and Font {{{
syntax enable " Turn on syntax highlighting

set encoding=utf-8 " Set utf-8 to support more characters
let base16colorspace=256
set t_Co=256 " Set terminal-vi to use 256 colors
"set termguicolors

"silent! colorscheme base16-dracula " Sets colorscheme
silent! colorscheme base16-apathy " Sets colorscheme

if has('gui_running')
    if has("win32")
        set guifont=consolas:h12 " Change to your liking
    elseif has("unix")
        set guifont=Source\ Code\ Pro\ Medium\ 10 " Change to your liking
    endif
endif

"set background=dark " Sets background to be dark (noshitsherlock)
let g:airline_theme='base16'
"let g:lightline = {
"            \ 'colorscheme': 'base16',
"            \ } " Change color of lightline to match with colorscheme

"Set bgcolor to terminal color, including transparancy
let g:CSApprox_hook_post = [
            \ 'highlight Normal            ctermbg=NONE',
            \ 'highlight LineNr            ctermbg=NONE',
            \ 'highlight SignifyLineAdd    cterm=bold ctermbg=NONE ctermfg=green',
            \ 'highlight SignifyLineDelete cterm=bold ctermbg=NONE ctermfg=red',
            \ 'highlight SignifyLineChange cterm=bold ctermbg=NONE ctermfg=yellow',
            \ 'highlight SignifySignAdd    cterm=bold ctermbg=NONE ctermfg=green',
            \ 'highlight SignifySignDelete cterm=bold ctermbg=NONE ctermfg=red',
            \ 'highlight SignifySignChange cterm=bold ctermbg=NONE ctermfg=yellow',
            \ 'highlight SignColumn        ctermbg=NONE',
            \ 'highlight CursorLine        ctermbg=NONE cterm=NONE',
            \ 'highlight CursorLineNr      ctermbg=NONE cterm=NONE',
            \ 'highlight Folded            ctermbg=NONE cterm=bold',
            \ 'highlight FoldColumn        ctermbg=NONE cterm=bold',
            \ 'highlight LightlineRight_normal_tabsel_0       ctermbg=NONE cterm=NONE',
            \ 'highlight NonText           ctermbg=NONE',
            \ 'highlight SpellCap          ctermbg=NONE',
            \ 'highlight SpellBad          ctermbg=NONE',
            \ 'highlight SpellRare         ctermbg=NONE',
            \ 'highlight SpellLocal        ctermbg=NONE',
            \ 'highlight clear LineNr'
            \]

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
let mapleader = "\<Space>" " Rebind leader to space
let maplocalleader = "," " Leader used for vimtex

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

" FZF ctrl+p
nmap <C-P> :FZF<CR>

" FZF tagbar
nmap <leader>] :Tags<CR>

" FZF new tab
:command! -bang FZFTE call fzf#run(fzf#wrap({'sink': 'tabedit'}, <bang>0))
nnoremap <leader>e :FZFTE<CR>


nmap <silent> <leader>h :set opfunc=NrToBinaryWithMovement<CR>g@
vmap <silent> <leader>h :<c-u>call NrToBinaryWithMovement(visualmode())<CR>

function! NrToBinaryWithMovement(type)
    if a:type ==# 'v'
        execute  "normal! `<v`>y"
    elseif a:type ==# 'char'
        execute  "normal! `[v`]y"
    else
        return
    endif
    echom Nr2Bin(@@)
endfunction

" }}}
" Plugin settings {{{
" Airline {{{
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
" }}}
" vimtex {{{
let g:vimtex_view_method = 'zathura'
" Add imap to create \item
call vimtex#imaps#add_map({
            \ 'lhs' : 'i',
            \ 'rhs' : '\item ',
            \ 'wrapper' : 'vimtex#imaps#wrap_environment',
            \ 'context' : ['itemize', 'enumerate'],
            \})
" }}}
" Vim Markdown {{{
let vim_markdown_preview_toggle=2

"Use github flavored md if in git repo TODO check if github?
if system('git rev-parse --is-inside-work-tree')
    let vim_markdown_preview_github=1
endif
let vim_markdown_preview_github=1

" }}}
" ALE linters{{{ 
let g:ale_linters = {
            \ 'cs': ['OmniSharp']
            \}
" }}}
" YCM {{{
let g:ycm_seed_identifiers_with_syntax=1
let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'

" Remove YCM error highlighting, ALE does this.
let g:ycm_show_diagnostics_ui = 1
let g:ycm_enable_diagnostic_signs = 0
let g:ycm_enable_diagnostic_highlighting = 0
let g:ycm_autoclose_preview_window_after_completion = 1

" }}}
" Indentline {{{
let g:indentLine_fileTypeExclude = ['json', 'tex'] " Makes sure conceallevel is not 2 in json and tex
" }}}
" Tagbar {{{
let g:tagbar_sort = 0
let g:tagbar_show_linenumbers = 1
let g:tagbar_wrap = 1
" }}}
" fzf {{{

let s:tag_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit'}
function! Custom_tags_sink(lines)
    if len(a:lines) < 2
        return
    endif
    let cmd = get(s:tag_action, a:lines[0], '')
    let tagname = split(a:lines[1], ' ')[0]
    if empty(cmd)
        execute 'tag '.tagname
    elseif cmd == 'ptag'
        execute 'ptag '.tagname
    else
        execute cmd
        execute 'tag '.tagname
    endif
endfunction

:command! -bang -nargs=* Tags call fzf#vim#tags(<q-args>, fzf#vim#with_preview({'sink*': function('Custom_tags_sink'), "placeholder": "--tag {2}:{-1}:{3..}" }), <bang>0)'

nmap <silent> <leader>a :set opfunc=AgWithMovement<CR>g@
vmap <silent> <leader>a :<c-u>call AgWithMovement(visualmode())<CR>

function! AgWithMovement(type)
    if a:type ==# 'v'
        execute  "normal! `<v`>y"
    elseif a:type ==# 'char'
        execute  "normal! `[v`]y"
    else
        return
    endif
    silent execute "Ag ".@@
endfunction

" Rewrite Ag function to use global extra options
function! CustomAg(query, ...)
  if type(a:query) != v:t_string
    return s:warn('Invalid query argument')
  endif
  let query = empty(a:query) ? '^(?=.)' : a:query
  let args = copy(a:000)
  let ag_opts = len(args) > 1 && type(args[0]) == v:t_string ? remove(args, 0) : ''
  let opts_raw = get(g:, 'fzf_ag_opts', '')
  let opts = empty(opts_raw) ? '' : join(opts_raw)
  let command = opts.ag_opts . ' -- ' . fzf#shellescape(query)
  return call('fzf#vim#ag_raw', insert(args, command, 0))
endfunction
command! -bang -nargs=* Ag call CustomAg(<q-args>, fzf#vim#with_preview(), <bang>0)

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

set rnu " Have line numbers relative to your position
set nu " Show line number on current line (non relative)

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
:command! Undo :UndotreeToggle " Open Undotree, so nice
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
set updatetime=750 " Make updatetime 750 ms instead of 4 s
set ignorecase " Make tags work with unsorted tags

" Increase vertical size of split (window)
map <C-UP> :winc+<CR>
" Decrease vertical size of split (window)
map <C-DOWN> :winc-<CR>
" Increase horizontal size of split (window)
map <C-LEFT> :winc<<CR>
" Decrease horizontal size of split (window)
map <C-RIGHT> :winc><CR>

" Make splits more logical
set splitbelow
set splitright

" Expand the window so it isn't some small shit on startup
if has("gui_running")
    if has("unix")
        set lines=999 columns=999
    elseif has("win32")
        au GUIEnter * simalt ~x
    endif
endif


" find tagfiles
set tags=./tags;/
au Filetype python set tags+=$VIRTUAL_ENV/tags

set conceallevel=0 "This stupid ass standard vim thing makes wrtiting latex impossible

func Nr2Bin(nr)
    let n = a:nr
    let r = ""
    while n
        let r = '01'[n % 2] . r
        let n = n / 2
    endwhile
    return r
endfunc

" }}}
" File settings {{{
" TODO: Use ftplugin
au Filetype make set noexpandtab " Turn of expandtab when in makefiles

au Filetype vim set foldmethod=marker " Use different fold method for vimrc
au Filetype vim set foldlevel=0 " Start with everything folded in vimrc

au Filetype tex set linebreak " Don't linebreak in the middle of a word, only certain characters (Can be configured IIRC)
au Filetype tex set nowrap " Don't wrap across lines, break the line instead, tex doesn't care if there's only one linebreak
au Filetype tex set tw=80 " Don't let a line exceed 80 characters
au Filetype tex map <C-b> i\begin{}<left>
au Filetype tex imap <C-b> \begin{}<left>

" frontend dev uses to many tabs for a 4 space tab
au Filetype html,javascript,jsx setlocal shiftwidth=2
au Filetype html,javascript,jsx setlocal softtabstop=2
au Filetype html,javascript,jsx setlocal tabstop=2

" Templates {{{
if has("autocmd")
    augroup templates
        autocmd BufNewFile *.tex 0r ~/.vim/templates/skeleton.tex
    augroup END
endif
"}}}
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
set undofile "Persistent undos is magic
" }}}
" Eventual functionality restoration {{{
set backspace=2 " Forces backspace to function as normal
set backspace=indent,eol,start " Allows backspacing across indents, end of lines and start of insertion
" }}}
