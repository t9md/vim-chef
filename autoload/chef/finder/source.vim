let s:finder = {}

function s:finder.condition() "{{{1
    return (self.env.line =~# '\s\+source\>' && self.env.cword !=# 'source')
endfunction

function s:finder.find() "{{{1
    let type = self.env.ext == 'erb' ? 'templates' : 'files'
    let fpath = join([self.env.path.recipe , type, 'default' , self.env.cfile ], '/')
    if isdirectory(fpath)
        call self.msghl([[self.env.cfile, "Identifier"], [" is directory", "Normal"]], ' ')
        return 0
    elseif filereadable(fpath)
        call self.edit(fpath)
        return 1
    else
        call self.msghl([[self.env.cfile, "Identifier"], [" not found", "Normal"]], ' ')
        return 0
    endif
endfunction

function! chef#finder#source#new() "{{{1
    return chef#finder#new(s:finder)
endfunction
" vim: set sw=4 sts=4 et fdm=marker:
