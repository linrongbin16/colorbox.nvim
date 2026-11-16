# 🌈 colorbox.nvim

<p>
<a href="https://github.com/neovim/neovim/releases/tag/v0.12.0"><img alt="Neovim" src="https://img.shields.io/badge/require-0.12%2B-blue" /></a>
<a href="https://github.com/linrongbin16/colorbox.nvim/actions/workflows/ci.yml"><img alt="ci.yml" src="https://img.shields.io/github/actions/workflow/status/linrongbin16/colorbox.nvim/ci.yml?label=ci" /></a>
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

It collects the most popular colorschemes from GitHub, with stars &ge; 800. Please check [COLORSCHEMES.md](https://github.com/linrongbin16/colorbox.nvim/blob/main/COLORSCHEMES.md) for full colorscheme dataset.

> [!NOTE]
>
> The **most popular** colorschemes are manually picked from:
>
> - Awesome Neovim Colors: <https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/>
> - Awesome Vim Colors: <https://github.com/rafi/awesome-vim-colorschemes>
> - GitHub "neovim-colorscheme" topic: <https://github.com/topics/neovim-colorscheme>
> - GitHub "vim-colorscheme" topic: <https://github.com/topics/vim-colorscheme>
>
> For plugins that conflicts on same color name, the one with more stars or Neovim features are picked.

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
  - [Options](#options)
  - [Filter](#filter)
  - [Timing and Policy](#timing-and-policy)
  - [Background](#background)
  - [Hook](#hook)
  - [Setup](#setup)
- [Receipts](#-receipts)
  - [Choose fixed color on nvim start](#choose-fixed-color-on-nvim-start)
  - [Choose random color on nvim start](#choose-random-color-on-nvim-start)
  - [Change random color per second](#change-random-color-per-second)
  - [Choose color by file type](#choose-color-by-file-type)
  - [Disable by name](#disable-by-name)
  - [Disable by plugin](#disable-by-plugin)
- [Development](#%EF%B8%8F-development)
- [Contribute](#-contribute)

## ✅ Requirements

> [!NOTE]
> This plugin always supports with the latest stable and (possibly) nightly Neovim version.

- Neovim &ge; 0.12.
- [Git](https://git-scm.com/).

## 📦 Install

> [!IMPORTANT]
>
> 1. Don't lazy load it.
> 2. Load it before all other plugins.

> [!IMPORTANT]
>
> Please add below dependencies if your colorschemes need them:
>
> - [termguicolors](https://neovim.io/doc/user/options.html#'termguicolors')
> - [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
> - [lush.nvim](https://github.com/rktjmp/lush.nvim)

<details>
<summary><b>With <a href="https://github.com/folke/lazy.nvim">lazy.nvim</a></b></summary>

```lua
require('lazy').setup({
  {
    'linrongbin16/colorbox.nvim',

    -- don't lazy load and load it before all other plugins.
    lazy = false,
    priority = 1000,

    -- add dependencies if colorschemes need them
    dependencies = {"nvim-treesitter/nvim-treesitter", "rktjmp/lush.nvim"},

    config = function()
      -- Enable 'termguicolors' option
      vim.o.termguicolors = true
      require("colorbox").setup()
    end,
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

    -- add dependencies if colorschemes need them
    requires = {"nvim-treesitter/nvim-treesitter", "rktjmp/lush.nvim"},

    config = function()
      -- Enable 'termguicolors' option
      vim.o.termguicolors = true
      require("colorbox").setup()
    end,
  };
})
```

</details>

## 🎬 How it Works

When loading this plugin, it does below steps:

1. Runs the filters, only enables the colors you choose from the dataset (see [Filter](#filter)).
2. Registers the triggers to invoke related policies at a proper timing (see [Timing and Policy](#timing-and-policy)).

When a timing is triggered, it does below steps:

1. Runs the registered policy and pick a colorscheme (see [Timing and Policy](#timing-and-policy)).
2. Refreshes the `background` option (see [Background](#background)).
3. Runs the `colorscheme` command to actually apply the colorscheme.

## 🚀 Usage

You can use the `Colorbox` command with below subcommands:

- `update`: Install/update all git submodules.
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

The `opts` is an optional lua table merged on top of the defaults. For the annotated source, please see [configs.lua](https://github.com/linrongbin16/colorbox.nvim/blob/main/lua/colorbox/configs.lua).

### Options

| Option        | Type                                | Default                             | Description                                                                                  |
| ------------- | ----------------------------------- | ----------------------------------- | -------------------------------------------------------------------------------------------- |
| `policy`      | `string` \| `table`                 | `"shuffle"`                         | How to pick the next colorscheme, see [Timing and Policy](#timing-and-policy).               |
| `timing`      | `string`                            | `"startup"`                         | When to pick the next colorscheme, see [Timing and Policy](#timing-and-policy).              |
| `filter`      | `function` \| `function[]` \| `nil` | `nil`                               | Enables only the colors you choose, see [Filter](#filter).                                   |
| `background`  | `"dark"` \| `"light"` \| `nil`      | `nil`                               | Forces the `background` option before applying a colorscheme, see [Background](#background). |
| `post_hook`   | `function` \| `nil`                 | `nil`                               | Runs after a colorscheme is applied, see [Hook](#hook).                                      |
| `setup`       | `table<string, function>`           | `{}`                                | Per colorscheme hook keyed by git handle, see [Setup](#setup).                               |
| `command`     | `table`                             | `{ name = "Colorbox", desc = ... }` | The `:Colorbox` command's name and description.                                              |
| `augroup`     | `string`                            | `"Colorbox"`                        | The autocmd group that colorbox attaches its autocmds to.                                    |
| `cache_dir`   | `string`                            | `stdpath("data")/colorbox.nvim`     | Where the previous colorscheme track is cached.                                              |
| `debug`       | `boolean`                           | `false`                             | Raises the log level from `INFO` to `DEBUG`.                                                 |
| `console_log` | `boolean`                           | `true`                              | Notifies logs on the command line.                                                           |
| `file_log`    | `boolean`                           | `false`                             | Appends logs to `stdpath("data")/colorbox.log`.                                              |

> [!NOTE]
>
> An invalid `filter` or `augroup` value is reported with a warning, and replaced by its default. An invalid `timing`/`policy` pair is reported with an error and nothing is scheduled, see [Timing and Policy](#timing-and-policy).

### Filter

The `filter` option is to help user filter some colorschemes from the dataset, thus they will never show up.

It defaults to `nil`, which enables all colors in the dataset. There're 2 kinds of filters:

| Kind            | Type                                                           | A color is enabled when                      |
| --------------- | -------------------------------------------------------------- | -------------------------------------------- |
| Function filter | `function(color_name:string, spec:colorbox.ColorSpec):boolean` | The function returns `true`.                 |
| List filter     | `function[]`                                                   | All the functions in the list return `true`. |

The function filter has two parameters:

| Parameter    | Type                 | Description                                       |
| ------------ | -------------------- | ------------------------------------------------- |
| `color_name` | `string`             | The colorscheme name.                             |
| `spec`       | `colorbox.ColorSpec` | The colorscheme's meta info, see the table below. |

The `spec` parameter is a `colorbox.ColorSpec`, it is also passed to `post_hook` and `setup`, see [`@class colorbox.ColorSpec`](https://github.com/linrongbin16/colorbox.nvim/blob/main/lua/colorbox/db.lua?plain=1#L1-L7):

| Field          | Type      | Description                                                 |
| -------------- | --------- | ----------------------------------------------------------- |
| `handle`       | `string`  | The git handle, i.e. `folke/tokyonight.nvim`.               |
| `color_name`   | `string`  | The colorscheme name, i.e. `tokyonight`.                    |
| `plugin_name`  | `string`  | The plugin name, i.e. `tokyonight`.                         |
| `url`          | `string`  | The plugin's homepage URL.                                  |
| `install_path` | `string`  | The installed directory name, i.e. `folke-tokyonight.nvim`. |
| `git_branch`   | `string?` | The git branch to clone, `nil` means the default branch.    |

### Timing and Policy

The `timing` and `policy` options are configured together: `timing` decides **when** to pick the next colorscheme, `policy` decides **which** one to pick. Each `timing` drives exactly one kind of `policy`, so the only pairs that work are:

| `timing`   | Trigger                                                                                                               | `policy`                                                                                   | Behavior                                                                                                             |
| ---------- | --------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------- |
| `startup`  | Neovim starts (`VimEnter`).                                                                                           | A builtin policy: a lua string, see [Builtin policy](#builtin-policy).                     | Changes to the next colorscheme once, it works exactly like manually adding `colorscheme xxx` in nvim's init config. |
| `interval` | A timer fires every `policy.seconds` seconds.                                                                         | A fixed interval policy: a lua table, see [Fixed interval policy](#fixed-interval-policy). | Changes to the next colorscheme on every timeout, the timer reschedules itself.                                      |
| `filetype` | A buffer or window becomes current, or the terminal gains focus (`BufEnter`, `WinEnter`, `TermEnter`, `FocusGained`). | A file type policy: a lua table, see [File type policy](#file-type-policy).                | Changes to the colorscheme mapped by the current buffer's file type.                                                 |

Any other pair (i.e. `timing = "startup"` with a file type policy) is rejected with an error message naming both options, and nothing is scheduled. An unknown `timing` or `policy` is rejected the same way. The `bufferchanged` timing was renamed to `filetype` in colorbox `1.13.9`, it is rejected with a message pointing at the new name.

#### Builtin policy

The `policy` of the `startup` timing is a lua string that presents the name of a builtin policy, see [Choose random color on nvim start](#choose-random-color-on-nvim-start):

| Value           | Picks                                                                      |
| --------------- | -------------------------------------------------------------------------- |
| `shuffle`       | A random color.                                                            |
| `in_order`      | The next color in order, color names are ordered from 'A' to 'Z'.          |
| `reverse_order` | The next color in reversed order, color names are ordered from 'Z' to 'A'. |
| `single`        | Always the same color, i.e. the next color is still the current color.     |

#### Fixed interval policy

The `policy` of the `interval` timing is a lua table, see [Change random color per second](#change-random-color-per-second):

| Field       | Type                           | Description                                                       |
| ----------- | ------------------------------ | ----------------------------------------------------------------- |
| `seconds`   | `integer`, must be `> 0`       | Choose next colorscheme on every X seconds.                       |
| `implement` | `colorbox.BuiltinPolicyConfig` | The builtin policy that chooses how to pick the next colorscheme. |

#### File type policy

The `policy` of the `filetype` timing is a lua table, see [Choose color by file type](#choose-color-by-file-type):

| Field      | Type                    | Description                                                                                                |
| ---------- | ----------------------- | ---------------------------------------------------------------------------------------------------------- |
| `mapping`  | `table<string, string>` | Maps from file type to color name. When current buffer's file type is hit, it changes to the mapped color. |
| `empty`    | `string?`               | The color name when the file type is an empty lua string, `nil` falls through to `fallback`.               |
| `fallback` | `string?`               | The color name when the file type is not found in `mapping` field, `nil` does nothing.                     |

### Background

The `background` option runs `set background=dark/light` every time before running the `colorscheme` command (to change a colorscheme):

| Value           | Behavior                                              |
| --------------- | ----------------------------------------------------- |
| `"dark"`        | Sets `background=dark` before every colorscheme.      |
| `"light"`       | Sets `background=light` before every colorscheme.     |
| `nil` (default) | Leaves `background` to whatever the colorscheme sets. |

```lua
require("colorbox").setup({
  background = "dark",
})
```

Some colors (`tokyonight-day`, `rose-pine-dawn`, etc) are forced to be light, i.e. they forced the `background` option to `light` inside their internal implementations.

This is no problem, except some user may want all those following colorschemes (after `tokyonight-day` and `rose-pine-dawn`) go back to `dark` background if they're dark-able.

### Hook

The `post_hook` option runs a lua function once per colorscheme load, after the new colorscheme is applied and its track is saved:

| Parameter | Type                 | Description                                         |
| --------- | -------------------- | --------------------------------------------------- |
| `color`   | `string`             | The colorscheme name that was just applied.         |
| `spec`    | `colorbox.ColorSpec` | The colorscheme's meta info, see [Filter](#filter). |

```lua
require("colorbox").setup({
  post_hook = function(color, spec)
    vim.notify(string.format("Colorscheme changed to: %s", vim.inspect(color)))
  end,
})
```

### Setup

The `setup` option is a lua table that maps a colorscheme's git handle to a function. It runs after colorbox `packadd`-s that colorscheme and before the `colorscheme` command applies it, so the function can prepare the plugin's global variables:

| Parameter  | Type                 | Description                                                         |
| ---------- | -------------------- | ------------------------------------------------------------------- |
| `home_dir` | `string`             | The colorbox.nvim directory, where all the colorschemes are stored. |
| `spec`     | `colorbox.ColorSpec` | The colorscheme's meta info, see [Filter](#filter).                 |

```lua
require("colorbox").setup({
  setup = {
    ["catppuccin/nvim"] = function(home_dir, spec)
      vim.g.catppuccin_flavour = "mocha"
    end,
  },
})
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

### Disable by name

```lua
local function disabled(color_name)
  for _, c in ipairs({
    "iceberg",
    "ayu",
    "edge",
    "nord",
  }) do
    if string.lower(c) == string.lower(color_name) then
      return true
    end
  end
  return false
end

require("colorbox").setup({
  filter = function(color, spec)
    return disabled(spec.color_name)
  end
})
```

### Disable by plugin

```lua
local function plugin_disabled(handle)
  for _, p in ipairs({
    "cocopon/iceberg.vim",
    "folke/tokyonight.nvim",
    "ayu-theme/ayu-vim",
    "shaunsingh/nord.nvim",
  }) do
    if string.lower(p) == string.lower(handle) then
      return true
    end
  end
  return false
end

require("colorbox").setup({
  filter = function(color, spec)
    return not plugin_disabled(spec.handle)
  end
})
```

## ✏️ Development

To develop the project and make PR, please setup with:

- [lua_ls](https://github.com/LuaLS/lua-language-server).
- [stylua](https://github.com/JohnnyMorganz/StyLua).
- [selene](https://github.com/Kampfkarren/selene).

Do not touch below files as they are vendored from other projects:

- `lua/colorbox/async.lua` and `lua/colorbox/async/` are from [async.nvim](https://github.com/lewis6991/async.nvim).

## 🎁 Contribute

Please open [issue](https://github.com/linrongbin16/colorbox.nvim/issues)/[PR](https://github.com/linrongbin16/colorbox.nvim/pulls) for anything about colorbox.nvim.
