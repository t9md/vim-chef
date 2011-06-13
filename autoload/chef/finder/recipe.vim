let s:finder = {}

function s:finder.condition() "{{{1
    return (self.env.line =~# '\<include_recipe\>' && self.env.cword !=# 'include_recipe')
endfunction

function s:finder.find() "{{{1
    let [recipe ;node_part ] = split(self.env.cword, "::")

    call self.debug(string([recipe, node_part]))
    let node = empty(node_part) ? 'default.rb' : node_part[0] . ".rb"
    let fpath = join([self.env.path.cookbooks, recipe, "recipes", node ], '/')
    if filereadable(fpath)
        call self.edit(fpath)
        return 1
    else
        call self.msg(fpath . " not found")
        return 0
    endif
endfunction


function! chef#finder#recipe#new()  "{{{1
    return chef#finder#new(s:finder)
endfunction
" vim: set sw=4 sts=4 et fdm=marker:

