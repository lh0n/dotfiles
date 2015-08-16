set nocompatible    " Welcome to the 21st century
set shell=/bin/bash " Sane shell for vim.
set term=screen-256color

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
Plugin 'altercation/vim-colors-solarized'  " Solarized color scheme.
Plugin 'bling/vim-airline'                 " Light-wight powerline.
Plugin 'airblade/vim-gitgutter'            " Git diff in the gutter.
Plugin 'mbbill/undotree'                   " Super undo.

" End of Vundle Plugins Setup
call vundle#end()                  " Required for proper Vundle setup
filetype plugin indent on          " Required for proper Vundle setup

" Options for Vim-Airline plugin.
"
" Only load the extensions I want.
let g:airline_extensions = ['branch', 'tabline']
"
" Setup nice UTF8 symbols.
" Require powerline fonts to be installed.
" Quick reference:
"   wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
"   wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf
"   mv PowerlineSymbols.otf ~/.fonts/
"   fc-cache -vf ~/.fonts/
"   mv 10-powerline-symbols.conf ~/.config/fontconfig/conf.d/
" Details: https://powerline.readthedocs.org/en/master/installation/linux.html#fontconfig
"
" Load powerine symbols.
let g:airline_powerline_fonts = 1

syntax enable
set background=dark
colorscheme solarized

set laststatus=2    " Always show status line.
set noshowmode      " Do not show the default mode indicator.
set cursorline      " Highlight active cursor line.
set colorcolumn=80  " Highlight 80th colunm.

set tabstop=2 shiftwidth=2 expandtab
