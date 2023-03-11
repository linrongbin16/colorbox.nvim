#!/usr/bin/env python3

import datetime
import logging
import os
import pathlib
import shutil
from re import sub

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


def dump_colors(fp, repo: util.Repo) -> None:
    colors_dir = pathlib.Path(f"submodule/{repo.url}/colors")
    colors_files = [
        f
        for f in colors_dir.iterdir()
        if f.is_file() and (str(f).endswith(".vim") or str(f).endswith(".lua"))
    ]
    colors = [str(c.name)[:-4] for c in colors_files]
    for c in colors:
        fp.writelines(f"{INDENT*2}{c},\n")


def build() -> None:
    for repo in util.Repo.get_all():
        with util.GitObject(repo) as candidate:
            candidate.clone()
    deduped_repos = dedup()
    for repo in deduped_repos:
        submodule_path = pathlib.Path(f"submodule/{repo.url}")
        if not submodule_path.exists() or not submodule_path.is_dir():
            submodule_cmd = (
                f"git submodule add -b {repo.config.branch} https://github.com/{repo.url} {submodule_path}\n"
                if repo.config and repo.config.branch
                else f"git submodule add https://github.com/{repo.url} {submodule_path}\n"
            )
            logging.info(submodule_cmd)
            os.system(submodule_cmd)
    update_submodule_cmd = "git submodule update --remote"
    logging.info(update_submodule_cmd)
    os.system(update_submodule_cmd)
    with open("lua/colorswitch/candidates.lua") as fp:
        fp.writelines(f"-- Colorscheme Collections\n")
        fp.writelines(f"{INDENT}return {{\n")
        for repo in deduped_repos:
            dump_colors(fp, repo)
        fp.writelines(f"{INDENT}}}\n")


if __name__ == "__main__":
    options = util.parse_options()
    util.init_logging(options)
    build()
