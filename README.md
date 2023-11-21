# colorbox.nvim

I'm greedy that I want all the **most popular** Neovim colorschemes than only one, I'm playful that I want to change colorscheme from time to time. Are you like me?

This is it!

It use offline github actions to weekly collect and update the most popular Vim/Neovim colorscheme list.

> The **most popular** colorschemes are picked from below websites:
>
> - [vimcolorscheme.com/top](https://vimcolorschemes.com/top)
> - [www.trackawesomelist.com/rockerBOO/awesome-neovim](https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/#colorscheme)
>
> with below conditions:
>
> 1. Github stars &ge; 900.
> 2. Last git commit in 3 years.
> 3. For multiple variants, choose the one in following rules:
>    1. **Awesome-neovim** wins **vimcolorsheme**, since they usually has modern Neovim features (lua, lsp, treesitter) and support more third-party plugins.
>    2. Moe github stars.
>    3. Newer git commits.

It install color plugins via git submodules instead of copy-paste source code, so you get continuously updates from original authors instead of me, e.g. it only transport and manage, not produce.

It allow you do any switches with:

- Multiple policies:
  - Suffle playback.
  - Play in order(todo).
  - Single cycle(todo).
- Multiple timing:
  - On startup.
  - Fixed interval(todo).
  - By filetype(todo).

Please check [COLORSCHEMES.md](https://github.com/linrongbin16/colorbox.nvim/blob/main/COLORSCHEMES.md) for full colorschemes list.

## Requirement

- neovim &ge; 0.8.
- [git](https://git-scm.com/).

## Install

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
require('lazy').setup({
    {
        'linrongbin16/colorbox.nvim',
        build = function() require('colorbox').update() end,
    }
})
```

## Configuratoin

```lua
require('colorbox').setup({
    --- @type "shuffle"|"inorder"|"single"
    policy = "shuffle",

    --- @type "startup"|"interval"|"filetype"
    timing = "startup",

    --- @type "primary"|fun(color:string):boolean|nil
    filter = nil,

    --- @type "dark"|"light"|nil
    background = nil,

    -- enable debug
    debug = false,

    -- print log to console (command line)
    console_log = true,

    -- print log to file.
    file_log = false,
})
```
