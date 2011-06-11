let s:finder = {}

function s:finder.find(e)
    let dirs = split(a:e.path, '/')
    let type_name = a:e.type_name
    let type_idx  = a:e.type_idx

    if     type_name == 'recipes'
        let dirs[type_idx] = "attributes"
    elseif type_name == 'attributes'
        let dirs[type_idx] = "recipes"
    else
        return ""
    endif
    let fpath = '/' . join(dirs, '/')
    if filereadable(fpath)
        execute a:e.editcmd . ' ' . fpath
    endif
endfunction

function! chef#finder#related#new()
  return chef#finder#new("RelatedFinder", s:finder)
endfunction

