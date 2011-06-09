"=============================================================================
" File: chef.vim
" Author: t9md <taqumd@gmail.com>
" Version: 0.01
" WebPage: https://github.com/t9md/vim-chef
" License: BSD

" GUARD: {{{
"============================================================
" if exists('g:loaded_chef')
  " finish
" endif

let g:loaded_underchef = 1
let s:old_cpo = &cpo
if ! exists('g:ChefEditCmd')
  let g:ChefEditCmd  = 'edit '
endif
set cpo&vim
" }}}

function! g:ChefEditRelated() "{{{
  let path = expand('%:p')
  let dirs = split(path, '/')

  let recipes_idx = index(dirs, 'recipes')
  let attributes_idx = index(dirs, 'attributes')
  let templates_idx = index(dirs, 'templates')
  let files_idx = index(dirs, 'files')

  if recipes_idx != -1
    let type = 'attributes'
    let dirs[recipes_idx] = type
  elseif attributes_idx != -1
    let type = 'recipes'
    let dirs[attributes_idx] = type
  elseif templates_idx != -1
    let type = 'recipes'
    let dirs[templates_idx] = type
    call remove(dirs, -1)
    let dirs[-1] = dirs[-1] . '.rb'
  elseif files != -1
    let type = 'recipes'
    let dirs[files_idx] = type
    call remove(dirs, -1)
    let dirs[-1] = dirs[-1] . '.rb'
  endif
  let alter_file = '/' . join(dirs, '/')
  if filereadable(alter_file)
    execute g:ChefEditCmd . ' ' . alter_file
  elseif type == 'attributes'
    let tmp = split(alter_file,'/')
    let alter_file = '/' . join(tmp[:-2], "/") . "/default.rb"
    if filereadable(alter_file)
      execute g:ChefEditCmd . ' ' . alter_file
    else
      echo "[" . type . "] not exist"
    endif
  else
    echo "[" . type . "] not exist"
  endif
endfunction "}}}

function! g:ChefEditFile(...) "{{{
  let fname = len(a:000) ?  a:1 : expand('<cfile>')
  let path = expand('%:p')

  let dirs = split(path, '/')
  let idx = index(dirs, 'cookbooks')
  let recipe_name = dirs[idx+1]
  let cookbook_root = "/" . join(dirs[: idx],'/')
  let type = fnamemodify(fname,":p:e") == 'erb' ? 'templates' : 'files'
  let target = '/' . join(dirs[:idx+1] + [ type, 'default', fname], '/')

  if filereadable(target)
    execute  g:ChefEditCmd .  ' ' . target
  else
    echo "not exist"
  endif
endfunction "}}}

function! g:ChefEditRecipe(name) "{{{
  let [recipe ;node_part ] = split(a:name, "::")
  let node = empty(node_part) ? 'default.rb' : node_part[0] . ".rb"
  let path = expand('%:p')
  let dirs = split(path, '/')
  let idx = index(dirs, 'cookbooks')
  let target = "/" . join(dirs[: idx] + [recipe, "recipes", node ] ,'/')
  if filereadable(target)
    execute g:ChefEditCmd . ' ' . target
  else
    echo "not exist"
  endif
endfunction "}}}

function! g:ChefDoWhatIMean() "{{{
  let line = getline('.')
  let path = expand('%:p')
  if line =~# '\<source\>' && expand('<cword>') !=# 'source'
    " echo "source"
    let file = matchlist(line,'\<source\>[ |\(]\s*["'']\(.*\)["'']')[1]
    call g:ChefEditFile(file)
  elseif expand('<cWORD>') =~# '^node\['
    " echo "node"
    call g:ChefFindAttribute(expand('<cWORD>'))
  elseif expand('<cWORD>') =~# '^@node\['
    " echo "node"
    call g:ChefFindAttribute(expand('<cWORD>')[1:])
  elseif expand('<cWORD>') =~# '#{node\['
    let str = expand('<cWORD>')
    let nodestr = matchlist(str,'#{\(.\{-}\)\}')[1]
    call g:ChefFindAttribute(nodestr)
  elseif line =~# '\<include_recipe\>' && expand('<cword>') !=# 'include_recipe'
    echo "include_recipe"
    " let recipe_name = matchlist(line,'\<include_recipe\>[ |\(]\s*["'']\(.*\)["'']')[1]
    call g:ChefEditRecipe(expand('<cword>'))
  elseif path =~# 'recipes/\w\+\.rb' || path =~# 'attributes/\w\+\.rb'
    " echo "recipes"
    call g:ChefEditRelated()
  elseif path =~# 'templates/\w\+' || path =~# 'files/\w\+'
    " echo "templates"
    call g:ChefEditRelated()
  else
    echo "I don't know"
  endif
endfunction "}}}

function! s:cleanup_attr(str) "{{{
  return substitute(a:str,'[:"'']','','g')
endfunction "}}}

function! g:ChefFindAttribute(str) "{{{
  let lis = split(a:str, ']\|[')
  call  filter(lis, '!empty(v:val)')[1:]
  call map(lis, 's:cleanup_attr(v:val)')
  call remove(lis,0)
  let recipe = remove(lis,0)
  let target = empty(lis) ? '' : remove(lis,0)

  let path = expand('%:p')
  let dirs = split(path, '/')
  let idx = index(dirs, 'cookbooks')
  let base = "/" . join(dirs[: idx] + [recipe, 'attributes'] ,'/')
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
endfunction "}}}

" Command {{{
"=================================================================
command! -nargs=1 ChefEditRecipe   :call g:ChefEditRecipe(<f-args>)
command! -nargs=? ChefEditFile     :call g:ChefEditFile(<f-args>)
command! -nargs=? ChefEditRelated   :call g:ChefEditRelated()
" }}}

let &cpo = s:old_cpo
" vim: foldmethod=marker
