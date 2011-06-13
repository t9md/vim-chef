let s:Controller  = {}

function! s:Controller.main(...) "{{{1
    let success = 0
    try
        let org_iskeyword = &iskeyword
        silent set iskeyword+=:,-
        let env = chef#environment#new()
    finally
        let &iskeyword = org_iskeyword
    endtry

    let env.editcmd = a:0 ? a:1 : "edit"

    for finder in self.finders(env)
        call self.debug(finder.id)
        if finder.condition()
            call self.debug('condition met for ' . finder.id)
            let success = finder.find()
            break
        endif
    endfor

    call self.debug('find finish ' . finder.id)

    if success
        for s:hook in g:chef.hooks
            call self.debug('calling hook ' . s:hook )
            if type(function(s:hook)) == 2
                call call(function(s:hook),[env])
            endif
            unlet s:hook
        endfor
    endif
endfunction 

function! s:Controller.finders(env) "{{{1
    let val =  [ 
                \ chef#finder#attribute#new(a:env),
                \ chef#finder#source#new(a:env),
                \ chef#finder#recipe#new(a:env),
                \ chef#finder#definition#new(a:env),
                \ chef#finder#related#new(a:env),
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
