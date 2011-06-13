"=============================================================================
" File: chef.vim
" Author: t9md <taqumd@gmail.com>
" Version: 0.8
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
if ! exists('g:ChefDebug')
  let g:ChefDebug = 0
endif
if ! exists('g:ChefDebugEveryInit')
  let g:ChefDebugEveryInit = 0
endif

if !exists('g:chef')
    let g:chef= {}
endif
if !has_key(g:chef, 'hooks')
    let g:chef.hooks = []
endif
if !has_key(g:chef, 'any_finders')
    let g:chef.any_finders = [ "Attribute", "Source", "Recipe", "Definition", "Related" ]
endif


" Command: {{{1
"=================================================================
command! ChefDoWhatIMean       :call chef#controller#findAny()
command! ChefDoWhatIMeanSplit  :call chef#controller#findAny('split')
command! ChefDoWhatIMeanVsplit :call chef#controller#findAny('vsplit')

command! ChefFindAny           :call chef#controller#findAny()
command! ChefFindAnySplit      :call chef#controller#findAny('split')
command! ChefFindAnyVsplit     :call chef#controller#findAny('vsplit')

command! ChefFindAttribute        :call chef#controller#findAttribute()
command! ChefFindAttributeSplit   :call chef#controller#findAttribute('split')
command! ChefFindAttributeVsplit  :call chef#controller#findAttribute('vsplit')

command! ChefFindRecipe           :call chef#controller#findRecipe()
command! ChefFindRecipeSplit      :call chef#controller#findRecipe('split')
command! ChefFindRecipeVsplit     :call chef#controller#findRecipe('vsplit')

command! ChefFindDefinition       :call chef#controller#findDefinition()
command! ChefFindDefinitionSplit  :call chef#controller#findDefinition('split')
command! ChefFindDefinitionVsplit :call chef#controller#findDefinition('vsplit')

command! ChefFindSource           :call chef#controller#findSource()
command! ChefFindSourceSplit      :call chef#controller#findSource('split')
command! ChefFindSourceVsplit     :call chef#controller#findSource('vsplit')

command! ChefFindRelated          :call chef#controller#findRelated()
command! ChefFindRelatedSplit     :call chef#controller#findRelated('split')
command! ChefFindRelatedVsplit    :call chef#controller#findRelated('vsplit')

" Finalize: {{{1
"=================================================================
let &cpo = s:old_cpo
" vim: set sw=4 sts=4 et fdm=marker fdc=3 fdl=3:
