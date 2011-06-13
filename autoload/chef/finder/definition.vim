let s:finder = {}

function s:finder.condition() "{{{1
    " echo s:definition_names()
    return index(s:definition_names(), ":" . self.env.cword) != -1
endfunction

function s:finder.find() "{{{1
    return 0
endfunction

function! s:finder.definition_files()
    ret result = []
    let result = split(globpath(self.env.path.cookbooks, '*/definitions/*.rb', 1),"\n")
    return result
endfunction

function! s:definition_names()
    return keys(s:definition_table())
endfunction

function! s:definition_table()
    let table = {}
    let pattern = '^define\s\+\(:\w\+\)[, ]'
    for file in s:definition_files()
        for line in readfile(file)
            " echo line
            let m = matchlist(line, pattern)
            if !empty(m)
                let table[m[1]] = file
            endif
        endfor
    endfor
    return table
endfunction

function! chef#finder#definition#new(env)  "{{{1
  return chef#finder#new("DefinitionFinder", s:finder, a:env)
endfunction
" vim: set sw=4 sts=4 et fdm=marker:
