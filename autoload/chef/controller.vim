let s:Controller  = {}

function! s:Controller.main(...)
    let env = chef#environment#new()
    let env.editcmd = a:0 ? a:1 : g:ChefEditCmd

    let finders = [
                \ chef#finder#attribute#new(),
                \ chef#finder#source#new(),
                \ chef#finder#recipe#new(),
                \ chef#finder#related#new(),
                \ ]

    for finder in finders
        if g:ChefDebug
            echo finder.id
        endif
        try
            if finder.condition(env)
                call finder.find(env)
                break
            endif
        catch /FinderComplete/
            echo v:exception
            break
        endtry
    endfor
endfunction 

function! chef#controller#main(...)
    call call(s:Controller.main, a:000, s:Controller)
endfunction
