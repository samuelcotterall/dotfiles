filetype off
set nocompatible 
set encoding=utf8

" Shhhhh!
set noerrorbells
set visualbell

" Syntax
syntax on
filetype plugin indent on

" Pathogen
call pathogen#infect()
set clipboard=unnamed

" Colour Scheme
set background=dark
colorscheme solarized
let g:solarized_termcolors=256

" Backups
set nobackup
set nowb
set noswapfile

" Line Numbers
set number
set nowrap

" Invisibles
set list
set listchars=tab:▸\ ,eol:¬

" Tab stops
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab

" Indent
set autoindent
set smartindent

" Keymappings
let mapleader = ","
map <leader>n :NERDTreeToggle<cr> 


" http://stevelosh.com/blog/2010/09/coming-home-to-vim/
nnoremap / /\v
vnoremap / /\v
set ignorecase
set smartcase
set gdefault
set incsearch
set showmatch
set hlsearch
nnoremap <leader><space> :noh<cr>
nnoremap <tab> %
vnoremap <tab> %

" NERDTree config
let NERDTreeChDirMode=2
let NERDTreeShowBookmarks=1
let NERDTreeHightlightCursorline=1
let NERDTreeWinSize=1

" Auto reload .vimrc on save
" autocmd! bufwritepost .vimrc source %