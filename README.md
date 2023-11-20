# colorbox.nvim

**WIP: Don't use this tool for now, it's still not done yet.**

I'm greedy that I want all the **most popular** Neovim colorschemes than only one, I'm playful that I want to change colorscheme from time to time. Are you like me?

This is it!

It use offline github actions to weekly collect and update the most popular Vim/Neovim colorscheme list.

> The **most popular** colorschemes are picked from below websites:
>
> - [vimcolorscheme.com/top](https://vimcolorschemes.com/top)
> - [www.trackawesomelist.com/rockerBOO/awesome-neovim](https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/#colorscheme)
>
> With below conditions:
>
> 1. Github stars &ge; 900.
> 2. Last git commit in 3 years.
> 3. For multiple variants, choose the one in following rules:
>    1. **Awesome-neovim** wins **vimcolorsheme**, since they usually has modern Neovim features (lua, lsp, treesitter) and support more third-party plugins.
>    2. Moe github stars.
>    3. Newer git commits.

It install color plugins via git submodules instead of copy-paste source code, so you get continuously updates from original authors instead of me, e.g. it only transport and manage, not produce.

It allow you do any switches with:

- Multiple policies: suffle playback, play in order(todo), single cycle(todo).
- Multiple timing: on startup, fixed interval(todo), by filetype(todo), etc.

## Requirement

Neovim &ge; 0.8.

## Install

TODO
