What is this?
==================================
chef.vim is plugin which make it easy for

  * jump between `attributes` and `recipes`
  * open `recipes` by extract filename from `include_recipe`
  * open `templates` and `files`
  * jump to `attributes` file

Current status
-----------------------------------------------------------------

Very Very *BETA* State
use this plugin at your own risk.

HOW to Use
-----------------------------------------------------------------
in following examples, assume

* `<M-a>` is mapped to `call g:ChefDoWhatIMean()<CR>`
* `^` indicate cursor position

## open template or file in current recipe

    source "grants.sql.erb"
            ^^^^^^^^^^^^^^
`<M-a>` try to open file under `templates/default/grants.sql.erb`

    source "grants.sql"
            ^^^^^^^^^^^^^^
`<M-a>` try to open file under `files/default/grants.sql`

## jump between attributes and recipes
in buffer for file under `recipes/*` or `attributes/*`
Press `<M-a>` to jump *alternate* files.
For examples, jump between `recipes/default.rb` and `attributes/default.rb`

## open recipe files

    include_recipe "nova::mysql"
                    ^^^^^^^^^^
`<M-a>` try to open `cookbooks/nova/recipes/mysql.rb`

## jump to node's attribute

    node[:apache2][:address] = node[:nova][:my_ip]
    ^^^^^^^^^^^^^^^^^^^^^^^

`<M-a>` try to open in following order

1. apache2/attribute/address.rb
2. apache2/attribute/default.rb

Keymap Example
-----------------------------------------------------------------
    au BufNewFile,BufRead */cookbooks/*  call s:SetupChef()
    function! s:SetupChef()
        set isk+=!,?,:
        " default ChefEditCmd is 'edit '
        let g:ChefEditCmd  = 'split '

        nnoremap <buffer> <silent> <M-a>      :<C-u>ChefDoWhatIMean<CR>
        nnoremap <buffer> <silent> <M-f>      :<C-u>ChefDoWhatIMeanSplit<CR>
    endfunction

TODO
-----------------------------------------------------------------
* Refactor.  Eliminate global scope variable. DRY.
* make each function return path then handle editing method 'split', 'edit' in controller.
