# colorswitch.nvim

A colorscheme switch and collection plugin for Neovim.

## Introduction

Want more colorschemes for your Neovim? This is it.

### Awesome collection

Awesome colorschemes collected from:

- [vimcolorscheme.com/top](https://vimcolorschemes.com/top).
- [awesome-neovim#colorscheme](https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/#colorscheme).

Here 'awesome' is defined with:

1. Github stars &ge; 500.
2. Last commit in 2 years(365 days/year).
3. For multiple ports/variants, keep the one with more plugins support, stars or
   git commits.

### Switch Policy

Switch on such an awesome collection, using configured policies:

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

### To load color on startup

Add `lua require('colorswitch').switch()` to the `init.vim`.

### To switch to a new color

Use (the same) `lua require('colorswitch').switch()`.

### To switch to a specific color

Use `lua require('colorswitch').switch({color='your_color_name'})`.

### To forcibly switch to a color

Use `lua require('colorswitch').switch({force=true})`.

It will refresh the syntax since sometimes there're highlighting issues after
change a colorscheme.

## Configuration

By default, the color candidates list provide primary dark colors.

```lua
require('colorswitch').setup({
    -- include colors, a nil|table value.
    include = nil,
    -- exclude colors, a nil|table value.
    exclude = nil,
    -- exclude variants, keep primary only
    no_variants = true,
    -- exclude dark
    no_dark = false,
    -- exclude light
    no_light = true,
})
```

## Notes

I found a few color collections never update their collections, which is the
original reason why I create this plugin.

To fix this issue, I use python scripts to update colors automatically:

```bash
python3 fetch.py
python3 build.py
```

They will do following steps:

1. Start a web crawler on [vimcolorscheme.com/top](https://vimcolorschemes.com/top)
   and [awesome-neovim#colorscheme](https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/#colorscheme),
   collect all the awesome colors.
2. Download all these repositores, and copy the source code to this plugin.

For now I run these scripts every day, so users could get daily updates.
But I'm not sure how long I can last, this thing could be fully automatic if using a cloud machine, which is not free.
