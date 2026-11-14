#!/usr/bin/env python3
"""Generate the colorscheme dataset consumed by colorbox.nvim.

The hand-maintained list below (:data:`ALL_COLORS`) is the single source of
truth. Running this script regenerates:

- ``lua/colorbox/db/dataset.lua``: handle => color name, plus the handful of
  fields that cannot be derived from the handle.
- ``COLORSCHEMES.md``: human readable list.

``lua/colorbox/db.lua`` expands the dataset into full ``colorbox.ColorSpec``
tables at runtime, so the checked-in data stays minimal.

Usage::

    python3 collect.py [--debug]
"""

from __future__ import annotations

import logging
from collections.abc import Iterable
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, cast

import click
import luadata

SCRIPT_DIR = Path(__file__).resolve().parent
LUA_DB_DIR = SCRIPT_DIR / "lua" / "colorbox" / "db"

DATASET_LUA = LUA_DB_DIR / "dataset.lua"
COLORSCHEMES_MD = SCRIPT_DIR / "COLORSCHEMES.md"

LUA_INDENT = "  "
LUA_PREFIX = "return "

logger = logging.getLogger("collect")


class ColorSpecError(ValueError):
    """Raised when a colorscheme spec in :data:`ALL_COLORS` is invalid."""


def normalize_handle(handle: str) -> str:
    """Normalize a ``owner/repo`` git handle: trim slashes, lowercase."""
    return handle.strip().strip("/").lower()


@dataclass(frozen=True)
class ColorSpec:
    """A colorscheme plugin, plus the metadata needed to install and load it."""

    handle: str
    color_name: str
    url: str | None = field(default=None)
    plugin_name: str | None = field(default=None)
    git_branch: str | None = field(default=None)
    install_path: str = field(default="", init=False)

    def __post_init__(self) -> None:
        handle = normalize_handle(self.handle)
        owner, sep, repo = handle.partition("/")
        if not sep or not owner or not repo or "/" in repo:
            raise ColorSpecError(
                f"invalid handle {self.handle!r} for color {self.color_name!r}: expect 'owner/repo'"
            )
        if not self.color_name.strip():
            raise ColorSpecError(f"empty color name for handle {handle!r}")

        object.__setattr__(self, "handle", handle)
        object.__setattr__(self, "install_path", handle.replace("/", "-"))
        if self.url is None:
            object.__setattr__(self, "url", f"https://github.com/{handle}")
        if self.plugin_name is None:
            object.__setattr__(self, "plugin_name", repo)

    @property
    def repo(self) -> str:
        """The repository name, i.e. the part after ``owner/``."""
        return self.handle.partition("/")[2]

    def to_overrides(self) -> dict[str, str]:
        """Fields that ``db.lua`` cannot derive from the handle."""
        plugin_name = cast(str, self.plugin_name)
        url = cast(str, self.url)
        overrides: dict[str, str] = {}
        if plugin_name != self.repo:
            overrides["plugin_name"] = plugin_name
        if url != f"https://github.com/{self.handle}":
            overrides["url"] = url
        if self.git_branch is not None:
            overrides["git_branch"] = self.git_branch
        return overrides

    def __str__(self) -> str:
        return (
            f"<ColorSpec handle:{self.handle}, color_name:{self.color_name}, "
            f"url:{self.url}, plugin_name:{self.plugin_name}, "
            f"git_branch:{self.git_branch}, install_path:{self.install_path}>"
        )


# ColorSchemes are picked from below websites, with GitHub stars >= 800:
#
# - Awesome Neovim Colors: <https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/>
# - Awesome Vim Colors: <https://github.com/rafi/awesome-vim-colorschemes>
# - GitHub "neovim-colorscheme" topic: <https://github.com/topics/neovim-colorscheme>
# - GitHub "vim-colorscheme" topic: <https://github.com/topics/vim-colorscheme>

ALL_COLORS: list[ColorSpec] = [
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


def init_logging(level: int | None) -> None:
    logging.basicConfig(
        format="%(asctime)s %(levelname)s [%(filename)s:%(lineno)d](%(funcName)s) - %(message)s",
        level=logging.INFO if level is None else level,
        handlers=[
            logging.StreamHandler(),
            logging.FileHandler(f"{SCRIPT_DIR / 'collect.py'}.log", mode="w"),
        ],
    )


def validate_specs(specs: Iterable[ColorSpec]) -> list[ColorSpec]:
    """Sort specs by color name, rejecting duplicate handles or color names."""
    sorted_specs = sorted(specs, key=lambda spec: spec.color_name.lower())

    seen_handles: dict[str, str] = {}
    seen_color_names: dict[str, str] = {}
    for spec in sorted_specs:
        if spec.handle in seen_handles:
            raise ColorSpecError(
                f"duplicate handle {spec.handle!r}: "
                f"{seen_handles[spec.handle]!r} and {spec.color_name!r}"
            )
        seen_handles[spec.handle] = spec.color_name

        key = spec.color_name.lower()
        if key in seen_color_names:
            raise ColorSpecError(
                f"duplicate color name {spec.color_name!r}: "
                f"{seen_color_names[key]!r} and {spec.handle!r}"
            )
        seen_color_names[key] = spec.handle

    return sorted_specs


def write_lua(path: Path, data: Any) -> None:
    luadata.write(str(path), data, encoding="utf-8", indent=LUA_INDENT, prefix=LUA_PREFIX)
    # luadata writes no trailing newline, add one so editors/formatters stay happy.
    with path.open("a", encoding="utf-8") as f:
        f.write("\n")
    logger.debug("wrote %s", path)


def render_colorschemes_markdown(specs: Iterable[ColorSpec]) -> str:
    """Render ``COLORSCHEMES.md``: a setext title followed by a link list."""
    specs = list(specs)
    title = f"ColorSchemes List ({len(specs)})"
    lines = [f"- {spec.color_name}: [{spec.handle}]({spec.url})" for spec in specs]
    return f"\n{title}\n{'=' * len(title)}\n\n" + "\n".join(lines)


def render_dataset(specs: Iterable[ColorSpec]) -> dict[str, Any]:
    """Render the Lua dataset: color names keyed by handle, plus overrides.

    Everything else (``url``, ``plugin_name``, ``install_path``) is derived from
    the handle by ``lua/colorbox/db.lua``, so it is not duplicated here.
    """
    dataset: dict[str, Any] = {spec.handle: spec.color_name for spec in specs}
    overrides = {spec.handle: spec.to_overrides() for spec in specs}
    overrides = {handle: fields for handle, fields in overrides.items() if fields}
    return {"specs": dataset, "overrides": overrides}


def generate(specs: Iterable[ColorSpec] = ALL_COLORS) -> None:
    """Regenerate every dataset file from ``specs``."""
    sorted_specs = validate_specs(specs)

    write_lua(DATASET_LUA, render_dataset(sorted_specs))

    COLORSCHEMES_MD.write_text(render_colorschemes_markdown(sorted_specs), encoding="utf-8")
    logger.debug("wrote %s", COLORSCHEMES_MD)


@click.command()
@click.option("-d", "--debug", "debug_opt", is_flag=True, help="enable debug logging.")
def main(debug_opt: bool) -> None:
    init_logging(logging.DEBUG if debug_opt else logging.INFO)

    logger.info("generating dataset from %d colorschemes", len(ALL_COLORS))
    for index, spec in enumerate(ALL_COLORS):
        logger.debug("[%d]:%s", index, spec)

    generate()


if __name__ == "__main__":
    main()
