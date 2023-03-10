#!/usr/bin/env python3

import datetime
import logging
import os
import pathlib
import sqlite3
import sys
from dataclasses import dataclass
from typing import Optional


@dataclass
class CliOptions:
    log_level: int = logging.WARNING
    headless: bool = False


def parse_options():
    log_level = logging.WARNING
    if "--debug" in sys.argv:
        log_level = logging.DEBUG
    if "--info" in sys.argv:
        log_level = logging.INFO
    headless = "--headless" in sys.argv
    return CliOptions(log_level=log_level, headless=headless)


def init_logging(options: CliOptions) -> None:
    log_level = options.log_level
    assert isinstance(log_level, int) or log_level is None
    log_level = logging.WARNING if log_level is None else log_level
    logging.basicConfig(
        format="%(asctime)s %(levelname)s [%(filename)s:%(lineno)d](%(funcName)s) %(message)s",
        level=log_level,
    )


def backup_file(src: pathlib.Path):
    """backup file"""
    assert isinstance(src, pathlib.Path)
    if src.is_symlink() or src.exists():
        dest = f"{src}.{datetime.datetime.now().strftime('%Y-%m-%d.%H-%M-%S.%f')}"
        src.rename(dest)
        logging.info(f"backup '{src}' to '{dest}'")


def parse_number(payload: str) -> int:
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
    while i < len(payload):
        c = payload[i]
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


class DataStore:
    def __init__(self) -> None:
        DATA_FILE = "repo.db"
        self.db = sqlite3.connect(DATA_FILE)
        self._init_repo()

    def _init_repo(self) -> None:
        cur = self.cursor()
        cur.execute(
            """create table if not exists repo (
            url text primary key not null,
            stars integer not null,
            last_update datetime,
            )"""
        )
        self.commit()

    def __enter__(self):
        return self

    def __exit__(self, exception_type, exception_value, traceback):
        if self.db:
            self.db.close()

    def cursor(self) -> sqlite3.Cursor:
        return self.db.cursor()

    def commit(self) -> None:
        self.db.commit()


CANDIDATE_OBJECT_DIR = "candidate"


class CandidateObject:
    def __init__(self, repo) -> None:
        assert isinstance(repo, Repo)
        self.root = pathlib.Path(CANDIDATE_OBJECT_DIR)
        self.root.mkdir(parents=True, exist_ok=True)
        self.repo = repo
        self.path = pathlib.Path(f"{self.root}/{self.repo.url}")
        self.colors: list[str] = []

    def __enter__(self):
        return self

    def __exit__(self, exception_type, exception_value, traceback):
        pass

    def clone(self) -> None:
        try:
            specific_branch = (
                self.repo.config.branch
                if (
                    self.repo.config is not None and self.repo.config.branch is not None
                )
                else None
            )
            clone_cmd = (
                f"git clone --depth=1 --single-branch --branch {specific_branch} {self.repo.get_github_url()} {self.path}"
                if specific_branch
                else f"git clone --depth=1 {self.repo.get_github_url()} {self.path}"
            )
            logging.debug(clone_cmd)
            os.system(clone_cmd)
            # init data after clone git repo
            self.colors = self._init_colors()
        except Exception as e:
            logging.exception(f"failed to git clone:{self.repo.get_github_url()}", e)

    def _init_colors(self) -> list[str]:
        color_dir = pathlib.Path(f"{self.path}/colors")
        color_files = [f for f in color_dir.iterdir() if f.is_file()]
        colors = [
            str(c)[:-4]
            for c in color_files
            if str(c).endswith(".vim") or str(c).endswith(".lua")
        ]
        logging.debug(f"repo ({self.repo.url}) collect colors:{colors}")
        return colors


@dataclass
class RepoConfig:
    branch: Optional[str] = None


REPO_CONFIG = {"projekt0n/github-nvim-theme": RepoConfig(branch="0.0.x")}


class Repo:
    def __init__(
        self,
        url: str,
        stars: int,
        last_update: Optional[datetime.datetime] = None,
        priority: int = 0,
    ) -> None:
        assert isinstance(url, str)
        assert isinstance(stars, int) and stars >= 0
        assert isinstance(last_update, datetime.datetime) or last_update is None
        assert isinstance(priority, int)
        self.url = self._init_url(url)
        self.stars = stars
        self.last_update = last_update
        self.priority = priority
        self.config = self._init_config(url)

    def _init_url(self, url: str) -> str:
        url = url.strip()
        while url.startswith("/"):
            url = url[1:]
        while url.endswith("/"):
            url = url[:-1]
        return url

    def _init_config(self, url: str) -> Optional[RepoConfig]:
        if url not in REPO_CONFIG:
            return None
        return REPO_CONFIG[url]

    def __str__(self):
        return f"<Repo url:{self.url}, stars:{self.stars}, last_update:{self.last_update.isoformat() if self.last_update else None}>"

    def __hash__(self):
        return hash(self.url.lower())

    def __eq__(self, other):
        return isinstance(other, Repo) and self.url.lower() == other.url.lower()

    def get_github_url(self):
        return f"https://github.com/{self.url}"

    def save(self) -> None:
        with DataStore() as data:
            cur = data.cursor()
            count = cur.execute(
                f"select count(*) from repo where url='{self.url}'"
            ).fetchall()
            count = count[0][0]
            if count <= 0:
                # insert
                cur.execute(
                    f"insert into repo values ('{self.url}', {self.stars}, '{self.last_update.isoformat()}')"
                    if self.last_update
                    else f"insert into repo values ('{self.url}', {self.stars})"
                )
            else:
                # update
                cur.execute(
                    f"update repo set url='{self.url}', stars={self.stars}, last_update='{self.last_update.isoformat()}'"
                    if self.last_update
                    else f"update repo set url='{self.url}', stars={self.stars}"
                )
            data.commit()

    @staticmethod
    def get_all() -> list:
        with DataStore() as data:
            cur = data.cursor()
            records = cur.execute(f"select * from repo").fetchall()
            return [Repo(r[0], r[1], r[2]) for r in records]
