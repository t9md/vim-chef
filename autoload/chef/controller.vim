let s:Controller  = {}

function! s:Controller.main(...) "{{{1
    try
        let org_iskeyword = &iskeyword
        silent set iskeyword+=:,-
        let env = chef#environment#new()
    finally
        let &iskeyword = org_iskeyword
    endtry

    let env.editcmd = a:0 ? a:1 : "edit"

    for finder in self.finders()
        call self.debug(finder.id)
        if finder.condition(env)
            call self.debug('condition met for ' . finder.id)
            call finder.find(env)
            break
        endif
    endfor
endfunction 

function! s:Controller.finders() "{{{1
    let val =  [ 
                \ chef#finder#attribute#new(),
                \ chef#finder#source#new(),
                \ chef#finder#recipe#new(),
                \ chef#finder#related#new(),
                \ ]
    return val
endfunction

function! s:Controller.debug(msg) "{{{1
    if !g:ChefDebug
        return
    endif
    echo "[Controller] " . string(a:msg)
endfunction

function! chef#controller#main(...) "{{{1
    call call(s:Controller.main, a:000, s:Controller)
endfunction
" vim: set sw=4 sts=4 et fdm=marker:
