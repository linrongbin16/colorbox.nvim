# 🌈 colorbox.nvim

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
> 3. For multiple plugins that contain the same color name, choose the one in following rules:
>    1. **Awesome-neovim** wins **vimcolorsheme**, since they usually has modern Neovim features (lua, lsp, treesitter) and support more third-party plugins.
>    2. More github stars.
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

## 📖 Table of contents

- [Requirement](#-requirement)
- [Install](#-install)
  - [lazy.nvim](#lazynvim)
- [Configuration](#-configuration)
- [Development](#-development)
- [Contribute](#-contribute)

## ✅ Requirement

- neovim &ge; 0.8.
- [git](https://git-scm.com/).

## 📦 Install

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
require('lazy').setup({
    {
        'linrongbin16/colorbox.nvim',
        lazy = false,
        priority = 1000,
        build = function() require('colorbox').update() end,
        config = function() require('colorbox').setup() end,
    }
})
```

> Note: don't lazy this plugin since you usually need set `colorscheme` right after start nvim (it costs ~3 ms to start).

## 🔧 Configuration

```lua
require('colorbox').setup({
    --- @type "shuffle"|"inorder"|"single"
    policy = "shuffle",

    --- @type "startup"|"interval"|"filetype"
    timing = "startup",

    --- @type "primary"|fun(color:string):boolean|nil
    filter = nil,

    --- @type table<string, function>
    setup = {
        ["projekt0n/github-nvim-theme"] = function()
            require("github-theme").setup()
        end,
    },

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

## ✏️ Development

To develop the project and make PR, please setup with:

- [lua_ls](https://github.com/LuaLS/lua-language-server).
- [stylua](https://github.com/JohnnyMorganz/StyLua).
- [luarocks](https://luarocks.org/).
- [luacheck](https://github.com/mpeterv/luacheck).

To run unit tests, please install below dependencies:

- [vusted](https://github.com/notomo/vusted).

Then test with `vusted ./test`.

## 🎁 Contribute

Please open [issue](https://github.com/linrongbin16/fzfx.nvim/issues)/[PR](https://github.com/linrongbin16/fzfx.nvim/pulls) for anything about fzfx.nvim.

Like fzfx.nvim? Consider

[![Github Sponsor](https://img.shields.io/badge/-Sponsor%20Me%20on%20Github-magenta?logo=github&logoColor=white)](https://github.com/sponsors/linrongbin16)
[![Wechat Pay](https://img.shields.io/badge/-Tip%20Me%20on%20WeChat-brightgreen?logo=wechat&logoColor=white)](https://github.com/linrongbin16/lin.nvim/wiki/Sponsor)
[![Alipay](https://img.shields.io/badge/-Tip%20Me%20on%20Alipay-blue?logo=alipay&logoColor=white)](https://github.com/linrongbin16/lin.nvim/wiki/Sponsor)
