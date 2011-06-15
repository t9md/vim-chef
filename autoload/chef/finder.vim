let s:finderBase = {}

function! s:finderBase.new(finder) "{{{1
    let o = deepcopy(self)
    call extend(o, a:finder, 'force')
    return o
endfunction

function! s:finderBase.init(env) "{{{1
    let self.env = a:env
endfunction

function! s:finderBase.condition() "{{{1
    return 1
endfunction

function! s:finderBase.edit(fpath) "{{{1
    silent execute self.env.editcmd . ' ' . a:fpath
    call self.path_hl(a:fpath)
endfunction

function! s:finderBase.path_hl(fpath) "{{{1
    let path_str = a:fpath[len(self.env.path.cookbooks) + 1 : ]
    let [ recipe, type; rest ] = split(path_str, '/')
    let type_color = get(s:color_table, type, 'Special')
    let msgs = [[ recipe, "Directory" ], [ type, type_color ], [join(rest,'/'), 'Normal']]
    call self.msghl(msgs, '/')
endfunction

let s:color_table = {
            \ 'recipes':    "Identifier",
            \ 'attributes': "vimCommand",
            \ 'templates':  "PreProc",
            \ 'files':      "PreProc"
            \ }

function! s:finderBase.msghl(msgs, sep) "{{{1
    echohl Function
    echo "[". self.id ."] "
    let last = len(a:msgs) - 1
    for idx in range(len(a:msgs))
        let [msg, hl] = a:msgs[idx]
        silent execute 'echohl ' . hl
        echon msg
        echohl Normal
        if ! (idx == last)
            echon a:sep
        endif
    endfor
    echohl Normal
endfunction

function! s:finderBase.msg(msg) "{{{1
    try
        echohl Function
        echo "[". self.id ."] "
        echohl Normal
        echon a:msg
    finally
        echohl Normal
    endtry
endfunction

function! s:finderBase.debug(msg) "{{{1
    if !g:ChefDebug
        return
    endif
    echo "[". self.id ."] " . string(a:msg)
endfunction

function! chef#finder#new(finder) "{{{1
    let finder = s:finderBase.new(a:finder)
    return finder
endfunction
" vim: set sw=4 sts=4 et fdm=marker:
