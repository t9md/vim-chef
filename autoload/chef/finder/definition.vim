let s:finder = {}

function s:finder.condition() "{{{1
    " echo s:definition_names()
    return index(self.definition_names(), ":" . self.env.cword) != -1
endfunction

function s:finder.find() "{{{1
    " call self.debug(self.definition_table())
    let ident = ':' . self.env.cword
    call self.debug("search " . ident)

    let file = self.definition_table()[ident]
    call self.edit(file)
    call search(ident)
    return 1
endfunction

function! s:finder.definition_files()
    ret result = []
    let result = split(globpath(self.env.path.cookbooks, '*/definitions/*.rb', 1),"\n")
    return result
endfunction

function! s:finder.definition_names()
    let names = keys(self.definition_table())
    call self.debug(names)
    return names
endfunction

function! s:finder.definition_table()
    " if !has_key(self, '_table')
        let table = {}
        let pattern = '^define\s\+\(:\w\+\)[, ]'
        for file in self.definition_files()
            for line in readfile(file)
                " echo line
                let m = matchlist(line, pattern)
                if !empty(m)
                    let table[m[1]] = file
                    " let table[m[1]] = { 'file': file, 'mtime': getftime(file)}
                endif
            endfor
        endfor
        call self.debug("table initialized")
        let self._table = table
    " endif
    return self._table
endfunction

function! chef#finder#definition#new()  "{{{1
    return chef#finder#new(s:finder)
endfunction
" vim: set sw=4 sts=4 et fdm=marker:
