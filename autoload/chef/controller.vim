let s:Controller  = {}

function! s:Controller.main(...) "{{{1

    try
        let org_iskeyword = &iskeyword
        silent set iskeyword+=:
        let env = chef#environment#new()
    finally
        let &iskeyword = org_iskeyword
    endtry

    let env.editcmd = a:0 ? a:1 : "edit"

    " let finders = [
                " \ chef#finder#attribute#new(),
                " \ chef#finder#related#new(),
                " \ ]
    let finders = [
                \ chef#finder#attribute#new(),
                \ chef#finder#source#new(),
                \ chef#finder#recipe#new(),
                \ chef#finder#related#new(),
                \ ]

    for finder in finders
        if g:ChefDebug
            call self.debug(finder.id)
        endif

        if finder.condition(env)
            if g:ChefDebug
                call self.debug('condition met for ' . finder.id)
            endif
            call finder.find(env)
            break
        endif
    endfor
endfunction 

function! s:Controller.debug(msg) "{{{1
    echo "[Controller] " . string(a:msg)
endfunction

function! chef#controller#main(...) "{{{1
    call call(s:Controller.main, a:000, s:Controller)
endfunction
" vim: set sw=4 sts=4 et fdm=marker:
