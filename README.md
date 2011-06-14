                         ______   __               ____
                        / ____/  / /_     ___     / __/
                       / /      / __ `   / _ `   / /_  
                      / /___   / / / /  /  __/  / __/  
                      `____/  /_/ /_/   `___/  /_/    
                                - easy jump to target!!

What is this?
==================================
chef.vim is plugin which make it easy for

  * jump between `attributes` and `recipes`
  * open `recipes` by extract filename from `include_recipe`
  * open `templates` and `files`
  * jump to `attributes`
  * jump to `definition`

HOW to Use
-----------------------------------------------------------------
in following examples, assume

* `<M-a>` is mapped to `call g:ChefFindAny()<CR>`
* `^` indicate cursor position

## open template or file in current recipe

    source "grants.sql.erb"
            ^^^^^^^^^^^^^^
`<M-a>` try to open file under `templates/default/grants.sql.erb`

    source "grants.sql"
            ^^^^^^^^^^^^^^
`<M-a>` try to open file under `files/default/grants.sql`

## jump between attributes and recipes
In buffer for file under `recipes/*` or `attributes/*`
Press `<M-a>` to jump *related* files.
For examples, jump between `recipes/default.rb` and `attributes/default.rb`

## open recipe files

    include_recipe "nova::mysql"
                    ^^^^^^^^^^
`<M-a>` try to open `cookbooks/nova/recipes/mysql.rb`

## jump to node's attribute

    node[:apache2][:address] = node[:nova][:my_ip]
    ^^^^^^^^^^^^^^^^^^^^^^^

`<M-a>` try to find that attribute appropriate order.

## jump to definition

    apache_module "authz_groupfile"
    ^^^^^^^^^^^^^

apache_module is definition. so `<M-a>` would find and jump to position where defined.

Limitation
-----------------------------------------------------------------
chef.vim assume cookbooks is reside under the directory name of 'cookbooks',  
so cookboooks in either 'my_cookbooks' nor 'cookbooks_sample' work.

Commands
-----------------------------------------------------------------

  * ChefFindAny (oldname: ChefDoWhatIMean)
  * ChefFindAttribute
  * ChefFindRecipe
  * ChefFindDefinition
  * ChefFindSource
  * ChefFindRelated

Customize Finding target and finding order
-----------------------------------------------------------------
You can customize what you want to find in `ChefFindAny` command.
Following are default finder list.
`ChefFindAny` try to find target in this order.

    [ "Attribute", "Source", "Recipe", "Definition", "Related" ]

If you want to exclude `Related` finder from target, set following in your `.vimrc`

    let g:chef = {}
    let g:chef.any_finders = ['Attribute', 'Source', 'Recipe', 'Definition']

It's OK to remove Finder from list, but I don't recommend changing *order*.

Hook after finding success [experimental]
-----------------------------------------------------------------
After each finder success finding(return 1)
Hook function is called if hook is defined.
Hook take one argument `env`.
See "Configuration Example".

Configuration Example
-----------------------------------------------------------------

### Requirement
    au BufNewFile,BufRead */cookbooks/*  call s:SetupChef()

### Basic
    function! s:SetupChef()
        " Mouse:
        " Left mouse click to GO!
        nnoremap <buffer> <silent> <2-LeftMouse> :<C-u>ChefFindAny<CR>
        " Right mouse click to Back!
        nnoremap <buffer> <silent> <RightMouse> <C-o>

        " Keyboard:
        nnoremap <buffer> <silent> <M-a>      :<C-u>ChefFindAny<CR>
        nnoremap <buffer> <silent> <M-f>      :<C-u>ChefFindAnySplit<CR>
    endfunction

### Advanced
    function! ChefNerdTreeFind(env)
        try
            :NERDTreeFind
            let scrolloff_orig = &scrolloff
            let &scrolloff = 15
            normal! jk
            wincmd p
        finally
            let &scrolloff = scrolloff_orig
        endtry
    endfunction

    let g:chef = {}
    let g:chef.hooks = ['ChefNerdTreeFind']

    " remove 'Related' from default, I want to find 'Related' explicitly.
    let g:chef.any_finders = ['Attribute', 'Source', 'Recipe', 'Definition']

    function! s:SetupChef()
        " Mouse:
        " Left mouse click to GO!
        nnoremap <buffer> <silent> <2-LeftMouse> :<C-u>ChefFindAny<CR>
        " Right mouse click to Back!
        nnoremap <buffer> <silent> <RightMouse> <C-o>

        " Keyboard:
        nnoremap <buffer> <silent> <M-a>      :<C-u>ChefFindAny<CR>
        nnoremap <buffer> <silent> <M-f>      :<C-u>ChefFindAnySplit<CR>
        nnoremap <buffer> <silent> <M-r>      :<C-u>ChefFindRelated<CR>
    endfunction

TODO
-----------------------------------------------------------------
* Cache definition entries.
