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
let g:ChefDebug = 1

" Command: {{{1
"=================================================================
command! ChefDoWhatIMean      :call chef#controller#main()
command! ChefDoWhatIMeanSplit :call chef#controller#main('split')

" Finalize: {{{1
"=================================================================
let &cpo = s:old_cpo
" vim: set sw=4 sts=4 et fdm=marker fdc=3 fdl=3:
