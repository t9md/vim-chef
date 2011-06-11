let s:finder = {}

function s:finder.condition(e)  "{{{1
    let a:e.attr = s:extract_attribute(a:e.cWORD)
    if g:ChefDebug
        call self.debug('extracted attr is ' . a:e.attr)
    endif
    return !empty(a:e.attr)
endfunction

function s:finder.find(e) "{{{1
    " FIXME: node entry scraping have BUG. should be fixed
    let lis = split(a:e.attr, ']\|[')
    call filter(lis, '!empty(v:val)')[1:]
    call map(lis, 's:cleanup_attr(v:val)')
    call remove(lis,0)
    let  recipe = remove(lis,0)
    let  target = empty(lis) ? '' : remove(lis,0)

    let base = a:e.path.attributes
    let candidates = map([target, 'default'], 'base . "/" . v:val . ".rb"')
    call filter(candidates, 'filereadable(v:val)')

    if g:ChefDebug
        call self.debug(candidates)
    endif

    if empty(candidates)
        echo "can't find attribute file"
        return -1
    endif
    let searchword = ! empty(lis)  ? lis[-1] : target

    " case sensitive!!
    let search_pattern = '\<\C:\?' . searchword . '\>'
    if g:ChefDebug
        call self.debug('attr searchword is ' . searchword)
    endif

    let found_attribute = 0
    for file in candidates
        if g:ChefDebug
            call self.debug('attr search in ' . file)
        endif
        
        if match(readfile(file), search_pattern) != -1
            let found_attribute = 1
            exe 'silent ' . a:e.editcmd . ' ' . file
            keepjump normal! gg
            call search(search_pattern)
            normal! zz
            break
        endif
    endfor
    if ! found_attribute
        echo "couldn't find << " . searchword . " >>"
    endif

endfunction

function! s:cleanup_attr(str) "{{{1
  return substitute(a:str,'[:"'']','','g')
endfunction

function! s:extract_attribute(str) "{{{1
    try
        if a:str =~# '^@\?node\['
            return matchlist(a:str,'^@\?\(.*\)')[1]
        elseif a:str =~# '#{node\[.*\}'
            return matchlist(a:str,'#{\(.\{-}\)\}')[1]
        elseif a:str =~# '<%=\s\?@\?node\[.*%>'
            return matchlist(a:str, '<%=\s\?@\?\(.\{-}\)\s\?%>')[1]
        endif
    catch /E684/
        return ""
    endtry
endfunction

function! chef#finder#attribute#new() "{{{1
  return chef#finder#new("AttributeFinder", s:finder)
endfunction
" vim: set sw=4 sts=4 et fdm=marker:
