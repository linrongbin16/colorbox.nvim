# colorswitch.nvim

A colorscheme switch and collection plugin for Neovim.

## Introduction

Want more colorschemes for your Neovim? This is it.

### Awesome collection

Awesome colorschemes collected from:

- [vimcolorscheme.com/top](https://vimcolorschemes.com/top)
- [awesome-neovim#colorscheme](https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/#colorscheme)

Here 'awesome' is defined with:

1. Github stars &ge; 500.
2. Last commit in 2 years(365 days/year).
3. For multiple ports/variants, keep the one with more plugins support, stars or
   git commits.

Please check [repo.data](https://github.com/linrongbin16/colorswitch.nvim/blob/main/repo.data)
for full git repositories list, and check [colors](https://github.com/linrongbin16/colorswitch.nvim/tree/main/colors)
for full colors list.

### Switch Policy

Choose one in the collection, using configured policies:

1. How to choose the next color:

   - Shuffle

2. When to choose the next color:
   - Startup
   - Cronjob (todo)

## Requirement

Neovim &ge; 0.8.

## Install

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    'linrongbin16/colorswitch.nvim',
    lazy = true,
    priority = 1000,
    dependencies = { 'linrongbin16/logger.nvim' },
    config = function()
        require('colorswitch').setup()
    end
}
```

## Usage

There's only one API: `require('colorswitch').switch(option)`, the `option` is
an optional lua table for arguments.

### Load color on startup or switch to a new color

Add `lua require('colorswitch').switch()` to the `init.vim`, or execute in
command line.

### Switch to a specific color

Use `lua require('colorswitch').switch({color='your_color_name'})`.

Sometimes there're syntax highlighting issues after change colorscheme, please
add `force=true` in option: `lua require('colorswitch').switch({force=true})`.
It will force update the buffer's syntax.

## Configuration

By default, the color candidates list provide primary dark colors.

```lua
require('colorswitch').setup({
    -- include colors, a nil|table value.
    include = nil,

    -- exclude colors, a nil|table value.
    exclude = nil,

    -- no variants, primary only
    no_variants = true,

    -- dark only
    no_dark = false,

    -- no light
    no_light = true,

    -- log level: DEBUG/INFO/WARN/ERROR
    log_level = "WARN",
})
```

## Notes

I found a few color collections never update their colors, which is the origin
reason I create this plugin.

To solve this issue, I use python scripts to update colors automatically.

1. `fetch.py` starts a web crawler on [vimcolorscheme.com/top](https://vimcolorschemes.com/top)
   and [awesome-neovim#colorscheme](https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/#colorscheme),
   collect all the awesome colors.
2. `build.py` downloads all git repositores, copy the source code, and generate
   runtime colorscheme candidates.

For now I run these scripts every day, so users could get daily updates.
This thing could be fully automatic if using a cloud machine, which is not free.
I'm not sure how long I can maintain this :).
