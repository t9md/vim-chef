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
    " setup envrionment
    let self.env = s:Environment.new()
    let env = s:Environment.new()
    let cut = len(self.env.cookbook_root) + 1

    " extract node then find
    let line = getline('.')

    "#### `source'
    let fpath = self.findSource(env)
    " echo '[ source ] ' . fpath[ cut : ]
    if filereadable(fpath)
        execute g:ChefEditCmd . ' ' . fpath
        return
    endif

    "### extract attributes
    if expand('<cWORD>') =~# '^node\['
        call self.FindAttributes(expand('<cWORD>'))
        return
    elseif expand('<cWORD>') =~# '^@node\['
        " echo "node"
        call self.FindAttributes(expand('<cWORD>')[1:])
        return
    elseif expand('<cWORD>') =~# '#{node\['
        let str = expand('<cWORD>')
        let nodestr = matchlist(str,'#{\(.\{-}\)\}')[1]
        call self.FindAttributes(nodestr)
        return
    elseif expand('<cWORD>') =~# '<%=\s\?@\?node\['
        let nodestr = matchlist(expand('<cWORD>'),'<%=\s\?\(.\{-}\)\s\?%>')[1]
        call self.FindAttributes(nodestr)
        return
    endif

    "### include_recipe
    " echo '[ recipe ] ' . fpath[ cut : ]
    let fpath = self.RecipePath()
    if filereadable(fpath)
        execute g:ChefEditCmd . ' ' . fpath
        return
    endif

    "### jump between attributes and recipes
    let fpath = self.RelatedPath()
    " echo '[ related ] ' . fpath[ cut : ]
    if filereadable(fpath)
        execute g:ChefEditCmd . ' ' . fpath
        return
    endif
endfunction 

function! s:cleanup_attr(str) "{{{
  return substitute(a:str,'[:"'']','','g')
endfunction "}}}

function! c.FindAttributes(str) "{{{2
  let lis = split(a:str, ']\|[')
  call  filter(lis, '!empty(v:val)')[1:]
  call map(lis, 's:cleanup_attr(v:val)')
  call remove(lis,0)
  let recipe = remove(lis,0)
  let target = empty(lis) ? '' : remove(lis,0)
  
  let base = join([self.env.recipe_root, 'attributes'], '/')
  " let base = "/" . join(dirs[: idx] + [recipe, 'attributes'] ,'/')
  let candidates = map([target, 'default'], 'base . "/" . v:val . ".rb"')
  call filter(candidates, 'filereadable(v:val)')
  if empty(candidates)
    echo "can't find attribute file"
  else
    exe g:ChefEditCmd . ' ' . candidates[0]
    let searchword = ! empty(lis)  ? lis[-1] : target
    " case sensitive!!
    normal! gg
    call search('\<\C:\?' . searchword . '\>', 'w')
  endif
endfunction

function! c.findSource(e) "{{{2
    if !(a:e.line =~# '\<source\>' && a:e.cword !=# 'source')
        return ""
    endif
    let type = fnamemodify(a:e.cfile, ":p:e") == 'erb' ? 'templates' : 'files'
    return join([a:e.recipe_root , type, 'default' , a:e.cfile ], '/')
endfunction

function! c.RecipePath() "{{{2
    let cword = self.env.cword
    if !(self.env.line =~# '\<include_recipe\>' && cword !=# 'include_recipe')
        return ""
    endif
    let fname = cword
    let [recipe ;node_part ] = split(fname, "::")
    let node = empty(node_part) ? 'default.rb' : node_part[0] . ".rb"
    return join([self.env.recipe_root, "recipes", node ], '/')
endfunction

function! c.RelatedPath() "{{{2
    let dirs = split(self.env.path, '/')
    let type_name = self.env.type_name
    let type_idx  = self.env.type_idx

    if     type_name == 'recipes'
        let dirs[type_idx] = "attributes"
    elseif type_name == 'attributes'
        let dirs[type_idx] = "recipes"
    " elseif type_name == 'templates' || type_name == 'files'
    elseif type_name =~# '^templates$\|^files$'
        let dirs[type_idx] = "recipes"
        call remove(dirs, -1)
        let dirs[-1] = dirs[-1] . '.rb'
    endif

    let fpath = '/' . join(dirs, '/')
    return fpath
endfunction

" Command: {{{1
"=================================================================
command! ChefDoWhatIMean :call s:Controller.main()

" Finalize: {{{1
"=================================================================
" let g:ChefEditCmd = 'echo '
" call s:Controller.main()
let &cpo = s:old_cpo
" vim: set sw=4 sts=4 et fdm=marker fdc=3 fdl=3:
