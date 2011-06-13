let s:finder = {}

function s:finder.condition()  "{{{1
    let self.env.attr = s:extract_attribute(self.env.cWORD)
    call self.debug('extracted attr is ' . self.env.attr)
    return !empty(self.env.attr)
endfunction

function s:finder.find() "{{{1
    let found_attribute = 0
    try "{{{
        for pattern in self.attr_patterns()
            for file in self.candidate()
                call self.debug('search ' . pattern . ' in file ' . file )

                if match(readfile(file), pattern) != -1
                    call self.edit(file)
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

    if found_attribute
        return 1
    else
        call self.msghl([[self.env.attr, "Identifier"],["not found", "Normal"]], " ") 
        return 0
    endif
endfunction

function! s:finder.candidate() "{{{1
    let attr_list = s:scan(self.env.attr, '\[\(.\{-}\)\]\+')
    if len(attr_list) < 2
        return []
    endif 
    let candidate = []
    let recipe_name = s:clean_attr(attr_list[0])

    let attributes_dir = join([ self.env.path.cookbooks, recipe_name, 'attributes' ], '/')

    if isdirectory( attributes_dir )
        let candidate += split(globpath(attributes_dir, "*.rb", 1),"\n")
    else
        let candidate += split(globpath(self.env.path.attributes, "*.rb", 1),"\n")
    endif

    call self.debug("pre-prioritize: " . string(candidate))
    if attributes_dir == self.env.path.attributes
        " If there is attribute file which have same file name as current
        " recipe, it should be more likely contain target attribute.
        let f   = join([ self.env.path.attributes, self.env.basename ], '/')
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

function! s:finder.attr_patterns() "{{{1
    let attr = self.env.attr
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
    " let m =  matchlist(a:str, '\(node\[.*\]\)')
    let m =  matchlist(a:str, '\(node\[[^}]*\]\)')
    if !empty(m)
        return m[1]
    else
        return ""
    endif
endfunction

function! chef#finder#attribute#new() "{{{1
    return chef#finder#new("Attribute", s:finder)
endfunction
" vim: set sw=4 sts=4 et fdm=marker:
