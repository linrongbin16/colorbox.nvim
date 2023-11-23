# 🌈 colorbox.nvim

<p align="center">
<a href="https://github.com/neovim/neovim/releases/v0.8.0"><img alt="Neovim" src="https://img.shields.io/badge/Neovim-v0.8-57A143?logo=neovim&logoColor=57A143" /></a>
<a href="https://github.com/linrongbin16/colorbox.nvim/search?l=lua"><img alt="Language" src="https://img.shields.io/github/languages/top/linrongbin16/colorbox.nvim?label=Lua&logo=lua&logoColor=fff&labelColor=2C2D72" /></a>
<a href="https://github.com/linrongbin16/gitlinker.nvim/actions/workflows/ci.yml"><img alt="ci.yml" src="https://img.shields.io/github/actions/workflow/status/linrongbin16/colorbox.nvim/ci.yml?label=GitHub%20CI&labelColor=181717&logo=github&logoColor=fff" /></a>
<a href="https://app.codecov.io/github/linrongbin16/colorbox.nvim"><img alt="codecov" src="https://img.shields.io/codecov/c/github/linrongbin16/colorbox.nvim?logo=codecov&logoColor=F01F7A&label=Codecov" /></a>
<a href="https://github.com/linrongbin16/gitlinker.nvim/actions/workflows/collect.yml"><img alt="collect.yml" src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fapi.github.com%2Frepos%2Flinrongbin16%2Fcolorbox.nvim%2Fcommits%3Fpath%3DCHANGELOG.md%26page%3D1%26per_page%3D1&query=%24%5B0%5D.commit.author.date&label=Last%20Update&labelColor=00205B&logo=githubactions&logoColor=fff" /></a>
</p>

I'm greedy that I want all the **most popular** Neovim colorschemes than only one, I'm playful that I want to change colorscheme from time to time. Are you like me?

Let's put all the ultra colorschemes into your Neovim player!

It use offline github actions to weekly collect and update the most popular Vim/Neovim colorscheme list.

> The **most popular** colorschemes are picked from below websites:
>
> - [vimcolorscheme.com/top](https://vimcolorschemes.com/top)
> - [www.trackawesomelist.com/rockerBOO/awesome-neovim](https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/#colorscheme)
>
> with below conditions:
>
> 1. Github stars &ge; 800.
> 2. Last git commit in 3 years.
> 3. For multiple plugins that contain the same color name, choose the one in following rules:
>    1. **Awesome-neovim** wins **vimcolorsheme**, since they usually has modern Neovim features (lua, lsp, treesitter) and support more third-party plugins.
>    2. More github stars.
>    3. Newer git commits.
>
> Please check [COLORSCHEMES.md](https://github.com/linrongbin16/colorbox.nvim/blob/main/COLORSCHEMES.md) for full colorschemes list.

It install color plugins via git submodules instead of copy-paste source code, so you get continuously updates from original authors instead of me, e.g. it only transport and manage, not produce.

It allow you play them with multiple playback settings (policies):

- Suffle playback.
- Play in order.
- Play in reverse order.
- Single cycle (todo).
- Specific color name (todo).

And multiple trigger timings (colorschemes don't have end time):

- On startup.
- Fixed interval (todo).
- Date time (todo).
- By filetype (todo).
- Manual (todo).

## 📖 Table of contents

- [Requirement](#-requirement)
- [Install](#-install)
  - [lazy.nvim](#lazynvim)
  - [pckr.nvim](#pckrnvim)
- [Configuration](#-configuration)
- [Development](#-development)
- [Contribute](#-contribute)

## ✅ Requirement

- Neovim &ge; 0.8.
- [Git](https://git-scm.com/).

## 📦 Install

**Warning:** if this plugin provides the main colorscheme (e.g. the `colorscheme` command right after nvim start), then make sure:

1. Don't lazy this plugin, it only takes ~4 ms to load.
2. Load this plugin before all other start plugins.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
require('lazy').setup({
    {
        'linrongbin16/colorbox.nvim',
        lazy = false, -- don't lazy this plugin if it provides the main colorscheme
        priority = 1000, -- load this plugin before all other start plugins
        build = function() require('colorbox').update() end,
        config = function() require('colorbox').setup() end,
    }
})
```

### [pckr.nvim](https://github.com/lewis6991/pckr.nvim)

```lua
require('pckr').add({
    {
        'linrongbin16/colorbox.nvim',
        run = function() require('colorbox').update() end,
        config = function() require('colorbox').setup() end,
    }
})
```

If you have issues on running multiple git clone/pull commands, try set `concurrency=1` in the `update` API:

```lua
require('colorbox').update({
    --- @type integer
    concurrency = 4,
})
```

## 🔧 Configuration

```lua
require('colorbox').setup({
    --- @type "shuffle"|"in_order"|"reverse_order"|"single"
    policy = "shuffle",

    --- @type "startup"|"interval"|"filetype"
    timing = "startup",

    -- (Optional) filter color by color name. For now there're two types of filters:
    -- 1. the "primary" filter: only the primary colors will be selected, other variants will be skip.
    -- 2. the function filter: colors will be filtered if function return true.
    --
    --- @type "primary"|fun(color:string,spec:colorbox.ColorSpec):boolean|nil
    filter = nil,

    -- (Optional) setup plugin before running `colorscheme {color}`.
    --- @type table<string, function>
    setup = {
        ["projekt0n/github-nvim-theme"] = function()
            require("github-theme").setup()
        end,
    },

    -- Run `set background=dark/light` before running `colorscheme {color}`.
    --
    --- @type "dark"|"light"|nil
    background = nil,

    -- Cache directory
    -- * For macos/linux: $HOME/.local/share/nvim/colorbox.nvim
    -- * For windows: $env:USERPROFILE\AppData\Local\nvim-data\colorbox.nvim
    --
    --- @type string
    cache_dir = string.format("%s/colorbox.nvim", vim.fn.stdpath('data')),

    -- enable debug
    --
    --- @type boolean
    debug = false,

    -- print log to console (command line)
    --
    --- @type boolean
    console_log = true,

    -- print log to file.
    --
    --- @type boolean
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

Please open [issue](https://github.com/linrongbin16/colorbox.nvim/issues)/[PR](https://github.com/linrongbin16/colorbox.nvim/pulls) for anything about colorbox.nvim.

Like colorbox.nvim? Consider

[![Github Sponsor](https://img.shields.io/badge/-Sponsor%20Me%20on%20Github-magenta?logo=github&logoColor=white)](https://github.com/sponsors/linrongbin16)
[![Wechat Pay](https://img.shields.io/badge/-Tip%20Me%20on%20WeChat-brightgreen?logo=wechat&logoColor=white)](https://github.com/linrongbin16/lin.nvim/wiki/Sponsor)
[![Alipay](https://img.shields.io/badge/-Tip%20Me%20on%20Alipay-blue?logo=alipay&logoColor=white)](https://github.com/linrongbin16/lin.nvim/wiki/Sponsor)
