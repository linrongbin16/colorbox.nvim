# 🌈 colorbox.nvim

<!-- query a github file last update timestamp: https://stackoverflow.com/a/50204589/4438921 -->

<p align="center">
<a href="https://github.com/neovim/neovim/releases/v0.8.0"><img alt="Neovim" src="https://img.shields.io/badge/Neovim-v0.8+-57A143?logo=neovim&logoColor=57A143" /></a>
<a href="https://github.com/linrongbin16/commons.nvim"><img alt="commons.nvim" src="https://custom-icon-badges.demolab.com/badge/Powered_by-commons.nvim-teal?logo=heart&logoColor=fff&labelColor=red" /></a>
<a href="https://luarocks.org/modules/linrongbin16/colorbox.nvim"><img alt="luarocks" src="https://custom-icon-badges.demolab.com/luarocks/v/linrongbin16/colorbox.nvim?label=LuaRocks&labelColor=2C2D72&logo=tag&logoColor=fff&color=blue" /></a>
<a href="https://github.com/linrongbin16/gitlinker.nvim/actions/workflows/ci.yml"><img alt="ci.yml" src="https://img.shields.io/github/actions/workflow/status/linrongbin16/colorbox.nvim/ci.yml?label=GitHub%20CI&labelColor=181717&logo=github&logoColor=fff" /></a>
<a href="https://app.codecov.io/github/linrongbin16/colorbox.nvim"><img alt="codecov" src="https://img.shields.io/codecov/c/github/linrongbin16/colorbox.nvim?logo=codecov&logoColor=F01F7A&label=Codecov" /></a>
</p>

I'm greedy that I want all the **most popular** Neovim colorschemes than only one, I'm playful that I want to change colorscheme from time to time. Are you like me?

Let's load all the ultra colorschemes into your Neovim player!

https://github.com/linrongbin16/colorbox.nvim/assets/6496887/8fff55ea-749d-4064-90b8-a3799519898d

<details>
<summary><i>Click here to see how to configure</i></summary>

```lua
require('colorbox').setup({
  policy = { seconds = 1, implement = "shuffle" },
  timing = "interval",
})
```

</details>

It use offline github actions to weekly collect and update the most popular Vim/Neovim colorscheme list.

> [!NOTE]
>
> The **most popular** colorschemes are picked from below websites:
>
> - [vimcolorschemes.com/top](https://vimcolorschemes.com/top)
> - [rockerBOO/awesome-neovim](https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/#colorscheme)
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
- Single cycle.

And multiple trigger timings (colorschemes don't have end time):

- On startup.
- Fixed interval.
- Date time (todo).
- By filetype.

## 📖 Table of contents

- [Requirement](#-requirement)
- [Install](#-install)
  - [lazy.nvim](#lazynvim)
  - [pckr.nvim](#pckrnvim)
- [Command](#-command)
- [Configuration](#-configuration)
  - [Filter](#filter)
  - [Timing & Policy](#timing--policy)
  - [Background](#background)
- [Receipts](#receipts)
- [Development](#-development)
- [Contribute](#-contribute)

## ✅ Requirement

- neovim &ge; 0.8.
- [git](https://git-scm.com/).
- [rm](https://man7.org/linux/man-pages/man1/rm.1.html) (optional for `reinstall` command on Windows).

<details>
<summary><i>Click here to see how to install `rm` command on Windows</i></summary>
<br/>

There're many ways to install portable linux shell and builtin commands on Windows, but personally I would recommend below two methods.

### [Git for Windows](https://git-scm.com/download/win)

Install with the below 3 options:

- In **Select Components**, select **Associate .sh files to be run with Bash**.

  <img alt="install-windows-git1.png" src="https://raw.githubusercontent.com/linrongbin16/lin.nvim.dev/main/assets/installations/install-windows-git1.png" width="70%" />

- In **Adjusting your PATH environment**, select **Use Git and optional Unix tools from the Command Prompt**.

  <img alt="install-windows-git2.png" src="https://raw.githubusercontent.com/linrongbin16/lin.nvim.dev/main/assets/installations/install-windows-git2.png" width="70%" />

- In **Configuring the terminal emulator to use with Git Bash**, select **Use Windows's default console window**.

  <img alt="install-windows-git3.png" src="https://raw.githubusercontent.com/linrongbin16/lin.nvim.dev/main/assets/installations/install-windows-git3.png" width="70%" />

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

**Warning:** if this plugin provides the main colorscheme (e.g. the `colorscheme` command right after nvim start), then make sure:

1. Don't lazy this plugin (it only takes ~4 ms to load).
2. Load this plugin before all other start plugins.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
require('lazy').setup({
    {
        'linrongbin16/colorbox.nvim',
        lazy = false, -- don't lazy load
        priority = 1000, -- load at first
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
    concurrency = 4,
})
```

## 🚀 Command

You can use command `Colorbox` to control the player with below subcommands:

- `update`: Update all git submodules.
- `reinstall`: Clean & re-install all git submodules.
  - **Note:** use `concurrency=1` to specify the `concurrency` parameters.

> [!NOTE]
>
> You can still use `colorscheme` command to change colorscheme.

## 🔧 Configuration

```lua
require('colorbox').setup({
    -- Disable those colors you don't want from the candidates list.
    filter = "primary",

    -- Choose a colorscheme from the filtered candidates.
    policy = "shuffle",

    -- Decide when to switch to next colorscheme.
    timing = "startup",

    -- (Optional) setup plugin before running `colorscheme {color}`.
    --- @type table<string, function>
    setup = {
        ["projekt0n/github-nvim-theme"] = function()
            require("github-theme").setup()
        end,
    },

    -- Set `background` before running `colorscheme {color}`.
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
    debug = false,

    -- print log to console (command line)
    console_log = true,

    -- print log to file.
    file_log = false,
})
```

When choosing a colorscheme, this plugin will run following steps:

- Run the filter, disable those colors you don't want from candidates list. See [Filter](#filter).
- Run the policy at a proper timing, and choose a colorscheme. See [Timing & Policy](#timing--policy).
- Refresh the `background` option. See [Background](#background).
- Run the `colorscheme` command to actually change to the colorscheme.

### Filter

There're 3 types of filter configs:

- Builtin filters:

  - `"primary"`: Only enables the main color (if there are multiple colors in one plugin).

- Function filters: A lua function that decide whether to enable/disable a color

  > **Note:**
  >
  > The lua function has below signature:
  >
  > ```lua
  > function(color:string, spec:colorbox.ColorSpec):boolean
  > ```
  >
  > Parameters:
  >
  > - `color`: Color name.
  > - `spec`: Colorscheme meta info, which is the `colorbox.ColorSpec` type, see below.
  >
  > Returns:
  >
  > - To disable a color, returns `true`.
  > - To enable a color, returns `false`.
  >
  > ```lua
  > --- @class colorbox.ColorSpec
  > --- @field handle string "folke/tokyonight.nvim"
  > --- @field url string "https://github.com/folke/tokyonight.nvim"
  > --- @field github_stars integer 4300
  > --- @field last_git_commit string "2023-10-25T18:20:36"
  > --- @field priority integer 100/0
  > --- @field source string "https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/#colorscheme"
  > --- @field git_path string "folke-tokyonight.nvim"
  > --- @field git_branch string? nil|"neovim"
  > --- @field color_names string[] ["tokyonight","tokyonight-day","tokyonight-moon","tokyonight-night","tokyonight-storm"]
  > --- @field pack_path string "pack/colorbox/start/folke-tokyonight.nvim"
  > --- @field full_pack_path string "Users/linrongbin16/github/linrongbin16/colorbox.nvim/pack/colorbox/start/folke-tokyonight.nvim"
  > ```

- List filters: A lua list that contains multiple other filters. A color will be disabled if any of those filters returns true.

### Timing & Policy

> [!NOTE]
>
> Timing and policy have to work together.

- `timing`:

  - `"startup"`: Choose a color on nvim's start.
  - `"interval"`: Choose a color after a fixed interval time.
  - `"bufferchanged"`: Choose a color when buffer changed.

- `policy`:

  - Builtin policy, works with `timing = "startup"`.

    - `"shuffle"`: Random choose next color.
    - `"in_order"`: Choose next color in order, color names are ordered from 'A' to 'Z'.
    - `"reverse_order"`: Choose next color in reversed order, color names are ordered from 'Z' to 'A'.
    - `"single"`: Choose the fixed one color.

  - Fixed interval time policy, works with `timing = "interval"`. The policy contains two fields:

    - `seconds`: Fixed interval time by seconds.
    - `implement`: Internal policy implementation, e.g. `shuffle`, `in_order`, `reverse_order`, `single` builtin policies.

  - By filetype policy, works with `timing = "bufferchanged"`.

    - `mapping`: A lua table to map file type to colorscheme.
    - `fallback`: Default colorscheme when file type is not mapped.

### Background

There're some colors (`tokyonight-day`, `rose-pine-dawn`) are forced to be light, e.g. they forced the `set background=light` on loading.

If you want to bring the dark-able colors back to dark, please see:

```lua
require('colorbox').setup({
    background = 'dark',
})
```

It will automatically run `set background=dark` option before `colorscheme` command.

## Receipts

To choose a fixed colorscheme on nvim start, please use:

```lua
require('colorbox').setup({
    policy = 'single',
    timing = 'startup',
})
```

To choose a random colorscheme on nvim start with dark background, please use:

```lua
require('colorbox').setup({
    background = 'dark',
    policy = 'shuffle',
    timing = 'startup',
})
```

To choose a colorscheme by file type, please use:

```lua
require('colorbox').setup({
    policy = {
        mapping = {
            lua = "PaperColor",
            yaml = "everforest",
            markdown = "kanagawa",
            python = "iceberg",
        },
        fallback = "solarized8",
    },
    timing = "bufferchanged",
})
```

To choose a colorscheme on fixed interval per seconds, please use:

```lua
require('colorbox').setup({
    policy = { seconds = 1, implement = "shuffle" },
    timing = 'interval',
})
```

To disable filters, please use:

```lua
require('colorbox').setup({
    filter = false,
})
```

To enable only primary colors (default config), please use:

```lua
require('colorbox').setup({
    filter = 'primary',
})
```

To enable only github stars &ge; 1000 & primary colors, please use:

```lua
require('colorbox').setup({
    filter = {
        "primary",
        function(color, spec)
            return spec.github_stars < 1000
        end
    },
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
