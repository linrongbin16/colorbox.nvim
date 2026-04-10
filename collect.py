#!/usr/bin/env python3

import logging
import sys
import typing
import click
import luadata
from mdutils.mdutils import MdUtils


class ColorSpec:
    HANDLE = "handle"
    COLOR_NAME = "color_name"
    PLUGIN_NAME = "plugin_name"
    URL = "url"
    INSTALL_PATH = "install_path"
    GIT_BRANCH = "git_branch"

    def __init__(
        self,
        handle: str,
        color_name: str,
        url: typing.Optional[str] = None,
        plugin_name: typing.Optional[str] = None,
        git_branch: typing.Optional[str] = None,
    ) -> None:
        handle = self._normalize_handle(handle)
        handle_splits = handle.split("/")
        assert len(handle_splits) == 2
        self.handle = handle
        self.color_name = color_name
        self.plugin_name = plugin_name if isinstance(plugin_name, str) else handle_splits[-1]
        self.url = f"https://github.com/{handle}" if url is None else url
        self.install_path = self.handle.replace("/", "-")
        self.git_branch = git_branch

    @staticmethod
    def from_raw(
        handle: str,
        color_name: str,
        plugin_name: str,
        url: str,
        install_path: str,
        git_branch: typing.Optional[str],
    ) -> typing.Any:
        cs = ColorSpec(handle, color_name, url, plugin_name, git_branch)
        cs.plugin_name = plugin_name
        cs.install_path = install_path
        cs.git_branch = git_branch

    def _normalize_handle(self, handle: str) -> str:
        handle = handle.strip()
        while handle.startswith("/"):
            handle = handle[1:]
        while handle.endswith("/"):
            handle = handle[:-1]
        return handle.lower()

    def __str__(self):
        return f"<ColorSpec handle:{self.handle}, color_name:{self.color_name}, url:{self.url}, plugin_name: {self.plugin_name}, git_branch:{self.git_branch}, install_path:{self.install_path}>"

    def __hash__(self):
        return hash(self.handle.lower())

    def __eq__(self, other):
        return isinstance(other, ColorSpec) and self.handle.lower() == other.handle.lower()


# ColorSchemes are picked from:
#
# - Awesome Neovim Colors: <https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/>
# - Awesome Vim Colors: <https://github.com/rafi/awesome-vim-colorschemes>
# - GitHub "neovim-colorscheme" topic: <https://github.com/topics/neovim-colorscheme>
# - GitHub "vim-colorscheme" topic: <https://github.com/topics/vim-colorscheme>

ALL_COLORS = [
    # ---- NEOVIM COLORS ----
    ColorSpec(
        "tomasiser/vim-code-dark",
        "codedark",
    ),
    ColorSpec(
        "Mofiqul/vscode.nvim",
        "vscode",
    ),
    ColorSpec(
        "marko-cerovac/material.nvim",
        "material",
    ),
    ColorSpec(
        "bluz71/vim-nightfly-colors",
        "nightfly",
    ),
    ColorSpec("bluz71/vim-moonfly-colors", "moonfly"),
    ColorSpec("folke/tokyonight.nvim", "tokyonight"),
    ColorSpec("rebelot/kanagawa.nvim", "kanagawa"),
    ColorSpec("vague-theme/vague.nvim", "vague"),
    ColorSpec("olimorris/onedarkpro.nvim", "onedark"),
    ColorSpec("craftzdog/solarized-osaka.nvim", "solarized-osaka"),
    ColorSpec("sainnhe/sonokai", "sonokai"),
    ColorSpec("nyoom-engineering/oxocarbon.nvim", "oxocarbon"),
    ColorSpec("mhartington/oceanic-next", "OceanicNext"),
    ColorSpec("sainnhe/edge", "edge"),
    ColorSpec("savq/melange-nvim", "melange"),
    ColorSpec("fenetikm/falcon", "falcon"),
    ColorSpec("AlexvZyl/nordic.nvim", "nordic"),
    ColorSpec("shaunsingh/nord.nvim", "nord"),
    # replaced by "olimorris/onedarkpro.nvim"
    # ColorSpec(
    #   "navarasu/onedark.nvim",
    #   "onedark"
    # ),
    ColorSpec("sainnhe/gruvbox-material", "gruvbox-material"),
    ColorSpec("sainnhe/everforest", "everforest"),
    ColorSpec(
        "dracula/vim",
        "dracula",
        plugin_name="dracula",
    ),
    ColorSpec("projekt0n/github-nvim-theme", "github_dark"),
    ColorSpec("rose-pine/neovim", "rose-pine", plugin_name="rose-pine"),
    ColorSpec("zenbones-theme/zenbones.nvim", "zenbones"),
    ColorSpec(
        "catppuccin/nvim",
        "catppuccin",
        plugin_name="catppuccin",
    ),
    ColorSpec("EdenEast/nightfox.nvim", "nightfox"),
    ColorSpec("scottmckendry/cyberdream.nvim", "cyberdream"),
    ColorSpec("ellisonleao/gruvbox.nvim", "gruvbox"),
    # ---- VIM COLORS ----
    ColorSpec("ayu-theme/ayu-vim", "ayu"),
    ColorSpec("romainl/Apprentice", "apprentice"),
    ColorSpec("ajmwagar/vim-deus", "deus"),
    ColorSpec("whatyouhide/vim-gotham", "gotham"),
    # replaced by "ellisonleao/gruvbox.nvim"
    # ColorSpec(
    #   "morhetz/gruvbox",
    #   "gruvbox"
    # ),
    ColorSpec("cocopon/iceberg.vim", "iceberg"),
    ColorSpec("NLKNguyen/papercolor-theme", "PaperColor"),
    ColorSpec("nanotech/jellybeans.vim", "jellybeans"),
    # replaced by "shaunsingh/nord.nvim"
    # ColorSpec(
    #   "nordtheme/vim",
    #   "nord",
    # ),
    # replaced by "mhartington/oceanic-next"
    # ColorSpec(
    #   "oceanic-next",
    #   "mhartington/oceanic-next",
    # ),
    ColorSpec("rakr/vim-one", "one"),
    # replaced by "navarasu/onedark.nvim"
    # ColorSpec(
    #   "joshdick/onedark.vim",
    #   "onedark"
    # ),
    ColorSpec("junegunn/seoul256.vim", "seoul256"),
    ColorSpec(
        "lifepillar/vim-solarized8",
        "solarized8",
        url="https://codeberg.org/lifepillar/vim-solarized8",
        git_branch="neovim",
    ),
    ColorSpec("jacoborus/tender.vim", "tender"),
]


# utils {


def init_logging(level: typing.Optional[int]) -> None:
    assert isinstance(level, int) or level is None
    level = logging.WARNING if level is None else level
    logging.basicConfig(
        format="%(asctime)s %(levelname)s [%(filename)s:%(lineno)d](%(funcName)s) - %(message)s",
        level=level,
        handlers=[
            logging.StreamHandler(),
            logging.FileHandler(f"{sys.argv[0]}.log", mode="w"),
        ],
    )


# utils }


class Builder:
    def __init__(self) -> None:
        pass

    def _build_lua_specs(self, all_specs: list[ColorSpec]) -> None:
        lua_specs_by_handle = {}
        lua_specs_by_color_name = {}
        lua_color_names = []

        for i, spec in enumerate(all_specs):
            logging.info(f"dump lua specs for spec-{i}:{spec}")
            lobj = {
                ColorSpec.HANDLE: spec.handle,
                ColorSpec.COLOR_NAME: spec.color_name,
                ColorSpec.PLUGIN_NAME: spec.plugin_name,
                ColorSpec.URL: spec.url,
                ColorSpec.INSTALL_PATH: spec.install_path,
                ColorSpec.GIT_BRANCH: spec.git_branch,
            }
            lua_specs_by_handle[spec.handle] = lobj
            lua_specs_by_color_name[spec.color_name] = lobj
            lua_color_names.append(spec.color_name)

        lua_color_names = sorted(lua_color_names, key=lambda c: c.lower())
        luadata.write(
            "lua/colorbox/meta/specs.lua",
            lua_specs_by_handle,
            encoding="utf-8",
            indent="  ",
            prefix="return ",
        )
        luadata.write(
            "lua/colorbox/meta/specs_by_color_name.lua",
            lua_specs_by_color_name,
            encoding="utf-8",
            indent="  ",
            prefix="return ",
        )
        luadata.write(
            "lua/colorbox/meta/color_names.lua",
            lua_color_names,
            encoding="utf-8",
            indent="  ",
            prefix="return ",
        )

    def _build_md_list(self, all_specs: list[ColorSpec]) -> None:
        total = len(all_specs)
        md = MdUtils(file_name="COLORSCHEMES", title=f"ColorSchemes List ({total})")
        for i, spec in enumerate(all_specs):
            logging.info(f"collect spec-{i}:{spec}")
            md.new_line(f"- {md.new_inline_link(link=spec.url, text=spec.handle)}")
        md.create_md_file()

    def build(self) -> None:
        all_specs = sorted(ALL_COLORS, key=lambda s: s.color_name)
        self._build_md_list(all_specs)
        self._build_lua_specs(all_specs)


@click.command()
@click.option(
    "-d",
    "--debug",
    "debug_opt",
    is_flag=True,
    help="enable debug",
)
def collect(debug_opt):
    init_logging(logging.DEBUG if debug_opt else logging.INFO)
    logging.debug(f"debug_opt:{debug_opt}")

    # Build new data source
    builder = Builder()
    builder.build()


if __name__ == "__main__":
    collect()
