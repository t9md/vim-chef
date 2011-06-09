What is this?
==================================
chef.vim is plugin which make it easy for

  * jump between `attributes` and `recipes`
  * open `recipes` by extract filename from `include_recipe`
  * open `templates` and `files`
  * jump to `attributes` file

Current status
-----------------------------------------------------------------
    Very Very BETA State

Command
-----------------------------------------------------------------

    TODO

Keymap Example
-----------------------------------------------------------------
    au BufNewFile,BufRead /cookbooks/  call s:SetupChef()
    function! s:SetupChef()
        nnoremap <buffer> <M-a>      :<C-u>call g:ChefDoWhatIMean()<CR>
        nnoremap <buffer> <C-w><C-f> :split \| ChefEditRecipe <C-R><C-w><CR>
    endfunction
