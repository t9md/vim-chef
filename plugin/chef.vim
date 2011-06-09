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
set cpo&vim
" }}}

" Init {{{
"=================================================================
"}}}

" let lis = [":abc", "def", ":ghh"]
" call map(lis, 'v:val =~# "^:" ? v:val[1:] : v:val')
" echo lis
" " let s = ":abc"
" let s = "abc"
" if s =~# "^:"
  " echo s[1:]
" else
  " echo s
" endif
" echo substitute(s,'\(\w\+\)\.vba\(\.gz\)\?','\1','')
" function! g:ChefCookbookRoot()
  " let path = expand('%:p')
  " let dirs = split(path, '/')
  " let idx = index(dirs, 'cookbooks')
  " if idx == -1
    " return ""
  " else
    " let recipe_name = dirs[idx+1]
    " let cookbook_root = "/" . join(dirs[: idx],'/')
    " return cookbook_root
  " endif
" endfunction

" function! g:ChefRecipeName()
  " let path = expand('%:p')
  " " let path = "/etc/hosts/hoge/cookbooks/vagrant_main/recipes/default.rb"
  " " " let dirs = split(path, '/')
  " let dirs = split(path, '/')
  " let idx = index(dirs, 'cookbooks')
  " if idx == -1
    " return ""
  " else
    " let recipe_name = dirs[idx+1]
  " endif
  " return recipe_name
" endfunction

" function! g:ChefFindFile(type, name, node, ...)
  " let cookbook_root = g:ChefCookbookRoot()
  " if empty(cookbook_root)
    " return ""
  " endif

  " let result = [cookbook_root, a:name ]
  " "definitions recipes
  " if a:type == 'definitions' || a:type == 'recipes'
    " call extend(result,[ a:type, a:node . ".rb" ])
  " elseif a:type == 'templates'
    " let template = a:1
    " call extend(result,[ a:type , a:node , template ])
  " else
    " let file = a:1
    " call extend(result,[ a:type , a:node , file ])
  " endif
  " return join(result,'/')
  " " return result
" endfunction

" function! g:ChefEditRecipe(...)
  " let node = len(a:000) ? a:1 : "default"
  " echo g:ChefFindFile("recipes", g:ChefRecipeName(), node)
" endfunction

" function! g:ChefEditAttribute(...)
  " let path = expand('%:p')
  " let dirs = split(path, '/')
  " let dirs[-2] = 'attributes'
  " let file = '/' . join(dirs, '/')
  " execute 'edit ' . file
" endfunction


function! g:ChefEditRelated()
  let path = expand('%:p')
  let dirs = split(path, '/')

  let recipes_idx = index(dirs, 'recipes')
  let attributes_idx = index(dirs, 'attributes')

  if recipes_idx != -1
    let type = 'attributes'
    let dirs[recipes_idx] = type
  elseif attributes_idx != -1
    let type = 'recipes'
    let dirs[attributes_idx] = type
  endif
  let alter_file = '/' . join(dirs, '/')
  if filereadable(alter_file)
    execute 'edit ' . alter_file
  else
    echo "[" . type . "] not exist"
  endif
endfunction

function! g:ChefEditFile(...)
  let fname = len(a:000) ?  a:1 : expand('<cfile>')
  let path = expand('%:p')

  let dirs = split(path, '/')
  let idx = index(dirs, 'cookbooks')
  let recipe_name = dirs[idx+1]
  let cookbook_root = "/" . join(dirs[: idx],'/')
  let type = fnamemodify(fname,":p:e") == 'erb' ? 'templates' : 'files'
  let target = '/' . join(dirs[:idx+1] + [ type, 'default', fname], '/')

  if filereadable(target)
    execute 'edit ' . target
  else
    echo "not exist"
  endif
endfunction

function! g:ChefEditRecipe(name)
  let [recipe ;node_part ] = split(a:name, "::")
  let node = empty(node_part) ? 'default.rb' : node_part[0] . ".rb"
  let path = expand('%:p')
  let dirs = split(path, '/')
  let idx = index(dirs, 'cookbooks')
  let target = "/" . join(dirs[: idx] + [recipe, "recipes", node ] ,'/')
  if filereadable(target)
    execute 'edit ' . target
  else
    echo "not exist"
  endif
endfunction

" call g:ChefEditRecipe('mysql')
" finish

" let s1 = '  source "hostname.erb"'
" let s2 = '  source("hostname.erb")'
" let s3 = "  source 'hostname.erb'"
" echo matchlist(s1,'\<source\>[ |\(]\s*["'']\(.*\)["'']')[1]
" echo matchlist(s1,'\<source\>[ |\(]\s*["'']\(.*\)["'']')[1]
" echo matchlist(s3,'\<source\>[ |\(]\s*["'']\(.*\)["'']')[1]
" let s1 = 'include_recipe "mysql::server"'
" echo matchlist(s1,'\<include_recipe\>[ |\(]\s*["'']\(.*\)["'']')[1]
" let s1 = 'aa/recipes/hoge.rb'
" let s2 = 'aa/attributes/hoge.rb'
" echo s1 =~# '/(recipes)ibutes)]/\w\+\.rb'
" echo s2 =~# '/attributes/\w\+\.rb'
" finish
" finish
" finish

function! g:ChefDoWhatIMean()
  let line = getline('.')
  let path = expand('%:p')
  if line =~# '\<source\>' && expand('<cword>') !=# 'source'
    let file = matchlist(line,'\<source\>[ |\(]\s*["'']\(.*\)["'']')[1]
    call g:ChefEditFile(file)
  elseif line =~# '\<include_recipe\>' && expand('<cword>') !=# 'include_recipe'
    " let recipe_name = matchlist(line,'\<include_recipe\>[ |\(]\s*["'']\(.*\)["'']')[1]
    call g:ChefEditRecipe(expand('<cword>'))
  elseif expand('<cWORD>') =~# '^node\['
    call g:ChefFindAttribute(expand('<cWORD>'))
  elseif path =~# 'recipes/\w\+\.rb' || path =~# 'attributes/\w\+\.rb'
    call g:ChefEditRelated()
  else
    echo "I don't know"
  endif
endfunction

function! g:ChefFindAttribute(str)
  let lis = split(a:str, ']\|[')
  call  filter(lis, '!empty(v:val)')[1:]
  " delete simbols char
  call map(lis, "v:val =~# '^:' ? v:val[1:] : v:val")
  " delete 'node'
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
    exe 'edit ' . candidates[0]
  endif
endfunction

" Command {{{
"=================================================================
command! -nargs=1 ChefEditRecipe   :call g:ChefEditRecipe(<f-args>)
command! -nargs=? ChefEditFile     :call g:ChefEditFile(<f-args>)
command! -nargs=? ChefEditRelated   :call g:ChefEditRelated()
" }}}
" nnoremap <M-e>      :<C-u>ChefEditFile<CR>
" nnoremap <M-a>      :<C-u>ChefEditRelated<CR>
" nnoremap <M-a>      :<C-u>call g:ChefDoWhatIMean()<CR>
" nnoremap <C-w><C-f> :split | ChefEditRelated <C-R><C-w><CR>
" nnoremap <C-w><C-f> :split \| ChefEditRecipe <C-R><C-w><CR>
" command! -nargs=? ChefEditAttribute :call g:ChefEditAttribute(<q-args>)

let &cpo = s:old_cpo
" vim: foldmethod=marker
