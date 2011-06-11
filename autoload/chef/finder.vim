let s:finderBase = {}

function! s:finderBase.new(id, finder) "{{{1
    let o = a:finder
    let o.id = a:id
    call extend(o, deepcopy(self), 'keep')
    return o
endfunction

function! s:finderBase.condition(e) "{{{1
    return 1
endfunction

function! s:finderBase.debug(msg) "{{{1
    echo "[". self.id ."] " . string(a:msg)
endfunction


function! chef#finder#new(id, finder) "{{{1
    return s:finderBase.new(a:id, a:finder)
endfunction
" vim: set sw=4 sts=4 et fdm=marker:
