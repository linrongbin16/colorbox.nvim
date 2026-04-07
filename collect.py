#!/usr/bin/env python3

import datetime
import logging
import math
import os
import pathlib
import shutil
import subprocess
import sys
import time
import typing
from dataclasses import dataclass

import click
import luadata
from mdutils.mdutils import MdUtils
from selenium.webdriver import Chrome, ChromeOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.remote.webelement import WebElement
from selenium.webdriver.support import expected_conditions
from selenium.webdriver.support.wait import WebDriverWait
from tinydb import Query, TinyDB

DB = TinyDB("db.json")


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

    def upsert(self) -> None:
        q = Query()
        count = DB.search(q.handle == self.handle)
        obj = {
            ColorSpec.HANDLE: self.handle,
            ColorSpec.COLOR_NAME: self.color_name,
            ColorSpec.PLUGIN_NAME: self.plugin_name,
            ColorSpec.URL: self.url,
            ColorSpec.INSTALL_PATH: self.install_path,
            ColorSpec.GIT_BRANCH: self.git_branch,
        }
        if len(count) <= 0:
            DB.insert(obj)
            # logging.debug(f"add new repo: {self}")
        else:
            DB.update(obj, q.handle == self.handle)
            # logging.debug(f"add(update) existed repo: {self}")

    @staticmethod
    def all() -> list:
        try:
            records = DB.all()
            # for i, r in enumerate(records):
            #     logging.debug(f"all records-{i}:{r}")
            return [
                ColorSpec(
                    handle=r[ColorSpec.HANDLE],
                    color_name=r[ColorSpec.COLOR_NAME],
                    plugin_name=r[ColorSpec.PLUGIN_NAME],
                    url=r[ColorSpec.URL],
                    install_path=r[ColorSpec.INSTALL_PATH],
                    git_branch=r[ColorSpec.GIT_BRANCH],
                )
                for r in records
            ]
        except:
            return []


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
    ColorSpec("rose-pine/neovim", "rose-pine"),
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


def parse_number(v: str) -> int:
    def to_number(s: str):
        assert isinstance(s, str)
        s = s.lower()
        suffix_map = {"k": 1000, "m": 1000000, "b": 1000000000}
        if s[-1] in suffix_map.keys():
            suffix = s[-1]
            n = float(s[:-1]) * suffix_map[suffix]
        else:
            n = float(s)
        return int(n)

    i = 0
    builder = None
    while i < len(v):
        c = v[i]
        assert isinstance(c, str)
        i += 1
        if c.isdigit() or c == "." or c.lower() in ["k", "m", "b"]:
            if builder is None:
                builder = c
            else:
                builder = builder + c
        else:
            if builder is None:
                continue
            else:
                return to_number(builder)
    assert False


def trim_quotes(s: str) -> str:
    if s.startswith('"') or s.startswith("'"):
        s = s[1:]
    if s.endswith('"') or s.endswith("'"):
        s = s[:-1]
    return s


def datetime_tostring(
    value: typing.Optional[datetime.datetime],
) -> typing.Optional[str]:
    return value.strftime(DATETIME_FORMAT) if isinstance(value, datetime.datetime) else None


def datetime_fromstring(
    value: typing.Optional[str],
) -> typing.Optional[datetime.datetime]:
    return (
        datetime.datetime.strptime(value, DATETIME_FORMAT)
        if isinstance(value, str) and len(value.strip()) > 0
        else None
    )


def date_tostring(value: typing.Optional[datetime.datetime]) -> typing.Optional[str]:
    return value.strftime(DATE_FORMAT) if isinstance(value, datetime.datetime) else None


def date_fromstring(
    value: typing.Optional[str],
) -> typing.Optional[datetime.datetime]:
    return (
        datetime.datetime.strptime(value, DATE_FORMAT)
        if isinstance(value, str) and len(value.strip()) > 0
        else None
    )


def path2str(p: pathlib.Path) -> str:
    result = str(p)
    if result.find("\\") >= 0:
        result = result.replace("\\", "/")
    return result


def retrieve_last_git_commit_datetime(git_path: pathlib.Path) -> datetime.datetime:
    saved_cwd = os.getcwd()
    os.chdir(git_path)
    last_commit_time = subprocess.check_output(
        ["git", "log", "-1", '--format="%at"'], encoding="UTF-8"
    ).strip()
    last_commit_time = trim_quotes(last_commit_time)
    dt = datetime.datetime.fromtimestamp(int(last_commit_time))
    # logging.debug(f"repo ({git_path}) last git commit time:{dt}")
    os.chdir(saved_cwd)
    return dt


# utils }


class Builder:
    def __init__(self) -> None:
        pass

    def _build_lua_specs(self, all_specs: list[ColorSpec]) -> None:
        lspecs = {}
        lspecs_by_colorname = {}
        lspecs_by_gitpath = {}
        lcolornames = []

        for i, spec in enumerate(all_specs):
            logging.info(f"dump lua specs for spec-{i}:{spec}")
            lcolors = sorted(spec.get_vim_color_names())
            lobj = {
                ColorSpec.HANDLE: spec.handle,
                ColorSpec.URL: spec.url,
                ColorSpec.GITHUB_STARS: spec.github_stars,
                ColorSpec.LAST_GIT_COMMIT: date_tostring(spec.last_git_commit),
                ColorSpec.PRIORITY: spec.priority,
                ColorSpec.SOURCE: spec.source,
                ColorSpec.GIT_PATH: spec.git_path,
                ColorSpec.GIT_BRANCH: spec.git_branch,
                ColorSpec.COLOR_NAMES: lcolors,
            }
            lspecs[spec.handle] = lobj
            lspecs_by_gitpath[spec.git_path] = lobj
            for j, color in enumerate(lcolors):
                lcolornames.append(color)
                lspecs_by_colorname[color] = lobj

        lcolornames = sorted(lcolornames, key=lambda c: c.lower())
        luadata.write(
            "lua/colorbox/meta/specs.lua",
            lspecs,
            encoding="utf-8",
            indent="  ",
            prefix="return ",
        )
        luadata.write(
            "lua/colorbox/meta/specs_by_colorname.lua",
            lspecs_by_colorname,
            encoding="utf-8",
            indent="  ",
            prefix="return ",
        )
        luadata.write(
            "lua/colorbox/meta/specs_by_gitpath.lua",
            lspecs_by_gitpath,
            encoding="utf-8",
            indent="  ",
            prefix="return ",
        )
        luadata.write(
            "lua/colorbox/meta/colornames.lua",
            lcolornames,
            encoding="utf-8",
            indent="  ",
            prefix="return ",
        )

    def _build_md_list(self, all_specs: list[ColorSpec]) -> None:
        total = len(all_specs)
        md = MdUtils(file_name="COLORSCHEMES", title=f"ColorSchemes List ({total})")
        for i, spec in enumerate(all_specs):
            logging.info(f"collect spec-{i}:{spec}")
            color_names = spec.get_vim_color_names()
            color_names = sorted(color_names)
            md.new_line(
                f"- {md.new_inline_link(link=spec.url, text=spec.handle)} (stars: {spec.github_stars}, last update: {date_tostring(spec.last_git_commit)})"
            )
            for cname in color_names:
                md.new_line(f"  - {cname}")
        md.create_md_file()

    def build(self) -> None:
        all_specs = sorted(ColorSpec.all(), key=lambda s: s.github_stars, reverse=True)
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
