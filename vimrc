filetype off
set nocompatible 
set encoding=utf8
set laststatus=2

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
set t_Co=256
set background=dark
colorscheme tomorrow-night 

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

set backspace=indent,eol,start

" Yank text to the OS X clipboard
noremap <leader>y "*y
noremap <leader>yy "*Y

" Preserve indentation while pasting text from the OS X clipboard
noremap <leader>p :set paste<CR>:put  *<CR>:set nopaste<CR>

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

" Source the vimrc file after saving it
if has("autocmd")
  autocmd bufwritepost .vimrc source $MYVIMRC
endif
