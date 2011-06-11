let s:finder = {}

function s:finder.condition(e) "{{{1
    return (a:e.line =~# '\<source\>' && a:e.cword !=# 'source')
endfunction

function s:finder.find(e) "{{{1
    let type = a:e.ext == 'erb' ? 'templates' : 'files'
    let fpath = join([a:e.path.recipe , type, 'default' , a:e.cfile ], '/')
    if filereadable(fpath)
        execute a:e.editcmd . ' ' . fpath
    endif
endfunction

function! chef#finder#source#new() "{{{1
  return chef#finder#new("SourceFinder", s:finder)
endfunction
" vim: set sw=4 sts=4 et fdm=marker:
