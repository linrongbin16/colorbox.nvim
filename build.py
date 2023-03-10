#!/usr/bin/env python3

import datetime
import logging
import os
import pathlib

import util


def dedup() -> set[util.Repo]:
    colors: dict[str, util.Repo] = dict()
    repos: set[util.Repo] = set()
    for repo in util.Repo.get_all():
        with util.CandidateObject(repo) as candidate:
            for color in candidate.colors:
                # detect duplicated color
                if color in colors:
                    old_repo = colors[color]
                    # replace old repo if new repo has higher priority
                    if repo.priority > old_repo.priority:
                        colors[color] = repo
                        repos.add(repo)
                        repos.remove(old_repo)
                else:
                    # add new color
                    colors[color] = repo
                    repos.add(repo)
    return repos


def build() -> None:
    for repo in util.Repo.get_all():
        with util.CandidateObject(repo) as candidate:
            candidate.clone()
    repos = dedup()


if __name__ == "__main__":
    options = util.parse_options()
    util.init_logging(options)
    build()
