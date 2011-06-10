"=============================================================================
" File: chef.vim
" Author: t9md <taqumd@gmail.com>
" Version: 0.03
" WebPage: https://github.com/t9md/vim-chef
" License: BSD

" GUARD: {{{1
"============================================================
" if exists('g:loaded_chef')
  " finish
" endif

let g:loaded_chef = 1
let s:old_cpo = &cpo
set cpo&vim

" Declaration: {{{1
"=================================================================
let s:Environment = {}
let s:Controller = {}

if ! exists('g:ChefEditCmd')
  let g:ChefEditCmd  = 'edit '
endif

" Environment: {{{1
"=================================================================
let e = s:Environment
function! e.new() "{{{2
    let path = expand('%:p')
    " let path = '/home/maeda_taku/dev/chef/openstack-cookbooks/cookbooks/nova/recipes/default.rb'
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

" Controller: {{{1
"=================================================================
let c = s:Controller

function! c.main() "{{{2
    " let self.env = s:Environment.new()
    let env = s:Environment.new()
    let cut = len(env.cookbook_root) + 1

    "### extract attributes
    if self.findAttributes(env)
        return
    endif

    for Func in ['findSource', 'findRecipe', 'findRelated']
        let fpath = call(self[Func], [env], self)
        if !empty(fpath)
            execute g:ChefEditCmd . ' ' . fpath
            return
        endif
    endfor
endfunction 

function! s:cleanup_attr(str) "{{{2
  return substitute(a:str,'[:"'']','','g')
endfunction

function! s:extract_attribute(str) "{{{2
    try
        if a:str =~# '^@\?node\['
            return matchlist(a:str,'^@\?\(.*\)')[1]
        elseif a:str =~# '#{node\[.*\}'
            return matchlist(a:str,'#{\(.\{-}\)\}')[1]
        elseif a:str =~# '<%=\s\?@\?node\[.*%>'
            return matchlist(a:str, '<%=\s\?@\?\(.\{-}\)\s\?%>')[1]
        endif
    catch /E684/
        return ""
    endtry
endfunction

function! c.findAttributes(e) "{{{2
    let attr = s:extract_attribute(a:e.cWORD)
    if empty(attr)
        return
    endif
    let lis = split(attr, ']\|[')
    call filter(lis, '!empty(v:val)')[1:]
    call map(lis, 's:cleanup_attr(v:val)')
    call remove(lis,0)
    let  recipe = remove(lis,0)
    let  target = empty(lis) ? '' : remove(lis,0)

    let base = join([a:e.recipe_root, 'attributes'], '/')
    let candidates = map([target, 'default'], 'base . "/" . v:val . ".rb"')
    call filter(candidates, 'filereadable(v:val)')

    if empty(candidates)
        echo "can't find attribute file"
        return -1
    else
        exe  g:ChefEditCmd . ' ' . candidates[0]

        let searchword = ! empty(lis)  ? lis[-1] : target
        keepjump normal! gg
        " case sensitive!!
        call search('\<\C:\?' . searchword . '\>', 'w')
        " let search_pattern = '\<\C:\?' . searchword . '\>'
        " call cursor(searchpos(search_pattern, 'n'))
        return 1
    endif
endfunction

function! c.findSource(e) "{{{2
    if !(a:e.line =~# '\<source\>' && a:e.cword !=# 'source')
        return ""
    endif
    let type = fnamemodify(a:e.cfile, ":p:e") == 'erb' ? 'templates' : 'files'
    let fpath = join([a:e.recipe_root , type, 'default' , a:e.cfile ], '/')
    if filereadable(fpath) | return fpath | else | return "" | endif
endfunction

function! c.findRecipe(e) "{{{2
    if !(a:e.line =~# '\<include_recipe\>' && a:e.cword !=# 'include_recipe')
        return ""
    endif
    let [recipe ;node_part ] = split(a:e.cword, "::")
    let node = empty(node_part) ? 'default.rb' : node_part[0] . ".rb"
    let fpath = join([a:e.recipe_root, "recipes", node ], '/')
    if filereadable(fpath) | return fpath | else | return "" | endif
endfunction

function! c.findRelated(e) "{{{2
    let dirs = split(a:e.path, '/')
    let type_name = a:e.type_name
    let type_idx  = a:e.type_idx

    if     type_name == 'recipes'
        let dirs[type_idx] = "attributes"
    elseif type_name == 'attributes'
        let dirs[type_idx] = "recipes"
        " elseif type_name == 'templates' || type_name == 'files'
    else
        return ""
    endif
    " elseif type_name =~# '^templates$\|^files$'
        " let dirs[type_idx] = "recipes"
        " call remove(dirs, -1)
        " let dirs[-1] = dirs[-1] . '.rb'
    " endif

    let fpath = '/' . join(dirs, '/')
    if filereadable(fpath) | return fpath | else | return "" | endif
endfunction

" Command: {{{1
"=================================================================
command! ChefDoWhatIMean :call s:Controller.main()

" Finalize: {{{1
"=================================================================
let &cpo = s:old_cpo
" vim: set sw=4 sts=4 et fdm=marker fdc=3 fdl=3:
