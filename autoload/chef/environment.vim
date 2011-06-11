let s:Environment = {}
function! s:Environment.new()
    let path = expand('%:p')
    let dirs = split(path, '/')
    let types = ['recipes', 'attributes', 'templates', 'files']
    let type_name = "NONE"
    let type_idx  = -1
    for type in types
        let idx = index(dirs, type)
        if idx != -1
            let type_name = type
            let type_idx = idx
            break
        endif
    endfor

    let o =  {
                \ 'line': getline('.'),
                \ 'cword': expand('<cword>'),
                \ 'cWORD': expand('<cWORD>'),
                \ 'cfile': expand('<cfile>'),
                \ 'path': path,
                \ 'recipe_name': dirs[index(dirs, 'cookbooks')+1],
                \ 'type_name': type_name,
                \ 'type_idx': type_idx,
                \ }
    let o.cookbook_root = '/' . join(dirs[0: index(dirs, 'cookbooks')], '/')
    let o.recipe_root = join([o.cookbook_root , o.recipe_name ], '/')
    return o
endfunction

function! chef#environment#new()
    return s:Environment.new()
endfunction
