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
    let recipe_name = s:clean_attr(attr_list[0])

    let attributes_dir = join([ self.env.path.cookbooks, recipe_name, 'attributes' ], '/')

    let candidate = split(globpath(self.env.path.cookbooks, '*/attributes/*.rb', 1),"\n")

    " call self.debug("pre-prioritize: " . string(candidate))
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
    " call self.debug("post-prioritize: " . string(candidate))
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

function! s:attr_quote(attr)
    let tmp = substitute(a:attr, ":", '','g')
    let tmp = substitute(tmp, "[", "['",'g')
    return substitute(tmp, "]", "']",'g')
endfunction

function! s:attr_symbolize(attr)
    let tmp = substitute(a:attr, "'", '','g')
    return substitute(tmp, "[", '[:','g')
endfunction

function! s:clean_attr(str) "{{{1
  return substitute(a:str,'[:"'']','','g')
endfunction

function! s:finder.attr_patterns() "{{{1
    let attr = matchlist(self.env.attr, '[.*\]')[0]
    let idx = len(attr)
    let candidate = []
    let s:attr_translator = (match(attr, ':') != -1)
                \ ? function("s:attr_quote")
                \ : function("s:attr_symbolize")
    while 1
        let idx = strridx(attr, ']', idx-1)
        if idx == -1| break | endif
        let org = attr[ : idx ]
        call add(candidate, org)
        call add(candidate, call(s:attr_translator,[org]))
    endwhile
    return map(candidate, "escape(v:val, '[]')")
endfunction

function! s:extract_attribute(str) "{{{1
    " let m =  matchlist(a:str, '\(node\[[^}]*\]\)')
    let m =  matchlist(a:str, '\(\w\+\[[^}]*\]\)')
    if !empty(m)
        return m[1]
    else
        return ""
    endif
endfunction

function! chef#finder#attribute#new() "{{{1
    return chef#finder#new(s:finder)
endfunction
" vim: set sw=4 sts=4 et fdm=marker:
