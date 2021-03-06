set nocompatible    " Welcome to the 21st century
set shell=/bin/bash " Sane shell for vim.
filetype plugin indent on  " Required for proper plugin setup
"set termguicolors   " Enable True Color support.

" Vim does not understand the alacritty terminfo yet.
" Force enable true color support.
if exists('+termguicolors')
  let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

""""""""""""""""""""""""""""""
" Setup vim-plug and Plugins "
""""""""""""""""""""""""""""""
call plug#begin('~/.vim/plugged')
Plug 'airblade/vim-gitgutter'            " Git diff in the gutter.
Plug 'ConradIrwin/vim-bracketed-paste'   " Auto set paste.
Plug 'jiangmiao/auto-pairs'              " Auto close brackets.
Plug 'junegunn/fzf'                      " Fuzzy finder.
Plug 'mbbill/undotree'                   " Super undo.
Plug 'mhinz/vim-signify'                 " Diff gutter (mercurial).
Plug 'morhetz/gruvbox'                   " Gruvbox theme.
Plug 'scrooloose/nerdtree'               " Directory tree.
Plug 'sheerun/vim-polyglot'              " Better syntax highlighting.
Plug 'tpope/vim-fugitive'                " Awesome Git integration.
Plug 'tpope/vim-sensible'                " Sensible defaults.
Plug 'tpope/vim-surround'                " Change the surroundings.
call plug#end()

" Toggle NERDTree.
map <C-f> :NERDTreeToggle<CR>

""""""""""""""""""""""""""
" End of vim-plug  Setup "
""""""""""""""""""""""""""

" Automatically change the working path to the path of the current file
autocmd BufNewFile,BufEnter * silent! lcd %:p:h

" Show line numbers
set number

" use » to mark Tabs and ° to mark trailing whitespace. This is a
" non-obtrusive way to mark these special characters.
set list listchars=tab:»\ ,trail:°

" Highlight the search term when you search for it.
set hlsearch

" By default, <shift+k> looks up man pages for the word under the cursor,
" which isn't very useful, so we map it to something else.
nnoremap <s-k> <CR>

" Set the Leader.
let mapleader=' '

" GUI setup
if has('gui_running')
  set guioptions-=T  " no toolbar
  set guifont=FiraCode\ Nerd\ Font\ Regular\ 14
endif

" Use the patience diff algorithm
set diffopt+=internal,algorithm:patience

" Set syntax highlight and colorscheme.
syntax enable
set background=dark
let g:gruvbox_italic=1
colorscheme gruvbox

set laststatus=2           " Always show status line.
set showtabline=2          " Always show the tabline.
set expandtab              " Never insert tabs.
set shiftwidth=2           " Indent with 2 spaces.
set softtabstop=2          " Number os spaces to insert as Tab.
set tabstop=8              " Number of spaces a Tab is expanded to.
set textwidth=80           " Wrap text at the 80th column.
set noshowmode             " Do not show the default mode indicator.
set showmatch              " Show matching braces / brackets.
set incsearch              " Do incremental searching.
set title                  " Let vim change my tab/window title.
set autoread               " Reads file automatically if modified outside.
set cursorline             " highlight the current line.
set cursorcolumn           " highlight the current column.
set colorcolumn=80         " highlight the column 80.
set clipboard=unnamedplus  " Yank to the X window clipboard.

" Better menus and completion
set wildmenu
set wildmode=longest:list,full

" Easy tab switching (Ctrl+Tab)
map <C-i> gt

" Shift-<direction> is normally mapped to paging the screen up/down
" I find this is annoying with how I use visual mode (V).
noremap <S-Up> <Up>                 " Map shift-up to up
noremap <S-Down> <Down>             " Map shift-down to down
inoremap <S-Up> <Up>                " Map shift-up to up in insert mode
inoremap <S-Down> <Down>            " Map shift-down to down in insert mode

" Sanity keeping commands
command -bang Q :q
command -bang W :w

" Options for powerline.
python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup

