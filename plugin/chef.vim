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
if ! exists('g:ChefEditCmd')
  let g:ChefEditCmd  = 'edit '
endif

" Controller: {{{1
"=================================================================
let s:Controller  = {}
function! s:Controller.main(...) "{{{2
    let env = s:Environment.new()
    let env.editcmd = a:0 ? a:1 : g:ChefEditCmd
    let cut = len(env.cookbook_root) + 1

    let finders = [
                \ chef#finder#attribute#new(),
                \ chef#finder#source#new(),
                \ chef#finder#recipe#new(),
                \ chef#finder#related#new(),
                \ ]

    for finder in finders
        try
            let fpath =  finder.call(env)
            if !empty(fpath)
                execute env.editcmd . ' ' . fpath
                return
            endif
        catch /FinderComplete/
            echo v:exception
            break
        endtry
    endfor
endfunction 

" Environment: {{{1
"=================================================================
let s:Environment = {}
function! s:Environment.new() "{{{2
    let path = expand('%:p')
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

" Command: {{{1
"=================================================================
command! ChefDoWhatIMean      :call s:Controller.main()
command! ChefDoWhatIMeanSplit :call s:Controller.main('split')

" Finalize: {{{1
"=================================================================
let &cpo = s:old_cpo
" vim: set sw=4 sts=4 et fdm=marker fdc=3 fdl=3:
