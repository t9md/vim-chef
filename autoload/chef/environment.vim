let s:Environment = {}

function! s:Environment.new() "{{{1
    let org  = expand('%:p')
    let dirs = split(org, '/')

    let types = ['recipes', 'attributes', 'templates', 'files', 'definitions']
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
                \ 'type_idx': type_idx,
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

    " let env.recipe_root     = join([env.cookbook_root , env.recipe_name ] , '/')
    " let env.recipes_dir     = join([env.recipe_root, "recipes"        ] , '/')
    " let env.files_dir       = join([env.recipe_root, "files"          ] , '/')
    " let env.templates_dir   = join([env.recipe_root, "templates"      ] , '/')
    " let env.definitions_dir = join([env.recipe_root, "definitions"    ] , '/')
    " let env.attributes_dir  = join([env.recipe_root, "attributes"     ] , '/')
    return env
endfunction

function! chef#environment#new() "{{{1
    return s:Environment.new()
endfunction
" vim: set sw=4 sts=4 et fdm=marker:
