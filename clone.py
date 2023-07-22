#!/usr/bin/env python3

import datetime
import logging
import pathlib
import shutil
from typing import Optional

from util import (LASTCOMMIT, CliOptions, GitObject, RepoObject, init_logging,
                  parse_options)

OPTIONS: Optional[CliOptions] = None


def clone() -> None:
    assert isinstance(OPTIONS, CliOptions)
    # clean candidate dir
    if OPTIONS.log_level <= logging.DEBUG:
        candidate_path = pathlib.Path("candidate")
        if candidate_path.exists() and candidate_path.is_dir():
            shutil.rmtree(candidate_path)

    # clone candidates
    for repo in RepoObject.get_all():
        with GitObject(repo) as candidate:
            candidate.clone()
            last_update = candidate.last_commit_datetime()
            repo.last_update = last_update
            repo.update_last_update()
            if (
                repo.last_update.timestamp() + LASTCOMMIT
                < datetime.datetime.now().timestamp()
            ):
                logging.info(f"clone skip for last_update - repo:{repo}")
                repo.remove()


# main
OPTIONS = parse_options()
init_logging(OPTIONS)
clone()
