let s:finder = {}

function! s:finder.condition() "{{{1
    return index(self.lwrp_names(), self.env.cword) != -1
endfunction

function! s:finder.find() "{{{1
    let ident = self.env.cword
    call self.debug("search " . ident)

    let file = self.lwrp()[ident]
    call self.edit(file)
    call remove(self, '_cache') 
    return 1
endfunction

function! s:finder.lwrp()
    if has_key(self, '._cache')
        return self._cache
    endif
    let lwrp = {}
    for path in split(globpath(self.env.path.cookbooks, '*/providers/*.rb', 1), '\n')
        let name = join(matchlist(path, 'cookbooks/\zs\(.*\)/providers/\(.*\)\.rb$')[1:2], '_')
        let lwrp[name] = path
    endfor
    let self._cache = lwrp
    return self._cache
endfunction

function! s:finder.lwrp_names()
    return keys(self.lwrp())
endfunction

function! chef#finder#lwrp#new()  "{{{1
    return chef#finder#new(s:finder)
endfunction
" vim: set sw=4 sts=4 et fdm=marker:
