# color-all-in-one.nvim

**WIP: Don't use this tool for now, it's still not done yet.**

I'm greedy that I want all the **most popular** Neovim colorschemes than only one, I'm playful that I want to change colorscheme from time to time. Are you like me?

This is it!

It auto-collect the most popular Vim/Neovim colorschemes and install for you.

It allow you do any switches with:
  * Multiple policies: suffle playback, play in order, single cycle.
  * Multiple timing: on startup, fixed interval, etc.

> Note:
>
> The **most popular** colorschemes are picked from below websites:
> - [vimcolorscheme.com/top](https://vimcolorschemes.com/top)
> - [awesome-neovim#colorscheme](https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/#colorscheme)
>
> With below conditions:
>
> 1. Github stars &ge; 900.
> 2. Last git commit in 3 years.
> 3. For multiple variants, keep the one with modern Neovim features (lsp, treesitter), third-party plugins support, more github stars or newer git commits.

## Requirement

Neovim &ge; 0.8.

## Usage

### Collect colorschemes

The collector is implemented by selenium based crawler, depends on
python3 and [chromedriver](https://chromedriver.chromium.org/downloads).

1. Install pip libraries:

   ```bash
   pip3 install selenium
   pip3 install tinydb
   ```

2. Run python scripst:

   ```bash
   python3 ./fetch.py
   python3 ./clone.py
   python3 ./build.py
   ```

### Import to nvim config

For lazy.nvim:

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

For packer.nvim:

For vim-plug:
