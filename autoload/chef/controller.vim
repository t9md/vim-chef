let s:Controller  = {}
function! s:Controller.main(...)
    let env = chef#environment#new()
    let env.editcmd = a:0 ? a:1 : g:ChefEditCmd
    let cut = len(env.cookbook_root) + 1

    let finders = [
                \ chef#finder#attribute#new(),
                \ chef#finder#source#new(),
                \ chef#finder#recipe#new(),
                \ chef#finder#related#new(),
                \ ]

    for finder in finders
        try
            let fpath =  finder.call(env)
            if !empty(fpath)
                if g:ChefDebug
                    echo finder.id
                    echo fpath
                endif
                execute env.editcmd . ' ' . fpath
                return
            endif
        catch /FinderComplete/
            echo v:exception
            break
        endtry
    endfor
endfunction 

function! chef#controller#main(...)
    call call(s:Controller.main, a:000, s:Controller)
    " call s:Controller.main(a:000)
endfunction
