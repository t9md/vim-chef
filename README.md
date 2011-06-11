What is this?
==================================
chef.vim is plugin which make it easy for

  * jump between `attributes` and `recipes`
  * open `recipes` by extract filename from `include_recipe`
  * open `templates` and `files`
  * jump to `attributes` file

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

Limitation
-----------------------------------------------------------------
chef.vim assume cookbooks is reside under the directory name of 'cookbooks',  
so cookboooks in either 'my_cookbooks' nor 'cookbooks_sample' work.


Keymap Example
-----------------------------------------------------------------

    au BufNewFile,BufRead */cookbooks/*  call s:SetupChef()
    function! s:SetupChef()
        nnoremap <buffer> <silent> <M-a>      :<C-u>ChefDoWhatIMean<CR>
        nnoremap <buffer> <silent> <C-w><C-f> :<C-u>ChefDoWhatIMeanSplit<CR>
    endfunction

TODO
-----------------------------------------------------------------
* more accurate attribute finding
