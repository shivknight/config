set nocompatible

" enable syntax highlighting
syntax enable

set rtp+=/usr/local/bin/fzf
set rtp+=/usr/local/bin/git

" configure Vundle
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" install Vundle bundles
if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
  source ~/.vimrc.bundles.local
endif

Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-rhubarb'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-sensible'
Plugin 'Yggdroot/indentLine'
Plugin 'hashivim/vim-terraform'
Plugin 'powerman/vim-plugin-AnsiEsc'
Plugin 'adelarsq/vim-matchit'
Plugin 'will133/vim-dirdiff'
Plugin 'fatih/vim-go'
Plugin 'preservim/nerdtree'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'tomtom/tcomment_vim'
Plugin 'sebdah/vim-delve'
Plugin 'tpope/vim-vinegar'
Plugin 'bling/vim-airline'
Plugin 'vim-ruby/vim-ruby'
Plugin 'towolf/vim-helm'
Plugin 'alpertuna/vim-header'
" New plugins
Plugin 'preservim/tagbar'
Plugin 'dense-analysis/ale'

call vundle#end()

set diffopt+=internal,algorithm:patience

" ensure ftdetect et al work by including this after the Vundle stuff
filetype plugin indent on

set autoindent
set autoread                                                 " reload files when changed on disk, i.e. via `git checkout`
set backspace=2                                              " Fix broken backspace in some setups
set backupcopy=yes                                           " see :help crontab
set clipboard=unnamed                                        " yank and paste with the system clipboard
set directory-=.                                             " don't store swapfiles in the current directory
set encoding=utf-8
set expandtab                                                " expand tabs to spaces
set ignorecase                                               " case-insensitive search
set incsearch                                                " search as you type
set laststatus=2                                             " always show statusline
set list                                                     " show trailing whitespace
set listchars=tab:▸\ ,trail:▫
set number                                                   " show line numbers
" set relativenumber
set ruler                                                    " show where you are
set scrolloff=3                                              " show context above/below cursorline
set shiftwidth=2                                             " normal mode indentation commands use 2 spaces
set showcmd
set smartcase                                                " case-sensitive search if any caps
set softtabstop=2                                            " insert mode tab and backspace use 2 spaces
set tabstop=8                                                " actual tabs occupy 8 characters
set wildignore=log/**,node_modules/**,target/**,tmp/**,*.rbc
set wildmenu                                                 " show a navigable menu for tab completion
set wildmode=longest,list,full

" Enable basic mouse behavior such as resizing buffers.
set mouse-=a
if exists('$TMUX')  " Support resizing in tmux
  set ttymouse=xterm2
endif

" keyboard shortcuts
let mapleader = ','
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_

" in case you forgot to sudo
cnoremap w!! %!sudo tee > /dev/null %

" fdoc is yaml
autocmd BufRead,BufNewFile *.fdoc set filetype=yaml
" md is markdown
autocmd BufRead,BufNewFile *.md set filetype=markdown
autocmd BufRead,BufNewFile *.md set spell
" automatically rebalance windows on vim resize
autocmd VimResized * :wincmd =

" Fix Cursor in TMUX
if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" Don't copy the contents of an overwritten selection.
vnoremap p "_dP

" Go crazy!
if filereadable(expand("~/.vimrc.local"))
  " In your .vimrc.local, you might like:
  "
  " set autowrite
  " set nocursorline
  " set nowritebackup
  " set whichwrap+=<,>,h,l,[,] " Wrap arrow keys between lines
  "
  " autocmd! bufwritepost .vimrc source ~/.vimrc
  " noremap! jj <ESC>
  source ~/.vimrc.local
endif

set clipboard=unnamed
au VimEnter * if &diff | execute 'windo set wrap' | endif

autocmd FileType python setlocal shiftwidth=2 tabstop=2

"set switchbuf "usetab"

""" Go configurations
let g:go_fmt_command = "goimports"    " Run goimports along gofmt on each save
let g:go_auto_type_info = 1           " Automatically get signature/type info for object under cursor
let g:go_highlight_diagnostic_errors=0
let g:go_highlight_diagnostic_warnings=0
let g:go_list_type = "quickfix"
let g:go_auto_sameids = 1
nnoremap <leader>F :GoDecls<CR>
nnoremap gC :GoCallers<CR>
nnoremap gI :GoImplements<CR>
noremap <leader>e :cn<CR>
noremap <leader>E :cp<CR>

au FileType go nmap <leader>doc <Plug>(go-doc-tab)
let g:go_doc_popup_window = 1

"" vim-delv
noremap <leader>db :DlvToggleBreakpoint<CR>

" Build/Test on save.
" augroup auto_go
"   autocmd!
"   autocmd BufWritePost *.go !make &
"   autocmd BufWritePost *_test.go !make test &
" augroup end

""" NERDTree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
autocmd VimEnter * if argc() == 0 | exe 'NERDTreeFocus' | endif
noremap - :NERDTreeFocus<CR>

" Prevent opening buffers in NERDTree window
autocmd FileType nerdtree let t:nerdtree_winnr = bufwinnr('%')
autocmd BufWinEnter * call PreventBuffersInNERDTree()
function! PreventBuffersInNERDTree()
  if bufname('#') =~ 'NERD_tree' && bufname('%') !~ 'NERD_tree'
    \ && exists('t:nerdtree_winnr') && bufwinnr('%') == t:nerdtree_winnr
    \ && &buftype == '' && !exists('g:launching_fzf')
    let bufnum = bufnr('%')
    close
    exe 'b ' . bufnum
    NERDTree
  endif
  if exists('g:launching_fzf') | unlet g:launching_fzf | endif
endfunction

" Focus buffer if it's already open
au BufEnter * if bufname('#') =~ 'NERD_tree' && bufname('%') !~ 'NERD_tree' && winnr('$') > 1 | b# | exe "normal! \<c-w>\<c-w>" | :blast | endif

""" fzf
" Neighbouring files
function! s:fzf_neighbouring_files()
  let cwd = expand("%:~:.:h")
  let command = 'ag -g "" -f ' . cwd . ' --depth 2'
  echo command

  call fzf#run(fzf#wrap({ 'source': command, 'sink': 'e' }))
        "\ 'source': command,
"\ 'options': '-m -x +s'
endfunction

let g:fzf_files_options =
\ '--preview "(coderay {} || cat {}) 2> /dev/null | head -'.&lines.'"'

command! FZFNeigh call s:fzf_neighbouring_files()
nnoremap <leader>s :FZFNeigh<CR>

""" vim-fugitive
nnoremap <leader>f :GFiles<CR>
function ToggleGitStatus()
  if buflisted(bufname('.git/index'))
    bdelete .git/index
  else
    Git
  endif
endfunction
command ToggleGitStatus call ToggleGitStatus()
noremap <leader>g :ToggleGitStatus<CR>
noremap gb :Git blame<CR>
"""

function! FZFOpen(command_str)
  if (expand('%') =~# 'NERD_tree' && winnr('$') > 1)
    exe "normal! \<c-w>\<c-w>"
  endif
  exe 'normal! ' . a:command_str . "\<cr>"
endfunction

nnoremap <silent> <leader>b :call FZFOpen(':Buffers')<CR>
nnoremap <silent> <leader>G :call FZFOpen(':Ag')<CR>
nnoremap <silent> <C-g>c :call FZFOpen(':Commands')<CR>
nnoremap <silent> <C-g>l :call FZFOpen(':BLines')<CR>
nnoremap <silent> <C-n> :bnext<CR>
nnoremap <silent> <C-p> :bprevious<CR>
nnoremap <silent> <leader>d :bdelete<CR>

" vim-airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline_detect_modified=0
let g:airline_highlighting_cache = 0
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'




function! Smart_TabComplete()
  let line = getline('.')                         " current line

  let substr = strpart(line, -1, col('.')+1)      " from the start of the current
                                                  " line to one character right
                                                  " of the cursor
  let substr = matchstr(substr, "[^ \t]*$")       " word till cursor
  if (strlen(substr)==0)                          " nothing to match on empty string
    return "\<tab>"
  endif
  let has_period = match(substr, '\.') != -1      " position of period, if any
  let has_slash = match(substr, '\/') != -1       " position of slash, if any
  if (!has_period && !has_slash)
    return "\<C-X>\<C-P>"                         " existing text matching
  elseif ( has_slash )
    return "\<C-X>\<C-F>"                         " file matching
  else
    return "\<C-X>\<C-O>"                         " plugin matching
  endif
endfunction
inoremap <tab> <c-r>=Smart_TabComplete()<CR>

set updatetime=400


let g:github_enterprise_urls = ['https://git.soma.salesforce.com']

""" vim-helm
autocmd BufRead,BufNewFile */templates/**.tpl set ft=helm

""" Persistent undo
let target_path = expand('~/.config/vim-persisted-undo/')
if !isdirectory(target_path)
    call system('mkdir -p ' . target_path)
endif
let &undodir = target_path
set undofile

""" vim-header
let g:header_field_filename = 0
let g:header_field_copyright = '// Copyright © 2021 Salesforce'
let g:header_field_modified_timestamp = 0
let g:header_field_timestamp = 0
let g:header_field_modified_by = 0

nnoremap \z :setlocal foldexpr=(getline(v:lnum)=~@/)?0:(getline(v:lnum-1)=~@/)\\|\\|(getline(v:lnum+1)=~@/)?1:2 foldmethod=expr foldlevel=0 foldcolumn=2<CR>

"" ALE
let g:ale_completion_enabled = 1
set omnifunc=ale#completion#OmniFunc
