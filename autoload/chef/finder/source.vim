let s:finder = {}
function s:finder.condition(e)
    return (a:e.line =~# '\<source\>' && a:e.cword !=# 'source')
endfunction

function s:finder.find(e)
    let type = fnamemodify(a:e.cfile, ":p:e") == 'erb' ? 'templates' : 'files'
    let fpath = join([a:e.recipe_root , type, 'default' , a:e.cfile ], '/')
    if filereadable(fpath) | return fpath | else | return "" | endif
endfunction

" function! ChefSourceFinder#new()
function! chef#finder#source#new()
  let o = g:ChefFinder.new("SourceFinder", s:finder)
  return o
endfunction
