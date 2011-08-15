let s:finder = {}

let s:relation  = {
            \ 'recipes': "attributes",
            \ 'attributes': "recipes",
            \ 'providers': "resources",
            \ 'resources': "providers",
            \ }
function! s:finder.find() "{{{1
    let candidate = []
    let related =  get(s:relation, self.env.type_name,"")
    if !empty(related)
        let candidate = [
                    \ self.env.path[related] . "/" . self.env.basename,
                    \ self.env.path[related] . "/" . "default.rb"
                    \ ]
    endif

    call self.debug(candidate)
    let related_found = 0

    for file in candidate
        if filereadable(file)
            let related_found = 1
            call self.edit(file)
            break
        endif
    endfor

    if  related_found
        return 1
    else
        if !empty(related)
            call self.msg(related . "not found")
        else
            call self.msg("can't detemine related file")
        endif
        return 0
    endif
endfunction

function! chef#finder#related#new() "{{{1
    return chef#finder#new(s:finder)
endfunction
" vim: set sw=4 sts=4 et fdm=marker:

