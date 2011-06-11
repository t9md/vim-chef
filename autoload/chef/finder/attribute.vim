let s:finder = {}
function s:finder.condition(e)
    let a:e.attr = s:extract_attribute(a:e.cWORD)
    return !empty(a:e.attr)
endfunction

function s:finder.find(e)
    let lis = split(a:e.attr, ']\|[')
    call filter(lis, '!empty(v:val)')[1:]
    call map(lis, 's:cleanup_attr(v:val)')
    call remove(lis,0)
    let  recipe = remove(lis,0)
    let  target = empty(lis) ? '' : remove(lis,0)

    let base = join([a:e.recipe_root, 'attributes'], '/')
    let candidates = map([target, 'default'], 'base . "/" . v:val . ".rb"')
    call filter(candidates, 'filereadable(v:val)')

    if empty(candidates)
        echo "can't find attribute file"
        return -1
    else
        exe 'silent ' . a:e.editcmd . ' ' . candidates[0]

        let searchword = ! empty(lis)  ? lis[-1] : target
        keepjump normal! gg
        " case sensitive!!
        if !search('\<\C:\?' . searchword . '\>', 'w')
            echo "couldn't find " . searchword
        else
            normal! zz
        endif
        " let search_pattern = '\<\C:\?' . searchword . '\>'
        " call cursor(searchpos(search_pattern, 'n'))
        throw 'FinderComplete'
        return 1
    endif
endfunction

function! s:cleanup_attr(str) "{{{2
  return substitute(a:str,'[:"'']','','g')
endfunction

function! s:extract_attribute(str) "{{{2
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

function! chef#finder#attribute#new()
  " let o = g:ChefFinder.new("AttributeFinder", s:finder)
  let o = chef#finder#new("AttributeFinder", s:finder)
  return o
endfunction

