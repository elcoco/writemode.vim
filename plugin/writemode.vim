" Config option for textwidth (defaults to 80) 
" let g:plugin_center_textwidth = 80

function! SetSidebar()
    setlocal noma                           " set readonly
    setlocal nocursorline                   " disable cursor
    setlocal nonumber                       " show no linenumbers
    silent! setlocal norelativenumber
endfunction

function! BackupSettings()
    " Save the current 'scrolloff' value for reset later
    let s:save_scrolloff = ""
    if exists( "&scrolloff" )
        let s:save_scrolloff = &scrolloff
    endif

    " Save the current 'laststatus' value for reset later
    let s:save_laststatus = ""
    if exists( "&laststatus" )
        let s:save_laststatus = &laststatus
    endif

    " Save the current 'textwidth' value for reset later
    let s:save_textwidth = ""
    if exists( "&textwidth" )
        let s:save_textwidth = &textwidth
    endif
endfunction

function! RestoreSettings()
    if s:save_scrolloff != ""
        exec( "set scrolloff=" . s:save_scrolloff )
    endif
    if s:save_laststatus != ""
        exec( "set laststatus=" . s:save_laststatus )
    endif
    if s:save_textwidth != ""
        exec( "set textwidth=" . s:save_textwidth )
    endif
endfunction

function! ChangeSettings()
    set scrolloff=10
    set laststatus=0
    "set nonumber
    " Set textwidth to the configured variable
    exec( "set textwidth=".g:plugin_center_textwidth )  
endfunction

function! DistractionFreeWriting()
    if exists( "g:distractionfree_running" )
        unlet g:distractionfree_running
        setlocal number
        setlocal textwidth=0                    " reset textwidth
        setlocal nowrap                         " disable wrapping
        setlocal nolinebreak                    " disable linebreaks
        setlocal laststatus=2                   " show status line
        setlocal nospell                        " turn off spelling
        return
    else
        let g:distractionfree_running = 1
        setlocal nonumber
        setlocal textwidth=80
        setlocal wrap                           " automatically start new line when textwidth is reached
        setlocal linebreak                      " break the lines on words
        setlocal laststatus=0                   " don't show status line
        setlocal spell spelllang=nl,en_us       " turn on spelling
        " if vim starts complaining about the spelling files, delete the
        " spell files that came with vim (sudo mv /usr/share/vim/vim73/spell/* ~/tmp)

        " format suggestions in a list
        nnoremap <C-P> ea<C-X><C-S>                 
        hi clear SpellBad                           " reset colors
        hi clear SpellCap
        hi clear SpellRare
        hi clear SpellLocal
        hi SpellBad ctermfg=red guifg=red           " bad spelling
        hi SpellCap ctermfg=green guifg=green       " bad capitalisation
        hi SpellRare ctermfg=magenta guifg=magenta  " weird words
        hi SpellLocal ctermfg=yellow guifg=yellow   " other region
    endif
endfunction

function! CloseBuffers()
    " Check if plugin is running. The separation of this function is handy
    " cause we want to rebind :q :q! :wq, so we need to be able to call it
    if exists( "g:center_plugin_running" )
        unlet g:center_plugin_running           
        wincmd l
        close
        wincmd h
        close
        call RestoreSettings()
    endif
endfunction

function! ToggleCenter()
    " Close split windows if plugin already running
    if exists( "g:center_plugin_running" )
        call CloseBuffers()
    else
        " Set textwidth for main window
        if !exists( "g:plugin_center_textwidth" )
            let g:plugin_center_textwidth = 80
        endif

        " If window is big enough, do something
        if g:plugin_center_textwidth + 4 < winwidth(winnr())

            " Set var as running
            let g:center_plugin_running = 1

            " Backup and change all necessary settings
            call BackupSettings()
            call ChangeSettings()

            " Calculate sidebar width
            let s:sidebar = ( winwidth( winnr() ) - g:plugin_center_textwidth - 2 ) / 2

            " Create the left sidebar, apply settings and switch back
            exec( "silent leftabove " . s:sidebar . "vsplit new" )
            call SetSidebar()
            wincmd l        

            " Create the right sidebar, apply settings and switch back
            exec( "silent rightbelow " . s:sidebar . "vsplit new" )
            call SetSidebar()
            wincmd h        

            " Turn tilde characters black
            hi NonText guifg=bg ctermfg=bg
            " Don't show split characters (note the space after the '\' character)
            set fillchars+=vert:\ 
        endif
    endif
endfunction

" TODO Change keybindings to :q et all to call CloseBuffers()
" Setup keys
map <silent> <F8> :call ToggleCenter()<CR><CR>:call DistractionFreeWriting()<CR><CR>
"cnoreabbrev q <F8><CR>:q
"cnoremap q :call CloseBuffers()<CR>:q<CR>
"cnoreabbrev q! <F8><CR>:q!<CR>
"cnoreabbrev wq <F8><CR>:wq<CR>
