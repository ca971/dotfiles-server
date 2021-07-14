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
" Variables{{{
" Python 2
if executable('python2')
  let g:python_host_prog = '/usr/bin/python2'
endif

" Python 3
if executable('python3')
  let g:python3_host_prog = $HOME . '/.pyenv/versions/python_3/bin/python'
endif

" Ruby
if executable('ruby)
  let g:ruby_host_prog = $HOME . '/.rbenv/versions/3.0.2/bin/ruby'
endif

" Perl
if executable('perl')
  let g:perl_host_prog = '/usr/bin/perl'
endif

" NodeJs for Coc.nvim
if executable('node')
  let g:coc_node_path = $HOME . '/.nvm/bin/node'
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
if executable('node')
  command! PU PlugUpdate | PlugUpgrade | CocUpdate
else
  command! PU PlugUpdate | PlugUpgrade
endif
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
  Plug 'neoclide/coc.nvim', { 'branch': 'release' } " Coc Explorer
  Plug 'junegunn/fzf', {
        \ 'dir': '~/.fzf',
        \ 'do': './install --all --no-update-rc',
        \}
  Plug 'junegunn/fzf.vim' " Search faster
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

if isdirectory(expand('~/.vim/plugged/molokai/'))
  colorscheme molokai
else
  colorscheme default
endif

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
" Coc.nvim"{{{
" https://github.com/neoclide/coc.nvim.git
if isdirectory(expand('~/.vim/plugged/coc.nvim/'))
  if executable('node')
    " Global extensions{{{
    let g:coc_global_extensions = [
          \ 'coc-actions',
          \ 'coc-css',
          \ 'coc-emmet',
          \ 'coc-explorer',
          \ 'coc-git',
          \ 'coc-go',
          \ 'coc-gitignore',
          \ 'coc-highlight',
          \ 'coc-html',
          \ 'coc-java',
          \ 'coc-jedi',
          \ 'coc-json',
          \ 'coc-lists',
          \ 'coc-pairs',
          \ 'coc-phpactor',
          \ 'coc-phpls',
          \ 'coc-powershell',
          \ 'coc-prettier',
          \ 'coc-project',
          \ 'coc-python',
          \ 'coc-r-lsp',
          \ 'coc-syntax',
          \ 'coc-snippets',
          \ 'coc-sql',
          \ 'coc-svg',
          \ 'coc-tailwindcss',
          \ 'coc-texlab',
          \ 'coc-tsserver',
          \ 'coc-vimtex',
          \ 'coc-xml',
          \ 'coc-yaml',
          \ 'coc-yank',
          \ ]
"}}}
    " Coc-Actions{{{

"}}}
    " Coc-Bookmark{{{
    nnoremap <leader>mm <Plug>(coc-bookmark-toggle)
    nnoremap <leader>mi <Plug>(coc-bookmark-annotate)
    nnoremap <leader>mn <Plug>(coc-bookmark-next)
    nnoremap <leader>mp <Plug>(coc-bookmark-prev)
    nnoremap <silent> <leader>ma :<c-u>CocList bookmark<cr>

    let g:which_key_map.m = {
          \ 'name' : '+bookmark'         ,
          \ 'm'    : 'bookmark-toggle'   ,
          \ 'i'    : 'bookmark-annotate' ,
          \ 'n'    : 'bookmark-next'     ,
          \ 'p'    : 'bookmark-prev'     ,
          \ 'l'    : 'list-bookmarks'    ,
          \ }
    "}}}
    " Coc-Css{{{

"}}}
    " Coc-Emmet{{{

"}}}
    " Coc-Explorer{{{
    " CocExplorer functions{{{
    function! ToggleCocExplorer()
      execute 'CocCommand explorer --toggle --width=40 --sources=buffer+,file+ ' . getcwd()
    endfunction
"}}}
    " Coc-Explorer presets{{{
    let g:coc_explorer_global_presets = {
          \   'dotvim': {
          \      'root-uri': '~/.vim',
          \   },
          \   'dotfiles': {
          \      'root-uri': '~/.dotfiles',
          \   },
          \   'Projects': {
          \      'root-uri': '~/projects',
          \   },
          \   'floating': {
          \     'position': 'floating',
          \     'open-action-strategy': 'sourceWindow',
          \   },
          \   'floatingTop': {
          \     'position': 'floating',
          \     'floating-position': 'center-top',
          \     'open-action-strategy': 'sourceWindow',
          \   },
          \   'floatingLeftside': {
          \     'position': 'floating',
          \     'floating-position': 'left-center',
          \     'floating-width': 100,
          \     'open-action-strategy': 'sourceWindow',
          \   },
          \   'floatingRightside': {
          \     'position': 'floating',
          \     'floating-position': 'right-center',
          \     'floating-width': 100,
          \     'open-action-strategy': 'sourceWindow',
          \   },
          \   'simplify': {
          \     'file-child-template': '[selection | clip | 1] [indent][icon | 1] [filename omitCenter 1]'
          \   }
          \ }
"}}}
    " CocExplorer mappings{{{
    nmap <leader>ed :<C-u>CocCommand explorer --preset .dotfiles<CR>
    nmap <leader>ep :<C-u>CocCommand explorer --preset Projects<CR>

    if g:is_nvim
      try
        nmap <leader>ef :<C-u>CocCommand explorer --preset floating<CR>
        nmap <leader>eT :<C-u>CocCommand explorer --preset floatingTop<CR>
        nmap <leader>eL :<C-u>CocCommand explorer --preset floatingLeftside<CR>
        nmap <leader>eR :<C-u>CocCommand explorer --preset floatingRightside<CR>
      catch
        echohl ErrorMsg
      endtry
    endif

    " List all presets
    nmap <leader>el :<C-u>CocList explPresets<CR>

    nnoremap <silent> <leader>ee :<C-u>call ToggleCocExplorer()<CR>

    augroup explorerCustom
      autocmd!
      autocmd FileType coc-explorer setlocal signcolumn=no
      autocmd BufEnter * if (winnr("$") == 1 && &filetype ==# 'coc-explorer') | q | endif
    augroup END

    let g:which_key_map.e = {
          \ 'name'     : '+coc-explorer'                       ,
          \ 'e'        : 'toggle-coc-explorer'                 ,
          \ 'd'        : 'open-dotfiles'                       ,
          \ 'f'        : 'open-explorer-with-presets-floating' ,
          \ 'p'        : 'open-projects'                       ,
          \ }
"}}}
"}}}
    " Coc-Git{{{

"}}}
    " Coc-Go{{{

"}}}
    " Coc-Gitignore{{{

"}}}
    " Coc-Highlight{{{

"}}}
    " Coc-Html{{{

"}}}
    " Coc-Java{{{

"}}}
    " Coc-Jedi{{{

"}}}
    " Coc-Json{{{

"}}}
    " Coc-Lists{{{
    nnoremap <silent> <leader>lg  :<c-u>CocList diagnostics<cr>
    nnoremap <silent> <leader>lc  :<c-u>CocList commands<cr>
    nnoremap <silent> <leader>lj  :<c-u>CocNext<cr>
    nnoremap <silent> <leader>lk  :<c-u>CocPrev<cr>
    nnoremap <silent> <leader>ll  :<c-u>CocList<cr>
    nnoremap <silent> <leader>lo  :<c-u>CocList outline<cr>
    nnoremap <silent> <leader>lp  :<c-u>CocListResume<cr>
    nnoremap <silent> <leader>ls  :<c-u>CocList -I symbols<cr>
    nnoremap <silent> <leader>lx  :<c-u>CocList extensions<cr>
    nnoremap <leader>la <Plug>(coc-codeaction)
    vnoremap <leader>la <Plug>(coc-codeaction-selected)
    nnoremap <leader>lA <Plug>(coc-codelens-action)
    nnoremap <leader>ld <Plug>(coc-definition)
    nnoremap <leader>lD <Plug>(coc-declaration)
    nnoremap <leader>le <Plug>(coc-refactor)
    nnoremap <leader>lf <Plug>(coc-format)
    vnoremap <leader>lf <Plug>(coc-format-selected)
    nnoremap <leader>lF <Plug>(coc-fix-current)
    nnoremap <leader>lJ <Plug>(coc-diagnostic-next)
    nnoremap <leader>lK <Plug>(coc-diagnostic-prev)
    nnoremap <leader>lI <Plug>(coc-diagnostic-info)
    nnoremap <leader>lm <Plug>(coc-implementation)
    nnoremap <leader>lr <Plug>(coc-references)
    nnoremap <leader>lR <Plug>(coc-rename)
    nnoremap <leader>lt <Plug>(coc-type-definition)
    nnoremap <leader>lv <Plug>(coc-range-select)
    vnoremap <leader>lv <Plug>(coc-range-select)

    let g:which_key_map.l = {
      \ 'name' : '+coc-lists'                          ,
      \ 'a'    : 'code-action'                         ,
      \ 'A'    : 'codelens-action'                     ,
      \ 'c'    : 'show-commands'                       ,
      \ 'd'    : 'jump-to-definition'                  ,
      \ 'D'    : 'jump-to-declaration'                 ,
      \ 'e'    : 'open-refactor-windows'               ,
      \ 'f'    : 'format'                              ,
      \ 'F'    : 'fix-code'                            ,
      \ 'g'    : 'show-all-diagnostics'                ,
      \ 'j'    : 'do-default-action-for-next-item'     ,
      \ 'k'    : 'do-default-action-for-previous-item' ,
      \ 'I'    : 'diagnostic-info (LSP)'               ,
      \ 'J'    : 'diagnostic-next (LSP)'               ,
      \ 'K'    : 'diagnostic-prev (LSP)'               ,
      \ 'l'    : 'lists'                               ,
      \ 'm'    : 'jump-to-implementation'              ,
      \ 'o'    : 'find-symbol-current-document'        ,
      \ 'p'    : 'resume-latest-coc-list'              ,
      \ 'r'    : 'jump-to-references'                  ,
      \ 'R'    : 'rename-symbol'                       ,
      \ 's'    : 'search-workspace-symbol'             ,
      \ 't'    : 'jump-to-type-definition'             ,
      \ 'v'    : 'range-select'                        ,
      \ 'x'    : 'manage-extensions'                   ,
      \ }
"}}}
    " Coc-Pairs{{{

"}}}
    " Coc-Phpactor{{{

"}}}
    " Coc-Phpls{{{

"}}}
    " Coc-Powershell{{{

"}}}
    " Coc-Prettier{{{

"}}}
    " Coc-Project{{{

"}}}
    " Coc-Python{{{

"}}}
    " Coc-R-Lsp{{{

"}}}
    " Coc-Syntax{{{

"}}}
    " Coc-Snippets{{{

"}}}
    " Coc-Sql{{{

"}}}
    " Coc-Texlab{{{

"}}}
    " Coc-Tsserver{{{

"}}}
    " Coc-Vimtex{{{

"}}}
    " Coc-Xml{{{

"}}}
    " Coc-Yaml{{{

"}}}
    " Coc-Yank{{{

"}}}
  else
    let g:coc_disable_startup_warning = 1
  endif
endif
"}}}
" Fzf.vim"{{{
" https://github.com/junegunn/fzf.vim.git
if isdirectory(expand('~/.vim/plugged/fzf.vim/'))
  " Fzf {{{
  let g:which_key_map.f = {
    \ 'name' : '+fzf-CommentFrame'       ,
    \ 'A'    : ['Ag'        , 'ag-search-result']        ,
    \ 'B'    : ['Buffers'   , 'open-buffers']            ,
    \ 'K'    : ['Commands'  , 'commands']                ,
    \ 'C'    : ['Colors'    , 'color-schemes']           ,
    \ 'f'    : ['Files'     , 'files-path']              ,
    \ 'F'    : ['Filetypes' , 'file-types']              ,
    \ 'g'    : ['GFiles?'   , 'git-status']              ,
    \ 'G'    : ['GFiles'    , 'git-ls-files']            ,
    \ 'h'    : ['History'   , 'recent-files']            ,
    \ 'H'    : ['History:'  , 'command-history']         ,
    \ 'l'    : ['BLines'    , 'lines-in-current-buffer'] ,
    \ 'L'    : ['Lines'     , 'lines-in-loaded-buffers'] ,
    \ 'm'    : ['Maps'      , 'normal-mode-mappings']    ,
    \ 'M'    : ['Marks'     , 'marks']                   ,
    \ 'R'    : ['Rg'        , 'rg-search-result']        ,
    \ 'S'    : ['Snippets'  , 'snippets']                ,
    \ 't'    : ['BTags'     , 'tags-in-current-buffer']  ,
    \ 'T'    : ['Tags'      , 'tags-in-the-projects']    ,
    \ 'W'    : ['Windows'   , 'windows']                 ,
    \ '/'    : ['History/'  , 'search-history']          ,
    \ }
"}}}
  " Set FZF_DEFAULT_COMMAND{{{
  let $FZF_DEFAULT_COMMAND = 'rg --files --follow -g "!{.git,node_modules}/*" 2>/dev/null'

  command! -bang -nargs=* Rg
    \ call fzf#vim#grep(
    \   'rg --column --line-number --no-heading --color=always --smart-case -g "!{*.lock,*-lock.json}" '.shellescape(<q-args>), 1,
    \   <bang>0 ? fzf#vim#with_preview('up:40%')
    \           : fzf#vim#with_preview('right:50%:hidden', '?'),
    \   <bang>0)
"}}}
  " function! s:update_fzf_colors(){{{
  " FZF color scheme updater from https://github.com/junegunn/fzf.vim/issues/59
  function! s:update_fzf_colors()
    let rules =
    \ { 'fg':      [['Normal',       'fg']],
      \ 'bg':      [['Normal',       'bg']],
      \ 'hl':      [['String',       'fg']],
      \ 'fg+':     [['CursorColumn', 'fg'], ['Normal', 'fg']],
      \ 'bg+':     [['CursorColumn', 'bg']],
      \ 'hl+':     [['String',       'fg']],
      \ 'info':    [['PreProc',      'fg']],
      \ 'prompt':  [['Conditional',  'fg']],
      \ 'pointer': [['Exception',    'fg']],
      \ 'marker':  [['Keyword',      'fg']],
      \ 'spinner': [['Label',        'fg']],
      \ 'header':  [['Comment',      'fg']] }
    let cols = []
    for [name, pairs] in items(rules)
      for pair in pairs
        let code = synIDattr(synIDtrans(hlID(pair[0])), pair[1])
        if !empty(name) && code != ''
          call add(cols, name.':'.code)
          break
        endif
      endfor
    endfor
    let s:orig_fzf_default_opts = get(s:, 'orig_fzf_default_opts', $FZF_DEFAULT_OPTS)
    let $FZF_DEFAULT_OPTS = s:orig_fzf_default_opts .
          \ (empty(cols) ? '' : (' --color='.join(cols, ',')))
  endfunction
"}}}
  " VimEnter, ColorScheme : call update_fzf_colors(){{{
  augroup _fzf
    autocmd!
    autocmd VimEnter,ColorScheme * call <sid>update_fzf_colors()
  augroup END
"}}}
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
" Vim-which-key{{{
" https://github.com/liuchengxu/vim-which-key.git
if isdirectory(expand('~/.vim/plugged/vim-which-key/'))
  call which_key#register(',', "g:which_key_map")
  nnoremap <silent> <leader> :<c-u>WhichKey ','<cr>
  nnoremap <silent> <localleader> :<c-u>WhichKey '\'<cr>
  let g:which_key_map = {
    \ 'name' : '+main',
    \ ','    : 'toggle/hlsearch',
    \ ';'    : 'toggle/number',
    \ 'b'    : 'Fold all buffers',
    \ }

  " which_key_map leader"
  let g:which_key_map[','] = {
    \ 'name': '+menu'
    \ }

  " Various"
  let g:which_key_map['v'] = {
    \ 'name': '+various',
    \ 'p': 'spell',
    \ }

  " Buffers{{{
  let g:which_key_map.b = {
    \ 'name' : '+buffer'            ,
    \ '1' : ['b1'                   , 'buffer 1']                      ,
    \ '2' : ['b2'                   , 'buffer 2']                      ,
    \ '3' : ['b3'                   , 'buffer 3']                      ,
    \ '4' : ['b4'                   , 'buffer 4']                      ,
    \ '5' : ['b5'                   , 'buffer 5']                      ,
    \ '6' : ['b6'                   , 'buffer 6']                      ,
    \ '7' : ['b7'                   , 'buffer 7']                      ,
    \ '8' : ['b8'                   , 'buffer 8']                      ,
    \ '9' : ['b9'                   , 'buffer 9']                      ,
    \ 'b' : ['Buffers'              , 'fzf-buffer']                    ,
    \ 'B' : ['ls<cr>:b<space>'      , 'buffers-list']                  ,
    \ 'd' : ['bd'                   , 'delete-buffer']                 ,
    \ 'D' : ['bw'                   , 'wipe-buffer']                   ,
    \ 'C' : ['tabclose'             , 'close-single-tab']              ,
    \ 'f' : ['bfirst'               , 'first-buffer']                  ,
    \ 'h' : ['sp'                   , 'horizontally-split-buffer']     ,
    \ 'l' : ['blast'                , 'last-buffer']                   ,
    \ 'n' : ['bnext'                , 'next-buffer']                   ,
    \ 'o' : ['bufdo normal! zM<cr>' , 'decrease-all-buffer-foldlevel'] ,
    \ 'p' : ['bprevious'            , 'previous-buffer']               ,
    \ 'Q' : ['qa'                   , 'exit-all-buffer']               ,
    \ 's' : ['Startify'             , 'startify-buffer']               ,
    \ 't' : ['tabedit'              , 'open-new-tab']                  ,
    \ 'T' : ['tabs'                 , 'list-open-tabs']                ,
    \ 'v' : ['vsp'                  , 'vertically-split-buffer']       ,
    \ 'w' : ['w'                    , 'save-buffer']                   ,
    \ 'W' : ['wa'                   , 'save-all-buffer']               ,
    \ 'x' : ['bp\|bd #<cr>'         , 'switch-buffer']                 ,
    \ '#' : ['b#'                   , 'recent-buffer']                 ,
    \ '?' : ['b <c-d>'              , 'show-buffer-commands']          ,
    \ }
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
