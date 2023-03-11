# colorswitch.nvim

A colorscheme switch and collection plugin for Neovim.

## Introduction

Want more colorschemes for your Neovim? This is it.

### **Awesome** collection

The colorschemes(here we call them **candidates**) are collected from:

- [vimcolorscheme.com/top](https://vimcolorschemes.com/top).
- [awesome-neovim#colorscheme](https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/#colorscheme).

The term 'awesome' is defined with:

1. Github stars &ge; 400.
2. Last commit in 2 years(365 days/year).
3. For multiple ports/variants, keep the one with more plugins support, stars or
   git commits.

### Switch Policy

Switch on such an awesome collection, using configured policies:

1. How to choose the next color:

   - Fxied one
   - Repeat all
   - Shuffle all

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
    config = function()
        require('colorswitch').setup()
    end
}
```

## Usage

### Startup

Add `require('colorswitch').switch()` to your `init.lua` to load a colorscheme.

### Switch

Use `lua require('colorswitch').switch()` to switch to the next colorscheme.

There's an optional argument in `switch(option)` API, it's a lua table:

1. To switch to specific color, use `lua require('colorswitch').switch({color='your_color_name'})`.
2. To forcibly switch to a color, use `lua require('colorswitch').switch({force=true})`.
   It will refresh the syntax since sometimes there're highlighting issues after change a colorscheme.

## Configuration

```
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
})
```

## Maintainance

Colorscheme collections are hard to maintain, I found a few collections that copy colors from others' git repository, then never update them anymore.
That's a sad thing. To fix this issue, I write several python scripts to update colors automatically, for now I manually run these scripts daily:

```bash
python3 fetch.py
python3 build.py
```

They will do following steps:

1. Start a web crawler on [vimcolorscheme.com/top](https://vimcolorschemes.com/top) and [awesome-neovim#colorscheme](https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/#colorscheme),
   collect all the **awesome** colors.
2. Clone all these git repositores, copy and merge all the source code files into this git repository.

## Docs

TODO
