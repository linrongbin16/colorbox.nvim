#!/usr/bin/env python3

import datetime
import logging
import os
import pathlib
import shutil
from dataclasses import is_dataclass
from os.path import exists

import util


def dedup() -> set[util.Repo]:
    def greater_than(a: util.Repo, b: util.Repo) -> bool:
        if a.priority != b.priority:
            return a.priority > b.priority
        if a.stars != b.stars:
            return a.stars > b.stars
        # for duplicated colors, we suppose neovim/lua plugins are better
        # and we don't fetch last commit datetime in awesome-neovim's plugins
        # so the repo don't have last_update has higher priority
        if a.last_update is None or b.last_update is None:
            return True if a.last_update is None else False
        return a.last_update.timestamp() > b.last_update.timestamp()

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


class StashSourceCode:
    def __init__(self) -> None:
        for folder in util.CANDIDATE_SOURCE_FOLDERS:
            shutil.rmtree(folder, ignore_errors=True)

    def __enter__(self):
        return self

    def __exit__(self, exception_type, exception_value, traceback):
        shutil.copytree(
            pathlib.Path(".build/doc"), pathlib.Path("doc"), dirs_exist_ok=True
        )
        shutil.copytree(
            pathlib.Path(".build/lua"), pathlib.Path("lua"), dirs_exist_ok=True
        )


def merge(repo: util.Repo) -> None:
    candidate = util.GitObject(repo)
    merge_folders = ["autoload", "colors", "doc", "lua", "after", "src", "tests"]
    target_merge_paths = [pathlib.Path(f"{candidate.path}/{d}") for d in merge_folders]
    merge_paths = [p for p in target_merge_paths if p.exists() and p.is_dir()]
    for source_dir in merge_paths:
        target_dir = pathlib.Path(source_dir.name)
        logging.info(f"merge {source_dir.absolute()} into {target_dir.absolute()}")
        shutil.copytree(source_dir, target_dir, dirs_exist_ok=True)


def path2str(p: pathlib.Path) -> str:
    result = str(p)
    if result.find("\\") >= 0:
        result = result.replace("\\", "/")
    return result


def dump_color() -> None:
    with open("lua/colorswitch/candidates.lua", "w") as cfp:
        cfp.writelines(f"-- Candidates\n")
        cfp.writelines(f"return {{\n")
        colors_dir = pathlib.Path(f"colors")
        colors_files = [
            f
            for f in colors_dir.iterdir()
            if f.is_file() and (str(f).endswith(".vim") or str(f).endswith(".lua"))
        ]
        colors = [str(c.name)[:-4] for c in colors_files]
        for c in colors:
            cfp.writelines(f"{util.INDENT}'{c}',\n")
        cfp.writelines(f"}}\n")


def build() -> None:
    # clean candidate dir
    candidate_path = pathlib.Path("candidate")
    if candidate_path.exists() and candidate_path.is_dir():
        shutil.rmtree(candidate_path)

    # clone candidates
    for repo in util.Repo.get_all():
        with util.GitObject(repo) as candidate:
            candidate.clone()

    # dedup candidates
    deduped_repos = dedup()

    # merge candidates source code
    with StashSourceCode() as stash, open("lua/colorswitch/submodules.lua", "w") as sfp:
        sfp.writelines(f"-- Submodules\n")
        sfp.writelines(f"return {{\n")
        for repo in deduped_repos:
            merge(repo)
            sfp.writelines(f"{util.INDENT}'{repo.url}',\n")
        sfp.writelines(f"}}\n")

    # dump colors
    dump_color()


if __name__ == "__main__":
    options = util.parse_options()
    util.init_logging(options)
    build()
