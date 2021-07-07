" INIT:
" Skip initialisation if vim tiny"{{{
if !1 | finish | endif
"}}}
" Leader key"{{{
let g:mapleader = ','
let g:maplocalleader = '\\'
"}}}
" Create bundles directory"{{{
if !isdirectory($HOME . '/.vim/plugged')
  call mkdir($HOME . '/.vim/plugged', 'p')
endif
"}}}
" Create cache directory"{{{
if !isdirectory($HOME . '/.vim/cache')
  call mkdir($HOME . '/.vim/cache', 'p')
else
  let s:cache_dir = '~/.vim/cache/'
endif
"}}}
" Functions"{{{
" function! source_file_if_exists(file)"{{{
function! Source_file_if_exists(file) abort
  if filereadable(expand(a:file))
    exe 'source' a:file
  endif
endfunction
"}}}
"}}}
" Global autocmd"{{{
augroup vimrc
	autocmd!
augroup END
"}}}
" Not vi compatible"{{{
if &compatible
  set nocompatible
endif
"}}}
" Enable syntax and loading {ftdetect,ftplugin,indent}/*.vim files"{{{
filetype plugin indent on

" Syntax Highlight
" Enable loading syntax/*.vim files
if (&t_Co > 2 || g:is_gui) && !exists("syntax_on")
  syntax enable
endif
"}}}
" SETTINGS:
" Indentation"{{{
set cindent
set autoindent " Copy indent from current line when starting a new line.
set shiftround " Round indent to multiple of 'shiftwidth'. Applies to > and < commands.
set smartindent " Automatically inserts one extra level of indentation in some cases.
set expandtab " Expand spaces instead of tab. Essential in python
set tabstop=2 " How many columns 'spaces' a <Tab> counts for
set shiftwidth=2  " how many columns of text is indented with <<, >>, and cindent
set softtabstop=2 " How many columns vim uses when you hit <Tab> in the insert mode
set smarttab  " Tab key always inserts blanks according to 'tabstop'
"}}}
" Search{{{
set ignorecase  " Case insensitive search
set smartcase " Case insensitive when uc present
set magic " For regular expressions, turn to magic
set grepformat=%f:%l:%c:%m,%f:%l:%m " Format to recognize for the :grep command output
set incsearch " Find your pattern (all patterns)
if ! &hlsearch
  set hlsearch  " Highlight finding patterns
endif
"set nowrapscan " Vim incremental 'pattern search' stop at end of file
if executable('rg')
  let &grepprg = 'rg --vimgrep --no-messages --no-ignore --hidden --follow --smart-case --glob "!.git/" --glob "!node_modules/" --regexp' " Program to use for the :grep command
endif
"}}}
" Buffers{{{
set autowrite " Automatically write a file when leaving a modified buffer
set autoread  " Read the file again if have been changed outside of Vim
set hidden  " Allows you to hide buffers with unsaved changes without being prompted
set splitbelow " Splitting a window will put the new window below of the current one
set splitright " Splitting a window will put the new window right of the current one
"}}}
" Backup{{{
set noswapfile
set nobackup  " Prevent 'tilde backup files'. Pre-requisites for coc.nvim (issues for some LSP servers)
if has('persistent_undo')
  set undofile  " Keep changes in memory
  set undolevels=1000 " Maximum changes that can be undone
  set undoreload=10000  " Maximum lines to save for undo in a buffer reload
endif
if &history < 1000
  set history=1000  " Store a max of story
endif

silent !mkdir ~/.vim/.cache/{backup,undo,swap,views} > /dev/null 2>&1

set backupdir=~/.vim/.cache/backup//
set undodir=~/.vim/.cache/undo//
set directory=~/.vim/.cache/swap//
set viewdir=~/.vim/.cache/views//
"}}}
" Interface{{{
set t_Co=256  " Use 256 colors
set laststatus=2  " Always show status line
set showtabline=2 " Always show tabs
set ruler " Show the ruler
set cursorline
highlight clear SignColumn  " SignColumn should match background
highlight clear LineNr  " Current line number row will have same background color in relative mode

set conceallevel=1  " Syntax : each block of concealed text is replaced with one character
set backspace=2 " Fix backspace behavior on most terminals (or 2)
set scrolljump=5  " Line to scroll when cursor leaves screen
set scrolloff=3 " Minumum lines to keep above and below cursor
set sidescroll=3  " Columns to scroll horizontally when cursor is moved off the screen
set sidescrolloff=3 " Minimum number of screen columns to keep to cursor right
set linespace=0 " Number of extra spaces between rows
set number relativenumber " Line number / Relative number on
set modeline
set modelines=5
set title
set titlestring=%{getpid().':'.getcwd()}

" vim in tmux background color changes when paging
" http://stackoverflow.com/questions/6427650/vim-in-tmux-background-color-changes-when-paging/15095377#15095377
set t_ut=
"}}}
" line break and overlength{{{
set textwidth=0 " To disable the cit-off at a column number
"let &colorcolumn="+1,".join(range(120,999),",")
"set formatoptions+=a " Dynamycally resize a paragraph when any change is made
set nowrap " Not wrap lines or text
set linebreak " Not break in the middle of a word (work only if nolist is set)
set whichwrap+=<,>,h,l " Allow '< (left arrow),> (right arrow),h,l' keys that move cursor to previous/next line }}} Command mode{{{
set showcmd " Show partial commands in statusline
set showmode  " Show the current mode
set showmatch " Show matching brackets/parenthesis
set wildignore+=*.jpg,*.jpeg,*.bmp,*.gif,*.png            " image
set wildignore+=*.o,*.obj,*.exe,*.dll,*.so,*.out,*.class  " compiler
set wildignore+=*.swp,*.swo,*.swn                         " vim
set wildignore+=*/.git,*/.hg,*/.svn                       " vcs
set wildignore+=tags,*.tags
set wildignorecase
set wildmenu
set wildmode=list:longest,full
"set listchars=tab:→\ ,eol:↵,trail:·,extends:↷,precedes:↶
"}}}
" Behaviour{{{
set number relativenumber " Line number / Relative number on

" For Coc.nvim
set nowritebackup
set cmdheight=1 " More spaces for displaying messages
set updatetime=300  " If that milliseconds nothing is typed CursorHold event will trigger
set shortmess+=cI  " No help Uganda information (at0I)
"
" For vim-which_key_map
set timeout
set timeoutlen=500  " Mapping delays in milliseconds
set ttimeout
set ttimeoutlen=10  " Key code delays in milliseconds

" For tmux
set mouse=a

if ! has('nvim')
  if has('mouse_sgr')
    set ttymouse=sgr
  endif
endif

" Copy & paste
if has("clipboard")
  set clipboard=unnamed " copy to the system clipboard

  if has("unnamedplus") " X11 support
    set clipboard+=unnamedplus
  endif
endif
"}}}

" Folding{{{
"set foldexpr=vimrc#util#vim_fold_num(3)
"set foldtext=vimrc#util#vim_fold_text()
set fillchars=fold:.
nnoremap <silent> <space> @=(foldlevel('.')?'za':"zz")<CR>
vnoremap <space> zf
"}}}

" FILETYPES:
" Vimrc"{{{
augroup vimrc
	au!
  au BufWritePre * :%s/\s+$//e        " Trim trailing whitespaces
	au BufRead,BufNewFile *{_,.}{,g}vim{,rc}* set foldmethod=marker foldlevel=0
	"au BufWritePost *{_,.}{,g}vim{,rc}* so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
augroup END
"}}}
" COMMANDS:
" Run :CLEAN to trim whitespaces at EOL and retab"{{{
command! TEOL %s/\s\+$//e
command! CLEAN retab | TEOL
"}}}
" Close all buffers except this one"{{{
command! BufCloseOthers %bd|e#
"}}}
" Add ! to replace it"{{{
command! W w !sudo tee % > /dev/null
"}}}
" Update & Upgrade{{{
command PU PlugUpdate | PlugUpgrade
"}}}
" PLUGINS:
" Vim-Plug install"{{{
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd vimrc VimEnter * nested PlugInstall --sync | source $MYVIMRC
endif
"}}}
" Bundles"{{{
call plug#begin('~/.vim/plugged')
  " Colors schemes"{{{
  Plug 'tomasr/molokai' " Molokai colorscheme (dark background)
  Plug 'morhetz/gruvbox' " Gruvbox colorscheme (dark/light) retrro groove
"}}}
  " UI"{{{
  Plug 'vim-airline/vim-airline' | Plug 'vim-airline/vim-airline-themes' " Lean & mean status/tabline
  Plug 'ryanoasis/vim-devicons' " Add icons to plugins
  Plug 'tpope/vim-eunuch' " UNIX shell commands in Vim
  Plug 'preservim/nerdtree' " File system explorer for the Vim editor
  Plug 'jistr/vim-nerdtree-tabs' " NERDTree feel like a true panel, independent of tabs
  Plug 'tiagofumo/vim-nerdtree-syntax-highlight', { 'on': 'NERDTreeToggle' }
  Plug 'Xuyuanp/nerdtree-git-plugin' " NERDTree showing git status flags
  Plug 'tpope/vim-unimpaired' " Provides several pairs of bracket maps
  Plug 'liuchengxu/vim-which-key' " Shows key bindings in popup when pressing '<leader>'
  Plug 'mhinz/vim-startify' " Provides a start screen for Vim and Neovim
"}}}
  " Filetype: Html, Php, Css, Scss, Sass"{{{
  Plug 'mattn/emmet-vim', { 'for': ['css', 'scss', 'sass', 'html', 'php'] }
  Plug 'ap/vim-css-color', { 'for': ['css', 'scss', 'sass'] }
"}}}
call plug#end()
"}}}
" Automatically install missing plugins on startup"{{{
autocmd VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)')) | PlugInstall --sync | q | endif
"}}}
" Press 'H', to open Help docs"{{{
function! s:plug_doc()
  let name = matchstr(getline('.'), '^- \zs\S\+\ze:')
  if has_key(g:plugs, name)
    for doc in split(globpath(g:plugs[name].dir, 'doc/*.txt'), '\n')
      execute 'tabe' doc
    endfor
  endif
endfunction

augroup PlugHelp
  autocmd!
  autocmd FileType vim-plug nnoremap <buffer> <silent> H :call <sid>plug_doc()<cr>
augroup END
"}}}
" CONFIG:
" Colorscheme"{{{
" Make sure colored syntax mode is on, and make it Just Work with 256-color terminals.
set background=dark
let g:rehash256 = 1 " Something to do with Molokai?
colorscheme molokai
let g:airline_theme = 'badwolf'
let g:seoul256_background = 233
if !has('gui_running')
  let g:solarized_termcolors = 256
  if $TERM == "xterm-256color" || $TERM == "screen-256color" || $COLORTERM == "gnome-terminal"
    set t_Co=256
  elseif has("terminfo")
    colorscheme default
    set t_Co=8
    set t_Sf=[3%p1%dm
    set t_Sb=[4%p1%dm
  else
    colorscheme default
    set t_Co=8
    set t_Sf=[3%dm
    set t_Sb=[4%dm
  endif
  " Disable Background Color Erase when within tmux - https://stackoverflow.com/q/6427650/102704
  if $TMUX != ""
    set t_ut=
  endif
endif
syntax on
"}}}
" Airline"{{{
if isdirectory(expand('~/.vim/plugged/vim-airline/'))
  let g:airline_powerline_fonts = 1
  let g:airline#extensions#tabline#enabled = 1

  let g:airline_left_sep = "\uE0B4"
  let g:airline_right_sep = "\uE0B6"

  let g:airline_section_b = '%{strftime("%A %d %B %Y * %H:%M")}'
  let g:airline_section_z = "%p%% * \ue0a1:%l/%L * \ue0a3:%c"
endif
"}}}
" NerdTree"{{{
if isdirectory(expand('~/.vim/plugged/nerdtree/'))
  nnoremap <leader>nt :NERDTreeToggle<cr>
  " NERDtree variables{{{
  " 'm' puis 'a' to create new filename.
  " For a directory, append the filename with /
  let NERDTreeWinSize               = 70
  let g:NERDTreeShowHidden          = 1
  let g:NERDTreeQuitOnOpen          = 0
  let g:NERDTreeMinimalUI           = 1
  let g:NERDTreeDirArrowExpandable  = ''
  let g:NERDTreeDirArrowCollapsible = ''
  let g:NERDTreeIgnore              = ['^\.DS_Store$', '^tags$', '\.git$[[dir]]', '\.sass-cache$']
  let g:netrw_banner                = 0
  let g:netrw_liststyle             = 3
  let g:netrw_browse_split          = 4
"}}}
endif
"}}}
" MAPPINGS:
" h,j,k,l keys"{{{
inoremap jj <esc>
inoremap kk <esc>

" For moving between long wrapped lines.
nnoremap <expr> j v:count ? 'j' : 'gj'
nnoremap <expr> k v:count ? 'k' : 'gk'
xnoremap <expr> j v:count ? 'j' : 'gj'
xnoremap <expr> k v:count ? 'k' : 'gk'

" Make j and k move faster
nnoremap jk 10j
nnoremap kj 10k
"}}}
" Keys i want to ignore{{{
nmap Q  <silent>
nmap q: <silent>
"nmap K  <silent>
"}}}
" Edit{{{
" Quickly edits .vimrc
nnoremap <silent> <leader>ev :<c-u>execute 'edit' resolve($MYVIMRC)<cr>
nnoremap <silent> <leader>et :<c-u>tabe $MYVIMRC<cr>
"let g:which_key_map.e.v = 'edit-vimrc'
"let g:which_key_map.e.t = 'tab-vimrc'
"
" Quickly edits a file in the same directory
" Typing `:ec` on the command line expands to `:e` + the current path, so it's easy to edit a file in
" the same directory as the current file.
cnoremap ec e <C-\>eCurrentFileDir()<CR>
function! CurrentFileDir()
  return "e " . expand("%:p:h") . "/"
endfunction
"}}}
" Search{{{
nnoremap <leader>, :<c-u>silent! nohls<cr>
nnoremap n nzz
nnoremap N Nzz

" Always search with 'very magic' mode.
nnoremap / /\v
vnoremap / /\v

nnoremap ? ?\v
vnoremap ? ?\v

" How to clear the last search highlighting
nnoremap <cr> :noh<cr>

" Default to magic mode when using substitution
cnoremap %s/ %s/\v
cnoremap \>s/ \>s/\v
"}}}
" Indentation{{{
vmap < <gv
vmap > >gv

vmap <left> [egv
vmap <right> ]egv

" Fix indentation in file
map <leader>i mmgg=G`m<CR>
"}}}
" Buffers, windows and tabs"{{{
" Switch to a buffer n° [count]: [count]<c-^> or :b[count] or :[count]b
" Switch to most recent buffer: <c-^> or :b#
" Show buffer command list: :b <c-d>
" Tabs command :sbX, :tabs, :tabn, :tabp, :tabfirst, :tablast, :tabm, :tabm 0, :tabm X
" Tabs normal mode: ^w T, gt, gT, [count]gt
" https://www.tictech.info/post/vim_avance_p2
" https://vi.stackexchange.com/questions/2129/fastest-way-to-switch-to-a-buffer-in-vim/2131#2131
"nnoremap <leader>b :<c-u>ls<cr>:b<space>
"nnoremap <leader>b :<c-u>bufdo normal! zM<cr>
nnoremap <left> :<c-u>bp<cr>
nnoremap <right> :<c-u>bn<cr>

" Go back to the last buffer shortcut.
nnoremap <up> :<c-u>bf<cr>
nnoremap <down> :<c-u>bl<cr>

" Split window
nmap ss :split<cr><c-w>w
nmap sv :vsplit<cr><c-w>w

" Move window
map sh <C-w>h
map sk <C-w>k
map sj <C-w>j
map sl <C-w>l

" Switch tab
nmap <S-Tab> :tabprev<cr>
nmap <Tab> :tabnext<cr>

" Zoomed a buffer in full screen
nnoremap <leader>z <c-w>_ \| <c-w>\|
"tnoremap <leader>z <c-w>_ \| <c-w>\|

nnoremap <silent> <leader>x :bp\|bd #<cr>
"}}}
" Behaviour{{{
" Toggle no numbers → absolute → relative → relative with absolute on cursor line
nnoremap <silent> <leader>; :<c-u>exe 'set nu!' &nu ? 'rnu!' : ''<cr>

" Save file and source it
nnoremap <leader>w :<c-u>w!<cr>:so %<cr>:so $MYVIMRC<cr>

" Save and exit
nnoremap <leader>W :<c-u>wq!<cr>

" Exit
nnoremap <silent> <leader>q :<c-u>quit<cr>
nnoremap <silent> <leader>Q :<c-u>quitall<cr>

" Sudo
cmap w!! w !sudo tee % >/dev/null

" Marks should go to the column, not just the line. Why isn't this the default?
nnoremap ' `

" You don't know what you're missing if you don't use this.
nmap <c-e> :e#<cr>

"}}}
" LOCAL:
" Local"{{{
call Source_file_if_exists('~/.vimrc.local')
"}}}
" FIX:
" Some plugin seems to search for something at startup{{{
silent! nohlsearch
"}}}
