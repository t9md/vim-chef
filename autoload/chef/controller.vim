let s:finders = {}
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

    for finder in self.finders
        call self.debug(finder.id)

        call finder.init(env)
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


function! s:Controller.debug(msg) "{{{1
    if !g:ChefDebug | return | endif
    echo "[Controller] " . string(a:msg)
endfunction


function! s:finder_for(name)
    if !has_key(s:finders, a:name) || g:ChefDebugEveryInit
        let s:finders[a:name] = s:create_finder(a:name)
    endif
    return s:finders[a:name]
endfunction

function! s:create_finder(name)
    let finder = chef#finder#{tolower(a:name)}#new()
    let finder.id = a:name
    call finder.debug("initialized")
    return finder
endfunction

function! chef#controller#findAny(...) "{{{1
    let s:Controller.finders = map(copy(g:chef.any_finders), "s:finder_for(v:val)")
    call call(s:Controller.main, a:000, s:Controller)
endfunction

function! chef#controller#findAttribute(...) "{{{1
    let s:Controller.finders = [ s:finder_for("Attribute") ]
    call call(s:Controller.main, a:000, s:Controller)
endfunction

function! chef#controller#findSource(...) "{{{1
    let s:Controller.finders = [ s:finder_for("Source") ]
    call call(s:Controller.main, a:000, s:Controller)
endfunction

function! chef#controller#findRecipe(...) "{{{1
    let s:Controller.finders = [ s:finder_for("Recipe") ]
    call call(s:Controller.main, a:000, s:Controller)
endfunction

function! chef#controller#findDefinition(...) "{{{1
    let s:Controller.finders = [ s:finder_for("Definition") ]
    call call(s:Controller.main, a:000, s:Controller)
endfunction

function! chef#controller#findRelated(...) "{{{1
    let s:Controller.finders = [ s:finder_for("Related") ]
    call call(s:Controller.main, a:000, s:Controller)
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
