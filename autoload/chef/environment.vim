let s:Environment = {}

function! s:Environment.new() "{{{1
    let org  = expand('%:p')
    let dirs = split(org, '/')
    let types = ['recipes', 'attributes', 'templates', 'files', 'definitions']

    let type_name = "NONE"
    for type in types
        if index(dirs, type) != -1
            let type_name = type
            break
        endif
    endfor

    let cookbook_root = "/" . join(dirs[0: index(dirs, 'cookbooks')], '/')
    let recipe_name   = dirs[index(dirs, 'cookbooks')+1]
    let recipe_root   = cookbook_root . "/" . recipe_name

    let env =  {
                \ 'line':  getline('.'),
                \ 'cword': expand('<cword>'),
                \ 'cWORD': expand('<cWORD>'),
                \ 'cfile': expand('<cfile>'),
                \ 'basename': fnamemodify(org,":p:t"),
                \ 'ext': expand('<cfile>'),
                \ 'recipe_name': recipe_name,
                \ 'type_name': type_name,
                \ }

    let env.path = {}
    let env.path = {
                \ 'org':         org,
                \ 'cookbooks':   cookbook_root,
                \ 'recipe':      recipe_root,
                \ 'recipes':     recipe_root."/recipes",
                \ 'files':       recipe_root."/files",
                \ 'templates':   recipe_root."/templates",
                \ 'attributes':  recipe_root."/attributes",
                \ 'definitions': recipe_root."/definitions"
                \ }
    return env
endfunction

function! chef#environment#new() "{{{1
    return s:Environment.new()
endfunction
" vim: set sw=4 sts=4 et fdm=marker:
