<!-- markdownlint-disable MD001 MD013 MD034 MD033 MD051 -->

# 🌈 colorbox.nvim

<p>
<a href="https://github.com/neovim/neovim/releases/v0.7.0"><img alt="require" src="https://img.shields.io/badge/require-0.7%2B-blue" /></a>
<a href="https://github.com/linrongbin16/commons.nvim"><img alt="commons.nvim" src="https://img.shields.io/badge/power_by-commons.nvim-pink" /></a>
<a href="https://luarocks.org/modules/linrongbin16/colorbox.nvim"><img alt="luarocks" src="https://img.shields.io/luarocks/v/linrongbin16/colorbox.nvim" /></a>
<a href="https://github.com/linrongbin16/colorbox.nvim/actions/workflows/ci.yml"><img alt="ci.yml" src="https://img.shields.io/github/actions/workflow/status/linrongbin16/colorbox.nvim/ci.yml?label=ci" /></a>
<a href="https://github.com/linrongbin16/colorbox.nvim/actions/workflows/collect.yml"><img alt="collect.yml" src="https://img.shields.io/github/actions/workflow/status/linrongbin16/colorbox.nvim/collect.yml?label=collect" /></a>
<a href="https://app.codecov.io/github/linrongbin16/colorbox.nvim"><img alt="codecov" src="https://img.shields.io/codecov/c/github/linrongbin16/colorbox.nvim/main?label=codecov" /></a>
</p>

Do you want all the **most popular** (Neo)vim colorschemes than only one? Do you want to change colorscheme from time to time?

This is it! Let's load all the ultra colorschemes into the Neovim player!

https://github.com/linrongbin16/colorbox.nvim/assets/6496887/8fff55ea-749d-4064-90b8-a3799519898d

<details>
<summary><i>Click here to see how to configure</i></summary>

```lua
require("colorbox").setup({
  policy = { seconds = 1, implement = "shuffle" },
  timing = "interval",
})
```

</details>

It use offline github actions to weekly collect/update the colorscheme list.

> [!NOTE]
>
> The **most popular** colorschemes are picked from below websites:
>
> - [vimcolorschemes.com](https://vimcolorschemes.com)
> - [www.trackawesomelist.com - awesome-neovim](https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/#colorscheme)
>
> with below conditions:
>
> 1. Github stars &ge; 500 (default config only enable &ge; 800, see [Configuration](#-configuration)).
> 2. Last git commit in 5 years.
> 3. For multiple plugins that contain the same color name, pick by following rules:
>    1. **Awesome-neovim** wins **vimcolorsheme** (they usually support modern Neovim features).
>    2. More github stars.
>    3. Newer git commits.
>
> Please check [COLORSCHEMES.md](https://github.com/linrongbin16/colorbox.nvim/blob/main/COLORSCHEMES.md) for full colorschemes list.

It install via git submodules instead of copy-paste source code, so you get continuously updates from original authors.

It allow you play them with multiple playback settings (policies):

- Suffle playback.
- Play in order.
- Play in reverse order.
- Single cycle.

And multiple trigger timings:

- On startup.
- Fixed interval.
- Date time (todo).
- By filetype.

## 📖 Table of Contents

- [Requirements](#-requirements)
- [Install](#-install)
- [Usage](#-usage)
- [Configuration](#-configuration)
  - [Filter](#filter)
    - [Builtin Filters](#builtin-filters)
    - [Function Filters](#function-filters)
    - [List Filters](#list-filters)
  - [Timing & Policy](#timing--policy)
    - [On Nvim Start](#on-nvim-start)
    - [By Fixed Interval Time](#by-fixed-interval-time)
    - [By File Type](#by-file-type)
  - [Background](#background)
- [Receipts](#-receipts)
  - [1. Choose fixed color on nvim start](#1-choose-fixed-color-on-nvim-start)
  - [2. Change random color per second](#2-change-random-color-per-second)
  - [3. Enable all colors](#3-enable-all-colors)
  - [4. Enable only top stars (&ge; 1000) & primary colors](#4-enable-only-top-stars--1000--primary-colors)
  - [5. Disable by name](#5-disable-by-name)
  - [6. Disable by plugin](#6-disable-by-plugin)
- [Development](#-development)
- [Contribute](#-contribute)

## ✅ Requirements

- neovim &ge; 0.7.
- [git](https://git-scm.com/).
- [rm](https://man7.org/linux/man-pages/man1/rm.1.html) (optional for `reinstall` command on Windows).

<details>
<summary><i>Click here to see how to install `rm` command on Windows</i></summary>
<br/>

There're many ways to install portable linux shell and builtin commands on Windows, but personally I would recommend below two methods.

### [Git for Windows](https://git-scm.com/download/win)

Install with the below 3 options:

- In **Select Components**, select **Associate .sh files to be run with Bash**.

  <img alt="install-windows-git-step1.jpg" src="https://github.com/linrongbin16/colorbox.nvim/assets/6496887/6f2e0b34-4425-4766-85be-799d97aef80a" width="70%" />

- In **Adjusting your PATH environment**, select **Use Git and optional Unix tools from the Command Prompt**.

  <img alt="install-windows-git-step2.jpg" src="https://github.com/linrongbin16/colorbox.nvim/assets/6496887/2ff32b3b-2ade-4f3c-b25b-50e4b521f2e8" width="70%" />

- In **Configuring the terminal emulator to use with Git Bash**, select **Use Windows's default console window**.

  <img alt="install-windows-git-step3.png" src="https://github.com/linrongbin16/colorbox.nvim/assets/6496887/944147d1-e180-4e63-aecc-991c9c1093b0" width="70%" />

After this step, **git.exe** and builtin linux commands(such as **rm.exe**) will be available in `%PATH%`.

### [scoop](https://scoop.sh/)

Run below powershell commands:

```powershell
# scoop
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

scoop install uutils-coreutils     # rm
```

</details>

## 📦 Install

> [!IMPORTANT]
>
> If this plugin provides the main colorscheme (e.g. the color show right after nvim start), then make sure:
>
> 1. Don't lazy load it.
> 2. Load it before all other plugins.

> [!IMPORTANT]
>
> Some colorschemes have specific requirements:
>
> - [termguicolors](https://neovim.io/doc/user/options.html#'termguicolors')
> - [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
> - [lush.nvim](https://github.com/rktjmp/lush.nvim)
>
> Please manually add these dependencies if you enable them.

<details>
<summary><b>With <a href="https://github.com/folke/lazy.nvim">lazy.nvim</a></b></summary>

```lua
require('lazy').setup({
    {
        'linrongbin16/colorbox.nvim',

        -- don't lazy load
        lazy = false,
        -- load with highest priority
        priority = 1000,

        build = function() require("colorbox").update() end,
        config = function() require("colorbox").setup() end,
    }
})
```

</details>

<details>
<summary><b>With <a href="https://github.com/lewis6991/pckr.nvim">pckr.nvim</a></b></summary>

```lua
require('pckr').add({
    {
        'linrongbin16/colorbox.nvim',

        run = function() require("colorbox").update() end,
        config = function() require("colorbox").setup() end,
    };
})
```

</details>

## 🚀 Usage

When loading plugin, it will run following steps:

1. Run the filters, only enable the colors you choose from candidate list. See [Filter](#filter).
2. Register triggers to invoke related policies at a proper timing. See [Timing & Policy](#timing--policy).

When a timing is triggered, it will run following steps:

1. Run registered policy and choose a colorscheme. See [Timing & Policy](#timing--policy).
2. Refresh the `background` option. See [Background](#background).
3. Run `colorscheme` command to actually apply the colorscheme.

You can also use command `Colorbox` to control the player with below subcommands:

- `update`: Update all git submodules.
- `reinstall`: Clean & re-install all git submodules.
- `info`: Show detailed information and configured status.
  - **Note:** use `scale=0.7` to specify popup window's size in range `(0, 1]`, by default is `scale=0.7`.

> [!NOTE]
>
> You can still use `colorscheme` command to change colorscheme.

## 🔧 Configuration

To configure options, please use:

```lua
require("colorbox").setup(opts)
```

The `opts` is an optional lua table that override the default options.

For complete default options, please see [configs.lua](https://github.com/linrongbin16/colorbox.nvim/blob/main/lua/colorbox/configs.lua).

### Filter

There're 3 types of filter configs:

#### Builtin Filters

- `"primary"`: Only enables the main color (if there are multiple colors in one plugin).

#### Function Filters

Lua function that decide whether to enable/disable a color. It has below signature:

```lua
function(color:string, spec:colorbox.ColorSpec):boolean
```

Parameters:

- `color`: Color name.
- `spec`: Colorscheme meta info, which is the `colorbox.ColorSpec` type, see below.

Returns:

- To enable a color, returns `true`.
- To disable a color, returns `false`.

The `colorbox.ColorSpec` type is a lua table that has below fields:

- `handle`: Unique plugin name, `string` type, for example:
  - `"folke/tokyonight.nvim"`
- `url`: GitHub url, `string` type, for example:
  - `"https://github.com/folke/tokyonight.nvim"`
- `github_stars`: Github stars, `integer` type, for example:
  - `4300`
- `last_git_commit`: Last git commit date and time, `string` type, for example:
  - `"2023-10-25T18:20:36"`
- `priority`: Plugin priority, `integer` type, for example:
  - **awesome-neovim** is `100`
  - **vimcolorschemes** is `0`
- `source`: Data source, `string` type, for example:
  - **awesome-neovim** is `"https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/#colorscheme"`
- `git_path`: Git submodule file path, `string` type, for example:
  - `"folke-tokyonight.nvim"`
- `git_branch`: Optional git branch of plugin (most plugins use default main/master branch, while some have specific branch), `string?` type, for example:
  - `"neovim"`
- `color_names`: Color names that plugin contains, `string[]` type, for example:
  - `["tokyonight","tokyonight-day","tokyonight-moon","tokyonight-night","tokyonight-storm"]`

#### List Filters

A lua list that contains multiple other filters. A color will only be enabled if **all** filters returns `true`.

### Timing & Policy

#### On Nvim Start

To choose a color on nvim start, please use:

```lua
require("colorbox").setup({
    timing = "startup",
    policy = "shuffle",
})
```

There're 4 builtin policies to work with `startup` timing:

- `shuffle`: Choose a random color.
- `in_order`: Choose next color in order, color names are ordered from 'A' to 'Z'.
- `reverse_order`: Choose next color in reversed order, color names are ordered from 'Z' to 'A'.
- `single`: Choose a fixed color.

#### By Fixed Interval Time

To choose a color on a fixed interval time, please use:

```lua
require("colorbox").setup({
    timing = "interval",
    policy = { seconds = 60, implement = "in_order" },
})
```

The fixed interval timing needs to specify below 2 fields in its policy:

- `seconds`: Change to next color every X seconds.
- `implement`: The builtin policies (mentioned above) to decide which color to choose.

#### By File Type

To choose a color on buffer's file type change, please use:

```lua
require("colorbox").setup({
    timing = "filetype",
    policy = {
        mapping = {
            lua = "PaperColor",
            yaml = "everforest",
            markdown = "kanagawa",
            python = "iceberg",
        },
        empty = "tokyonight",
        fallback = "solarized8",
    },
})
```

The filetype timing needs to specify below 2 fields in its policy:

- `mapping`: Lua table that map from buffer's file type to color name.
- `empty`: **Optional** color name if file type is empty (and surely not found in `mapping`), do nothing if `nil`.
- `fallback`: **Optional** color name if file type is not found in `mapping`, do nothing if `nil`.

### Background

There're some colors (`tokyonight-day`, `rose-pine-dawn`) are forced to be light, e.g. they forced `set background=light` on loading. Thus the other following colors will continue use `light` background.

If you want to bring the dark-able colors back to `dark`, please use:

```lua
require("colorbox").setup({
    background = "dark",
})
```

It automatically `set background=dark` before run a `colorscheme` command.

## 📝 Receipts

### 1. Choose fixed color on nvim start

```lua
require("colorbox").setup({
    policy = "single",
    timing = "startup",
})
```

### 2. Change random color per second

```lua
require("colorbox").setup({
    policy = { seconds = 1, implement = "shuffle" },
    timing = "interval",
})
```

### 3. Enable all colors

```lua
require("colorbox").setup({
    filter = false,
})
```

### 4. Enable only top stars (&ge; 1000) & primary colors

```lua
require("colorbox").setup({
    filter = {
        "primary",
        function(color, spec)
            return spec.github_stars >= 1000
        end
    },
})
```

### 5. Disable by name

```lua
local function colorname_disabled(colorname)
    for _, c in ipairs({
        "iceberg",
        "ayu",
        "edge",
        "nord",
    }) do
        if string.lower(c) == string.lower(colorname) then
            return true
        end
    end
    return false
end

require("colorbox").setup({
    filter = function(color, spec)
        for _, c in ipairs(spec.color_names) do
            if colorname_disabled(c) then
                return false
            end
        end
        return true
    end
})
```

### 6. Disable by plugin

```lua
local function plugin_disabled(spec)
    for _, p in ipairs({
        "cocopon/iceberg.vim",
        "folke/tokyonight.nvim",
        "ayu-theme/ayu-vim",
        "shaunsingh/nord.nvim",
    }) do
        if string.lower(p) == string.lower(spec.handle) then
            return true
        end
    end
    return false
end

require("colorbox").setup({
    filter = function(color, spec)
        return not plugin_disabled(spec)
    end
})
```

## ✏️ Development

To develop the project and make PR, please setup with:

- [lua_ls](https://github.com/LuaLS/lua-language-server).
- [stylua](https://github.com/JohnnyMorganz/StyLua).
- [selene](https://github.com/Kampfkarren/selene).

To run unit tests, please install below dependencies:

- [vusted](https://github.com/notomo/vusted).

Then test with `vusted ./spec`.

## 🎁 Contribute

Please open [issue](https://github.com/linrongbin16/colorbox.nvim/issues)/[PR](https://github.com/linrongbin16/colorbox.nvim/pulls) for anything about colorbox.nvim.

Like colorbox.nvim? Consider

[![Github Sponsor](https://img.shields.io/badge/-Sponsor%20Me%20on%20Github-magenta?logo=github&logoColor=white)](https://github.com/sponsors/linrongbin16)
[![Wechat Pay](https://img.shields.io/badge/-Tip%20Me%20on%20WeChat-brightgreen?logo=wechat&logoColor=white)](https://github.com/linrongbin16/lin.nvim/wiki/Sponsor)
[![Alipay](https://img.shields.io/badge/-Tip%20Me%20on%20Alipay-blue?logo=alipay&logoColor=white)](https://github.com/linrongbin16/lin.nvim/wiki/Sponsor)
