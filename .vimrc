packadd! dracula
syntax enable
colorscheme dracula

set encoding=utf-8 fileencodings=ucs-bom,utf-8,cp936

" Configuration file for vim
set modelines=0		" CVE-2007-2438

" Normally we use vim-extensions. If you want true vi-compatibility
" remove change the following statements
set nocompatible	" Use Vim defaults instead of 100% vi compatibility
set backspace=2		" more powerful backspacing

" Don't write backup file if vim is being called by "crontab -e"
au BufWrite /private/tmp/crontab.* set nowritebackup nobackup
" Don't write backup file if vim is being called by "chpass"
au BufWrite /private/etc/pw.* set nowritebackup nobackup

let skip_defaults_vim=1

set guifont=Menlo\ Regular:h16 



colorscheme default     " 设置颜色主题

syntax on               " 语法高亮

filetype on             " 检测文件的类型

set number              " 显示行号
set cursorline          " 用浅色高亮当前行
"autocmd InsertLeave * se nocul
"autocmd InsertEnter * se cul

set ruler               " 在编辑过程中，在右下角显示光标位置的状态行
set laststatus=2        " 显示状态栏 (默认值为 1, 无法显示状态栏)
set statusline=\ %<%F[%1*%M%*%n%R%H]%=\ %y\ %0(%{&fileformat}\ %{&encoding}\ %c:%l/%L%)\
                        " 设置在状态行显示的信息

set tabstop=4           " Tab键的宽度
set softtabstop=4
set shiftwidth=4        " 统一缩进为4

set autoindent          " vim使用自动对齐，也就是把当前行的对齐格式应用到下一行(自动缩进)
set cindent             " (cindent是特别针对 C语言语法自动缩进)
set smartindent         " 依据上面的对齐格式，智能的选择对齐方式，对于类似C语言编写上有用

set scrolloff=3         " 光标移动到buffer的顶部和底部时保持3行距离

set incsearch           " 输入搜索内容时就显示搜索结果
set hlsearch            " 搜索时高亮显示被找到的文本

set foldmethod=indent   " 设置缩进折叠
set foldlevel=99        " 设置折叠层数
nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>
                        " 用空格键来开关折叠

" 自动跳转到上次退出的位置
if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Auto add head info
" .py file into add header
function HeaderPython()
    call setline(1, "#!/usr/bin/env python")
    call append(1, "# -*- coding: utf-8 -*-")
    normal G
    normal o
endf
autocmd bufnewfile *.py call HeaderPython()




set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()

" 在这里添加你想安装的Vim插件
Bundle 'gmarik/vundle'

" Python补全强力插件
Bundle 'davidhalter/jedi'

" code complete
" Bundle 'Valloric/YouCompleteMe'

" 添加引号,括号配对补全
Bundle 'jiangmiao/auto-pairs'

" 添加/解除注释
Bundle 'scrooloose/nerdcommenter'

" markdown"
Plugin 'plasticboy/vim-markdown'
Plugin 'iamcco/markdown-preview.vim'

" Plugin 'codota/tabnine-vim'

call vundle#end()            " required




" markdown"
let g:mkdp_auto_start= 1   "打开.md文件时 自动打开预览窗口



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Quickly Run
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

map <F9> :call CompileRunGcc()<CR>

func! CompileRunGcc()
    exec "w"
    if &filetype == 'c'
        exec '!gcc % -o %<'
        exec '!time ./%<'
    elseif &filetype == 'cpp'
        exec '!g++-10 % -o %<'
        exec '!time ./%<'
    elseif &filetype == 'python'
        exec '!time python %'
    elseif &filetype == 'sh'
        :!time bash %
	elseif &filetype == 'java'
        exec '!javac %'
        exec '!time java %<'

    endif
endfunc




packadd! dracula
syntax enable
colorscheme dracula



" Plugin 'zxqfl/tabnine-vim'


