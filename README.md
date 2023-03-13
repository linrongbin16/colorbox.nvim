# colorswitch.nvim

A colorscheme switch and collection plugin for Neovim.

## Introduction

Want more colorschemes for your Neovim? This is it.

### **Awesome** collection

**Awesome** colorschemes are collected from:

- [vimcolorscheme.com/top](https://vimcolorschemes.com/top).
- [awesome-neovim#colorscheme](https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/#colorscheme).

Here '**awesome**' is defined with:

1. Github stars &ge; 500.
2. Last commit in 2 years(365 days/year).
3. For multiple ports/variants, keep the one with more plugins support, stars or
   git commits.

### Switch Policy

Switch on such an awesome collection, using configured policies:

1. How to choose the next color:

   - Shuffle
   - Alphabetical Order

2. When to choose the next color:
   - Startup
   - Cronjob

### Custom Configuration

More custom configurations are coming...

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

```lua
require('colorswitch').setup({
    -- shuffle/repeat/fixed
    policy = 'shuffle',

    -- specify your fixed colorscheme here, working with `policy='fixed'`.
    fixed_color = nil,

    -- blacklist, disable colors here.
    blacklist = {},

    -- appendlist, add more colors here.
    appendlist = {},

    -- cronjob, schedule a background job to switch to next color
    -- for example:
    --   '30 8 * * *' - 8:30 every day
    --   '* * * * *' - every minute
    cronjob = nil,

    -- enable debug
    debug = false,
})
```

## Notes

I found a few color collections never update their collections, which is a sad thing.
Also this is the original reason why I create this plugin.

To fix this issue, I use python scripts to update colors automatically, but for
now I still need to manually run them:

```bash
python3 fetch.py
python3 build.py
```

They will do following steps:

1. Start a web crawler on [vimcolorscheme.com/top](https://vimcolorschemes.com/top)
   and [awesome-neovim#colorscheme](https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/#colorscheme),
   collect all the **awesome** colors.
2. Add all these repositores as git submodules. While setup this plugin, it
   will append all submodules to vim's runtimepath(same as plugin managers do).
