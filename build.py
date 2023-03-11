#!/usr/bin/env python3

import datetime
import logging
import os
import pathlib
import shutil

import util

INDENT_SIZE = 4
INDENT = " " * INDENT_SIZE


def dedup() -> set[util.Repo]:
    def greater_than(r1: util.Repo, r2: util.Repo) -> bool:
        if r1.priority != r2.priority:
            return r1.priority > r2.priority
        if r1.stars != r2.stars:
            return r1.stars > r2.stars
        # for duplicated colors, we suppose neovim/lua plugins are better
        # and we don't fetch last commit datetime in awesome-neovim's plugins
        # so the repo don't have last_update has higher priority
        if r1.last_update is None or r2.last_update is None:
            return True if r1.last_update is None else False
        return r1.last_update.timestamp() > r2.last_update.timestamp()

    colors: dict[str, util.Repo] = dict()
    repos: set[util.Repo] = set()
    for repo in util.Repo.get_all():
        with util.GitObject(repo) as candidate:
            for color in candidate.colors:
                # detect duplicated color
                if color in colors:
                    old_repo = colors[color]
                    logging.info(
                        f"detect duplicated color on new repo:{repo} and old repo:{old_repo}"
                    )
                    # replace old repo if new repo has higher priority
                    if greater_than(repo, old_repo):
                        logging.info(
                            f"replace old repo:{old_repo} with new repo:{repo}"
                        )
                        colors[color] = repo
                        repos.add(repo)
                        repos.remove(old_repo)
                else:
                    # add new color
                    colors[color] = repo
                    repos.add(repo)
    return repos


def copy(obj: util.GitObject) -> None:
    logging.info(f"merge repo:{obj.repo}")
    # autoload, plugins, doc, colors, lua, etc
    obj_dirs = [
        d for d in obj.path.iterdir() if d.is_dir() and not d.name.startswith(".")
    ]
    for d in obj_dirs:
        target_dir = pathlib.Path(d.name)
        logging.info(f"merge {d.absolute()} into {target_dir.absolute()}")
        shutil.copytree(d, target_dir, dirs_exist_ok=True)


def dump_colors() -> None:
    colors_dir = pathlib.Path("colors")
    colors_files = [
        f
        for f in colors_dir.iterdir()
        if f.is_file() and (str(f).endswith(".vim") or str(f).endswith(".lua"))
    ]
    colors = [str(c)[:-4] for c in colors_files]
    with open("lua/colorswitch/candidates.lua") as fp:
        fp.writelines(f"-- Colorscheme Collections\n")
        fp.writelines(f"{INDENT}return {{\n")
        for c in colors:
            fp.writelines(f"{INDENT*2}{c},\n")
        fp.writelines(f"{INDENT}}}\n")


def build() -> None:
    for repo in util.Repo.get_all():
        with util.GitObject(repo) as candidate:
            candidate.clone()
    deduped_repos = dedup()
    for repo in deduped_repos:
        copy(util.GitObject(repo))
    dump_colors()


if __name__ == "__main__":
    options = util.parse_options()
    util.init_logging(options)
    build()
