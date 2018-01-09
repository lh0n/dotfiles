set nocompatible    " Welcome to the 21st century
set shell=/bin/bash " Sane shell for vim.
set termguicolors   " Enable True Color support.

if has('gui_running')
  set guioptions-=T  " no toolbar
  set guifont=Roboto\ Mono\ for\ Powerline\ 12
endif

""""""""""""""""""""""""""""
" Setup Vundle and Plugins "
""""""""""""""""""""""""""""
filetype off                       " Required for proper Vundle setup
set rtp+=~/.vim/bundle/Vundle.vim  " Runtime path to initialize Vundle.
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'      " Let Vundle manage itself.

" Setup Vundle Plugins
Plugin 'tpope/vim-sensible'                " Sensible defaults.
Plugin 'tpope/vim-fugitive'                " Awesome Git integration.
Plugin 'bling/vim-airline'                 " Light-wight powerline.
Plugin 'airblade/vim-gitgutter'            " Git diff in the gutter.
Plugin 'mbbill/undotree'                   " Super undo.
Plugin 'crusoexia/vim-monokai'             " Monokai color scheme.

" End of Vundle Plugins Setup
call vundle#end()                  " Required for proper Vundle setup
filetype plugin indent on          " Required for proper Vundle setup

" Options for Vim-Airline plugin.
"
" Only load the extensions I want.
let g:airline_extensions = ['branch', 'tabline']

" Setup nice UTF8 symbols.
" Require powerline fonts to be installed.
" See: https://powerline.readthedocs.org/en/master/installation/linux.html#fontconfig
"
" Load powerine symbols.
let g:airline_powerline_fonts = 1

syntax enable
set background=dark
colorscheme monokai

set laststatus=2    " Always show status line.
set noshowmode      " Do not show the default mode indicator.
set cursorline      " Highlight active cursor line.
set colorcolumn=80  " Highlight 80th colunm.

set tabstop=2 shiftwidth=2 expandtab
