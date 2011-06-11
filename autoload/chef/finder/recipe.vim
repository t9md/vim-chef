let s:finder = {}

function s:finder.condition(e)
    return (a:e.line =~# '\<include_recipe\>' && a:e.cword !=# 'include_recipe')
endfunction

function s:finder.find(e)
    let [recipe ;node_part ] = split(a:e.cword, "::")
    let node = empty(node_part) ? 'default.rb' : node_part[0] . ".rb"
    let fpath = join([a:e.cookbook_root, recipe, "recipes", node ], '/')
    if filereadable(fpath)
        execute a:e.editcmd . ' ' . fpath
    endif
endfunction



function! chef#finder#recipe#new()
  return chef#finder#new("RecipeFinder", s:finder)
endfunction

