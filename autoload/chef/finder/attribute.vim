let s:finder = {}

function s:finder.condition(e)  "{{{1
    let a:e.attr = s:extract_attribute(a:e.cWORD)
    call self.debug('extracted attr is ' . a:e.attr)
    return !empty(a:e.attr)
endfunction

function s:finder.find(e) "{{{1
    let found_attribute = 0
    try "{{{
        for pattern in s:search_patterns_for(a:e.attr)
            for file in self.candidate(a:e)
                call self.debug('search ' . pattern . ' in file ' . file )

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

function! s:finder.candidate(e) "{{{1
    let attr_list = s:scan(a:e.attr, '\[\(.\{-}\)\]\+')
    if len(attr_list) < 2
        return []
    endif 
    let candidate = []
    let recipe_name = s:clean_attr(attr_list[0])

    let attributes_dir = join([ a:e.path.cookbooks, recipe_name, 'attributes' ], '/')

    if isdirectory( attributes_dir )
        let candidate += split(globpath(attributes_dir, "*.rb", 1),"\n")
    else
        let candidate += split(globpath(a:e.path.attributes, "*.rb", 1),"\n")
    endif

    call self.debug("pre-prioritize: " . string(candidate))
    if attributes_dir == a:e.path.attributes
        " If there is attribute file which have same file name as current
        " recipe, it should be more likely contain target attribute.
        let f   = join([ a:e.path.attributes, a:e.basename ], '/')
        let idx = index(candidate, f)
        if idx != -1
            let f = remove(candidate, idx)
            call insert(candidate, f)
        endif
    endif
    call self.debug("post-prioritize: " . string(candidate))
    return candidate
endfunction

function! s:scan(str, pattern) "{{{1
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
