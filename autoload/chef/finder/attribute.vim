let s:finder = {}

function s:finder.condition(e)  "{{{1
    let a:e.attr = s:extract_attribute(a:e.cWORD)
    if g:ChefDebug
        call self.debug('extracted attr is ' . a:e.attr)
    endif
    return !empty(a:e.attr)
endfunction

function s:finder.find(e) "{{{1
    let attr_list = s:scan(a:e.attr, '\[\(.\{-}\)\]\+')
    if len(attr_list) < 2
        return
    endif 
    let  recipe = s:clean_attr(attr_list[0])

    let path = join([ a:e.path.cookbooks, recipe, 'attributes' ], '/')
    let candidate = split(globpath(path, "*.rb", 1),"\n")


    if g:ChefDebug
        call self.debug(candidate)
    endif


    let found_attribute = 0
    try "{{{
        for pattern in s:search_patterns_for(a:e.attr)
            for file in candidate
                if g:ChefDebug
                    call self.debug('search ' . pattern . ' in file ' . file )
                endif

                if match(readfile(file), pattern) != -1
                    exe 'silent ' . a:e.editcmd . ' ' . file
                    keepjump normal! gg
                    call search(pattern, 'e')
                    normal! hzz
                    throw "AttributeFound"
                endif
            endfor
        endfor

    catch /AttributeFound/
        let found_attribute = 1
    endtry "}}}

    if ! found_attribute
        echo "couldn't find attributes"
    endif
endfunction

function! s:scan(str, pattern)
    let ret = []
    let pattern = a:pattern
    let nth = 1
    while 1
        let m = matchlist(a:str, pattern, 0, nth)
        if empty(m)
            break
        endif
        call add(ret, m[1])
        let nth += 1
    endwhile
    return ret
endfunction

function! s:clean_attr(str) "{{{1
  return substitute(a:str,'[:"'']','','g')
endfunction

function! s:search_patterns_for(attr) "{{{1
    let attr = a:attr
    let idx = 0
    let candidate = []
    while 1
        let idx += 1
        let idx = stridx(attr,'[',idx+1)
        if idx == -1
            break
        endif
        call add(candidate, escape(attr[idx : ], '[]') )
    endwhile
    return candidate
endfunction

function! s:extract_attribute(str) "{{{1
    let m =  matchlist(a:str, '\(node\[.*\]\)')
    if !empty(m)
        return m[1]
    else
        return ""
    endif
endfunction

function! chef#finder#attribute#new() "{{{1
  return chef#finder#new("AttributeFinder", s:finder)
endfunction
" vim: set sw=4 sts=4 et fdm=marker:
