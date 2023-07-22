#!/usr/bin/env python3

import datetime
import logging
import pathlib
from typing import Optional, Union

from util import (
    CANDIDATE_DIR,
    INDENT,
    LASTCOMMIT,
    CliOptions,
    GitObject,
    RepoObject,
    init_logging,
    parse_options,
)

OPTIONS: Optional[CliOptions] = None


def dedup() -> list[RepoObject]:
    def greater_than(a: RepoObject, b: RepoObject) -> bool:
        if a.priority != b.priority:
            return a.priority > b.priority
        if a.stars != b.stars:
            return a.stars > b.stars
        assert isinstance(a.last_update, datetime.datetime)
        assert isinstance(b.last_update, datetime.datetime)
        return a.last_update.timestamp() > b.last_update.timestamp()

    colors: dict[str, RepoObject] = dict()
    repos: set[RepoObject] = set()

    for repo in RepoObject.get_all():
        with GitObject(repo) as candidate:
            for color in candidate.colors:
                # detect duplicated color
                if color in colors:
                    old_repo = colors[color]
                    logging.info(
                        f"detect duplicated color({color}), new:{repo}, old:{old_repo}"
                    )
                    # replace old repo if new repo has higher priority
                    if greater_than(repo, old_repo):
                        logging.info(f"replace old repo({old_repo}) with new({repo})")
                        colors[color] = repo
                        repos.add(repo)
                        repos.remove(old_repo)
                else:
                    # add new color
                    colors[color] = repo
                    repos.add(repo)
    return sorted(list(repos), key=lambda r: (r.url.lower(), r.stars))


def path2str(p: pathlib.Path) -> str:
    result = str(p)
    if result.find("\\") >= 0:
        result = result.replace("\\", "/")
    return result


class Writer:
    def __init__(self, path: str) -> None:
        self.fp = open(path, "w")

    def __enter__(self):
        return self

    def __exit__(self, exception_type, exception_value, traceback):
        if self.fp:
            self.fp.close()
        self.fp = None


class ColorPluginWriter(Writer):
    def __init__(self, path: str) -> None:
        super().__init__(path)
        self.fp.writelines("return {\n")

    def __exit__(self, exception_type, exception_value, traceback):
        self.fp.writelines("}\n")
        super().__exit__(exception_type, exception_value, traceback)

    def append(self, repo: RepoObject):
        name = repo.altered_name()
        optional_name = f"{INDENT * 2}name = '{name}',\n" if name else ""
        branch = repo.altered_branch()
        optional_branch = f"{INDENT * 2}branch = '{branch}',\n" if branch else ""
        self.fp.writelines(
            f"""{INDENT}{{
{INDENT*2}"{repo.url}",
{INDENT*2}lazy = true,
{INDENT*2}priority = 1000,
{optional_name}{optional_branch}{INDENT}}},\n"""
        )


class ColorNameWriter(Writer):
    def __init__(self, path: str) -> None:
        super().__init__(path)
        self.fp.writelines("let s:colors=[\n")

    def __exit__(self, exception_type, exception_value, traceback):
        self.fp.writelines(f"{INDENT*3}\\]\n")
        super().__exit__(exception_type, exception_value, traceback)

    def append(self, color: Union[str, list]):
        if isinstance(color, list):
            for c in color:
                self.fp.writelines(f"{INDENT*3}\\ '{c}',\n")
        else:
            assert isinstance(color, str)
            self.fp.writelines(f"{INDENT*3}\\ '{color}',\n")


def list_colors(repo: RepoObject) -> list[str]:
    colors_dir = pathlib.Path(f"{CANDIDATE_DIR}/{repo.url}/colors")
    colors_files = [
        f
        for f in colors_dir.iterdir()
        if f.is_file() and (str(f).endswith(".vim") or str(f).endswith(".lua"))
    ]
    colors = [str(c.name)[:-4] for c in colors_files]
    return colors


def list_primary_color(repo: RepoObject) -> str:
    colors = list_colors(repo)
    primary_color = None
    if repo.url.lower() in [
        "EdenEast/nightfox.nvim".lower(),
        "projekt0n/github-nvim-theme".lower,
    ]:
        for c in colors:
            if c in ["nightfox", "github_dark"]:
                primary_color = c
    else:
        for c in colors:
            if primary_color is None or len(c) < len(primary_color):
                primary_color = c
    assert isinstance(primary_color, str)
    return primary_color


def list_dark_colors(repo: RepoObject) -> list[str]:
    colors = list_colors(repo)
    dark_colors = [
        c
        for c in colors
        if c.lower().find("light") < 0
        and c.lower().find("day") < 0
        and c.lower().find("dawn") < 0
    ]
    return dark_colors


def dump_color(
    plugin_writer: ColorPluginWriter,
    primary_writer: ColorNameWriter,
    dark_writer: ColorNameWriter,
    repo: RepoObject,
) -> None:
    primary_color = list_primary_color(repo)
    primary_writer.append(primary_color)
    dark_colors = list_dark_colors(repo)
    dark_writer.append(dark_colors)
    plugin_writer.append(repo)


def build() -> None:
    # dedup candidates
    deduped_repos = dedup()

    # dump colors
    with ColorPluginWriter(
        "output/color-plugins.lua"
    ) as plugin_writer, ColorNameWriter(
        "output/primary-color-names.vim"
    ) as primary_writer, ColorNameWriter(
        "output/dark-color-names.vim"
    ) as dark_writer:
        for repo in deduped_repos:
            dump_color(plugin_writer, primary_writer, dark_writer, repo)


# main
OPTIONS = parse_options()
init_logging(OPTIONS)
build()
