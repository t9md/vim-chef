let s:finder = {}

function s:finder.find(e) "{{{1
    let candidate = []
    let relation  = {
                \ 'recipes': "attributes",
                \ 'attributes': "recipes",
                \ }
    let related =  get(relation, a:e.type_name,"")
    if !empty(related)
        let candidate = [
                    \ a:e.path[related] . "/" . a:e.basename,
                    \ a:e.path[related] . "/" . "default.rb"
                    \ ]
    endif
    if g:ChefDebug
        call self.debug(candidate)
    endif
    for file in candidate
        if filereadable(file)
            execute a:e.editcmd . ' ' . file
            break
        endif
    endfor
endfunction

function! chef#finder#related#new() "{{{1
  return chef#finder#new("RelatedFinder", s:finder)
endfunction
" vim: set sw=4 sts=4 et fdm=marker:

