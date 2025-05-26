# 🌈 colorbox.nvim

<p>
<a href="https://github.com/neovim/neovim/releases/"><img alt="require" src="https://img.shields.io/badge/require-stable-blue" /></a>
<a href="https://github.com/linrongbin16/commons.nvim"><img alt="commons.nvim" src="https://img.shields.io/badge/power_by-commons.nvim-pink" /></a>
<a href="https://luarocks.org/modules/linrongbin16/colorbox.nvim"><img alt="luarocks" src="https://img.shields.io/luarocks/v/linrongbin16/colorbox.nvim" /></a>
<a href="https://github.com/linrongbin16/colorbox.nvim/actions/workflows/ci.yml"><img alt="ci.yml" src="https://img.shields.io/github/actions/workflow/status/linrongbin16/colorbox.nvim/ci.yml?label=ci" /></a>
<a href="https://github.com/linrongbin16/colorbox.nvim/actions/workflows/collect.yml"><img alt="collect.yml" src="https://img.shields.io/github/actions/workflow/status/linrongbin16/colorbox.nvim/collect.yml?label=collect" /></a>
<a href="https://app.codecov.io/github/linrongbin16/colorbox.nvim"><img alt="codecov" src="https://img.shields.io/codecov/c/github/linrongbin16/colorbox.nvim/main?label=codecov" /></a>
</p>

Do you want all the **most popular** (Neo)Vim colorschemes than only one? Do you want to change them from time to time?

This is it! Let's load all the ultra colorschemes into Neovim player!

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

It uses GitHub actions to weekly collect/update the colorscheme dataset.

> [!NOTE]
>
> The **most popular** colorschemes are picked from below websites:
>
> - [vimcolorschemes.com](https://vimcolorschemes.com)
> - [www.trackawesomelist.com - awesome-neovim](https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/#colorscheme)
>
> With below conditions:
>
> 1. GitHub stars &ge; 500 (by default it only enable &ge; 800, see [Configuration](#-configuration)).
> 2. Last git commit is in last 10 years.
> 3. For multiple plugins that contain the same color name, it picks one from them by a weighted scoring algorithm based on multiple attributes:
>    1. If a plugin is especially for Neovim (i.e. it is from **awesome-neovim**), it earns extra 10 points.
>    2. If a plugin has latest git commits, it earns extra 10 points.
>    3. In these multiple plugins, the score of each repository is the `star / max(stars of all repositories) * 80`. For example, if we have 3 plugins with stars 500, 380 and 71, then the 1st repository with most stars (500) has 80 points, the 2nd (380) has 60.8 points (`60.8 = 380 / 500 * 80`), the 3rd (71) has 11.36 points (`11.36 = 71 / 500 * 80`).
>
> Please check [COLORSCHEMES.md](https://github.com/linrongbin16/colorbox.nvim/blob/main/COLORSCHEMES.md) for full colorscheme dataset.

It installs colorschemes via git submodule instead of copy-paste source code, so you get continuously updates from original authors.

It allows you to play them with multiple playback settings(policies):

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
- [How it Works](#-how-it-works)
- [Usage](#-usage)
- [Configuration](#-configuration)
  - [Filter](#filter)
  - [Timing](#timing)
  - [Policy](#policy)
  - [Background](#background)
  - [Hook](#hook)
- [Receipts](#-receipts)
  - [Choose fixed color on nvim start](#choose-fixed-color-on-nvim-start)
  - [Choose random color on nvim start](#choose-fixed-color-on-nvim-start)
  - [Change random color per second](#change-random-color-per-second)
  - [Choose color by file type](#choose-color-by-file-type)
  - [Enable all colors](#enable-all-colors)
  - [Enable only top stars (&ge; 1000) & primary colors](#enable-only-top-stars--1000--primary-colors)
  - [Disable by name](#disable-by-name)
  - [Disable by plugin](#disable-by-plugin)
- [Development](#%EF%B8%8F-development)
- [Contribute](#-contribute)

## ✅ Requirements

> [!NOTE]
> This plugin always supports with the latest stable and (possibly) nightly Neovim version.

- Neovim &ge; 0.10.
- [Git](https://git-scm.com/).

## 📦 Install

> [!IMPORTANT]
>
> If this plugin provides the main colorscheme (i.e. the color show right after nvim start), then make sure:
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

## 🎬 How it Works

When loading this plugin, it does below steps:

1. Runs the filters, only enables the colors you choose from the dataset (see [Filter](#filter)).
2. Registers the triggers to invoke related policies at a proper timing (see [Timing](#timing)).

When a timing is triggered, it does below steps:

1. Runs the registered policy and pick a colorscheme (see [Policy](#policy)).
2. Refreshes the `background` option (see [Background](#background)).
3. Runs the `colorscheme` command to actually apply the colorscheme.

## 🚀 Usage

You can use the `Colorbox` command with below subcommands:

- `update`: Update all git submodules.
- `info`: Show detailed information and configured status.

  > **Note:** use `scale=0.7` to specify popup window's size in range `(0, 1]`, by default is `scale=0.7`.

- `shuffle`: Change to a random color.

> [!NOTE]
>
> You can still use the `colorscheme` command to change a colorscheme.

## 🔧 Configuration

To configure options, please use:

```lua
require("colorbox").setup(opts)
```

The `opts` is an optional lua table that override the default options. Here we only introduce some of the most options.

For complete default options, please see [configs.lua](https://github.com/linrongbin16/colorbox.nvim/blob/main/lua/colorbox/configs.lua).

### Filter

The `filter` option is to help user filter some colorschemes from the dataset, thus they will never show up.

There're 3 kinds of filters:

- Builtin filter: A lua string that presents the name of a builtin filter. For now we only have the `"primary"` builtin filter, it only enables the primary color in a plugin, filters all other color variants (when there're multiple colors in one plugin).
- Function filter: A lua function that decides whether to enable/disable a color. It uses the function signature:

  ```lua
  function(color:string, spec:colorbox.ColorSpec):boolean
  ```

  The function has two parameters:

  - `color`: The colorscheme name.
  - `spec`: The colorscheme's meta info, please see [`@class colorbox.ColorSpec`](https://github.com/linrongbin16/colorbox.nvim/blob/67b7724adfb38d84ad86ff9f3e780ad8118f6fff/lua/colorbox/db.lua?plain=1#L1-L11) for more details.

  It returns `true` to enable a color, `false` to disable a color.

- List filter: A lua list that contains multiple function filters and builtin filters. A colorscheme will only be enabled if _**all**_ these filters returns `true`.

### Timing

The `timing` option is to configure when to change to next colorscheme.

There're 3 kinds of timings:

- `startup`: On nvim start. It works exactly like manually adding the script `colorscheme xxx` in nvim's init config file.
- `interval`: On fixed interval timeout. It registers a background job to schedule on a fixed interval timeout (i.e. every X seconds), and triggers the next colorscheme.
- `filetype`: On file type change. It listens to current buffer's file type, and triggers the next colorscheme if the file type changed.

### Policy

The `policy` option is to configure how to pick the next colorscheme.

There're 3 kinds of policies (they work with the corresponding timings):

- Builtin policy: A lua string that presents the name of a builtin policy. For now we have 4 builtin policies (see below). It can works directly with the `startup` timing (see: [Choose random color on nvim start](#choose-fixed-color-on-nvim-start)).

  - `shuffle`: Pick a random color.
  - `in_order`: Pick next color in order, color names are ordered from 'A' to 'Z'.
  - `reverse_order`: Pick next color in reversed order, color names are ordered from 'Z' to 'A'.
  - `single`: Always pick the same color, i.e. next color is still the current color.

- Fixed interval timeout policy: A lua table that contains `seconds` and `implement` fields. It works with the `interval` timing (see: [Change random color per second](#change-random-color-per-second)).

  - `seconds`: Choose next colorscheme on every X seconds.
  - `implement`: The name of the builtin policy that choose how to pick the next colorscheme.

- File type policy: A lua table that contains `mapping` and (optional) `empty` and (optional) `fallback` fields. It works with the `filetype` timing (see: [Choose color by file type](#choose-color-by-file-type)).

  - `mapping`: A lua table that maps from file type to color name. When current buffer's file type is hitted, it changes to the mapped color.
  - (Optional) `empty`: The color name when the file type is empty lua string. When set to `nil`, it does nothing.
  - (Optional) `fallback`: The color name when the file type is not found in `mapping` field. When set to `nil`, it does nothing.

### Background

The `background` option runs `set background=dark/light` every time before running the `colorscheme` command (to change a colorscheme).

```lua
require("colorbox").setup({
  background = "dark",
})
```

Some colors (`tokyonight-day`, `rose-pine-dawn`, etc) are forced to be light, i.e. they forced the `background` option to `light` inside their internal implementations.

This is no problem, except some user may want all those following colorschemes (after `tokyonight-day` and `rose-pine-dawn`) go back to `dark` background if they're dark-able.

### Hook

To execute a hook function after policy is triggered and new colorscheme is applied, please use:

```lua
require("colorbox").setup({
  post_hook = function(color, spec)
    vim.notify(string.format("Colorscheme changed to: %s", vim.inspect(color)))
  end,
})
```

The hook accepts a lua function with below signature:

```lua
function(color:string, spec:colorbox.ColorSpec):nil
```

## 📝 Receipts

### Choose fixed color on nvim start

```lua
require("colorbox").setup({
  policy = "single",
  timing = "startup",
})
```

### Choose random color on nvim start

```lua
require("colorbox").setup({
  policy = "shuffle",
  timing = "startup",
})
```

### Change random color per second

```lua
require("colorbox").setup({
  policy = { seconds = 1, implement = "shuffle" },
  timing = "interval",
})
```

### Choose color by file type

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

### Enable all colors

```lua
require("colorbox").setup({
  filter = false,
})
```

### Enable only top stars (&ge; 1000) & primary colors

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

### Disable by name

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

### Disable by plugin

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
[![Wechat Pay](https://img.shields.io/badge/-Tip%20Me%20on%20WeChat-brightgreen?logo=wechat&logoColor=white)](https://linrongbin16.github.io/lin.nvim/#/sponsor?id=wechat-pay)
[![Alipay](https://img.shields.io/badge/-Tip%20Me%20on%20Alipay-blue?logo=alipay&logoColor=white)](https://linrongbin16.github.io/lin.nvim/#/sponsor?id=alipay)
