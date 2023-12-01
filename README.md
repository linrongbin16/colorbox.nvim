# 🌈 colorbox.nvim

<!-- query a github file last update timestamp: https://stackoverflow.com/a/50204589/4438921 -->

<p align="center">
<a href="https://github.com/neovim/neovim/releases/v0.8.0"><img alt="Neovim" src="https://img.shields.io/badge/Neovim-v0.8-57A143?logo=neovim&logoColor=57A143" /></a>
<a href="https://github.com/linrongbin16/colorbox.nvim/search?l=lua"><img alt="Language" src="https://img.shields.io/github/languages/top/linrongbin16/colorbox.nvim?label=Lua&logo=lua&logoColor=fff&labelColor=2C2D72" /></a>
<a href="https://github.com/linrongbin16/gitlinker.nvim/actions/workflows/ci.yml"><img alt="ci.yml" src="https://img.shields.io/github/actions/workflow/status/linrongbin16/colorbox.nvim/ci.yml?label=GitHub%20CI&labelColor=181717&logo=github&logoColor=fff" /></a>
<a href="https://app.codecov.io/github/linrongbin16/colorbox.nvim"><img alt="codecov" src="https://img.shields.io/codecov/c/github/linrongbin16/colorbox.nvim?logo=codecov&logoColor=F01F7A&label=Codecov" /></a>
<a href="https://github.com/linrongbin16/gitlinker.nvim/actions/workflows/collect.yml"><img alt="collect.yml" src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fapi.github.com%2Frepos%2Flinrongbin16%2Fcolorbox.nvim%2Fcommits%3Fpath%3Dcollect.py.log%26page%3D1%26per_page%3D1&query=%24%5B0%5D.commit.committer.date&logo=githubactions&logoColor=fff&label=Last%20Update&labelColor=2F4F4F" /></a>
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
  - [Timing & Policy](#timing--policy)
  - [Filter](#filter)
  - [Background](#background)
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

scoop install coreutils     # rm
```

</details>

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

## 🚀 Usage

You can use command `Colorbox` to control the colorschemes player:

- `Colorbox update/reinstall`: update, or clean & re-install git submodules.
  - **Note:** use `concurrency=1` to specify the `concurrency` parameters.
- `Colorbox next/prev/shuffle` (todo): next color, previous color, next random color (even you didn't configure the `shuffle` policy).
- `Colorbox pause/restart` (todo): stay on current color (disable timing config, e.g. fixed interval, by filetype timings), restart to continue change colors (enable timing config).

**Note:** you can still use `colorscheme` command to change colorscheme.

## 🔧 Configuration

```lua
require('colorbox').setup({
    -- builtin policy
    --- @alias colorbox.BuiltinPolicyConfig "shuffle"|"in_order"|"reverse_order"|"single"
    ---
    -- by filetype policy: buffer filetype => color name
    --- @alias colorbox.ByFileTypePolicyConfig {implement:colorbox.BuiltinPolicyConfig|table<string, string>}
    ---
    -- fixed interval seconds
    --- @alias colorbox.FixedIntervalPolicyConfig {seconds:integer,implement:colorbox.BuiltinPolicyConfig}
    ---
    --- @alias colorbox.PolicyConfig colorbox.BuiltinPolicyConfig|colorbox.ByFileTypePolicyConfig|colorbox.FixedIntervalPolicyConfig
    --- @type colorbox.PolicyConfig
    policy = "shuffle",

    --- @type "startup"|"interval"|"filetype"
    timing = "startup",

    -- (Optional) filters that disable some colors that you don't want.
    -- By default only enable primary color, e.g. only 'tokyonight' is picked, others ('tokyonight-day', 'tokyonight-moon', 'tokyonight-night', 'tokyonight-storm') are excluded.
    --
    -- builtin filter
    --- @alias colorbox.BuiltinFilterConfig "primary"
    ---
    --- @class colorbox.ColorSpec
    --- @field handle string "folke/tokyonight.nvim"
    --- @field url string "https://github.com/folke/tokyonight.nvim"
    --- @field github_stars integer 4300
    --- @field last_git_commit string "2023-10-25T18:20:36"
    --- @field priority integer 100/0
    --- @field source string "https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/#colorscheme"
    --- @field git_path string "folke-tokyonight.nvim"
    --- @field git_branch string? nil|"neovim"
    --- @field color_names string[] ["tokyonight","tokyonight-day","tokyonight-moon","tokyonight-night","tokyonight-storm"]
    --- @field pack_path string "pack/colorbox/start/folke-tokyonight.nvim"
    --- @field full_pack_path string "Users/linrongbin16/github/linrongbin16/colorbox.nvim/pack/colorbox/start/folke-tokyonight.nvim"
    --
    -- function-based filter, disabled if function return true.
    --- @alias colorbox.FunctionFilterConfig fun(color:string, spec:colorbox.ColorSpec):boolean
    ---
    ---list-based filter, disabled if any of filter hit the conditions.
    --- @alias colorbox.AnyFilterConfig (colorbox.BuiltinFilterConfig|colorbox.FunctionFilterConfig)[]
    ---
    --- @alias colorbox.FilterConfig colorbox.BuiltinFilterConfig|colorbox.FunctionFilterConfig|colorbox.AnyFilterConfig
    --- @type colorbox.FilterConfig?
    filter = "primary",

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

### Timing & Policy

Timing and policy configs have to work together.

- `timing`: 'startup' (on nvim start), 'interval' (fixed interval seconds), 'filetype' (by buffer filetype, todo).
- `policy`:
  - Builtin policies (see `colorbox.BuiltinPolicyConfig`): 'shuffle' (random select), 'in_order' ('A-Z' color names), 'reverse_order' ('Z-A' color names), 'single' (don't change, todo).
  - Fixed interval policies (see `colorbox.ByFileTypePolicyConfig`): todo.
  - By buffer filetype policies (see ``)

To choose a colorscheme on nvim start, please use:

```lua
require('colorbox').setup({
    policy = 'shuffle',
    timing = 'startup',
})
```

To choose a colorscheme on fixed interval per seconds, please use:

```lua
require('colorbox').setup({
    policy = { seconds = 1, implement = "shuffle" },
    timing = 'interval',
})
```

### Filter

There're 3 types of filter configs:

- Builtin filters (see `colorbox.BuiltinFilterConfig`): `primary` (only the main color).
- Function-based filters (see `colorbox.FunctionFilterConfig`): a lua function that decide whether to filter the color, return true if you want to disable the color.
  - **Note:** the lua function use signature `fun(color:string, spec:colorbox.ColorSpec):boolean`, where 1st parameter `color` is the color name, 2nd paraneter `spec` is the meta info of a color plugin, see `colorbox.ColorSpec`.
- List-based filters (see `colorbox.AnyFilterConfig`): a lua list that contains multiple of builtin filters and function filters, the color will be disabled if any of these filters returns true.

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
    filter = {'primary', function(color, spec) return spec.github_stars < 1000 end },
})
```

### Background

Most colorschemes are both dark-able and light-able, they depend on the `set background=dark/light` option, while there're some colors (`tokyonight-day`, `rose-pine-dawn`) are forced to be light, e.g. they change the `background` option when loaded.

If you didn't disable the light colors (for example set `filter=false` to allow all the colors), but still want to the dark-able colors to be dark, please see:

```lua
require('colorbox').setup({
    background = 'dark',
})
```

It automatically set `set background=dark` option before running `colorscheme {color}` command, thus try to bring background back to dark unless those forced to be light ones.

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
