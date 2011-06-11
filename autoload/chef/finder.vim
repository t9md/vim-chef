let s:finderBase = {}

function! s:finderBase.new(id, finder)
    let o = a:finder
    let o.id = a:id
    call extend(o, deepcopy(self), 'keep')
    return o
endfunction

function! s:finderBase.condition(e)
    return 1
endfunction


function! chef#finder#new(id, finder)
    return s:finderBase.new(a:id, a:finder)
endfunction
