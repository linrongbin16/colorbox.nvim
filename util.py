#!/usr/bin/env python3

import datetime
import logging
import os
import pathlib
import shutil
import sys
from dataclasses import dataclass
from typing import Optional

STARS = 500
LASTCOMMIT = 2 * 365 * 24 * 3600  # 2 years * 365 days * 24 hours * 3600 seconds
INDENT_SIZE = 4
INDENT = " " * INDENT_SIZE
HEADLESS = True
TIMEOUT = 30


@dataclass
class CliOptions:
    log_level: int = logging.WARNING
    headless: bool = False


def parse_options():
    log_level = logging.INFO
    if "--debug" in sys.argv:
        log_level = logging.DEBUG
    if "--warn" in sys.argv:
        log_level = logging.WARNING
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


def blacklist(repo) -> bool:
    assert isinstance(repo, Repo)
    blacklists = [
        "rafi/awesome-vim-colorschemes",
        "sonph/onehalf",
        "mini.nvim#minischeme",
        "olimorris/onedarkpro.nvim",
    ]
    return any([True for b in blacklists if repo.url.find(b) >= 0])


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


DATA_FILE = "repo.data"


class DataStore:
    @staticmethod
    def reset() -> None:
        pathlib.Path(DATA_FILE).unlink(missing_ok=True)

    @staticmethod
    def count(repo) -> int:
        assert isinstance(repo, Repo)
        try:
            with open(DATA_FILE, "r") as fp:
                return repo.url.lower() in [
                    line.split(",")[0].strip().lower() for line in fp.readlines()
                ]
        except:
            return 0

    @staticmethod
    def append(repo) -> None:
        assert isinstance(repo, Repo)
        with open(DATA_FILE, "a") as fp:
            fp.writelines(
                f"{repo.url},{repo.stars},{repo.last_update.isoformat() if repo.last_update else None},{repo.priority}\n"
            )

    @staticmethod
    def get_all() -> list:
        try:
            with open(DATA_FILE, "r") as fp:
                repos: list = []
                for line in fp.readlines():
                    line_splits = line.split(",")
                    url = line_splits[0].strip()
                    stars = int(line_splits[1].strip())
                    last_update = (
                        datetime.datetime.fromisoformat(line_splits[2].strip())
                        if line_splits[2].strip() != "None"
                        else None
                    )
                    priority = int(line_splits[3].strip())
                    repos.append(Repo(url, stars, last_update, priority))
                return repos
        except:
            return []


CANDIDATE_OBJECT_DIR = "candidate"
CANDIDATE_SOURCE_FOLDERS = ["autoload", "colors", "doc", "lua", "after", "src", "tests"]


class GitObject:
    def __init__(self, repo) -> None:
        assert isinstance(repo, Repo)
        self.root = pathlib.Path(CANDIDATE_OBJECT_DIR)
        self.root.mkdir(parents=True, exist_ok=True)
        self.repo = repo
        self.path = pathlib.Path(f"{self.root}/{self.repo.url}")
        self.colors = self._init_colors()

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
            logging.info(clone_cmd)
            if self.path.exists() and self.path.is_dir():
                shutil.rmtree(self.path)
            os.system(clone_cmd)
        except Exception as e:
            logging.exception(f"failed to git clone:{self.repo.get_github_url()}", e)

    def _init_colors(self) -> list[str]:
        color_dir = pathlib.Path(f"{self.path}/colors")
        if not color_dir.exists() or not color_dir.is_dir():
            return []
        color_files = [f for f in color_dir.iterdir() if f.is_file()]
        colors = [
            str(c.name)[:-4]
            for c in color_files
            if str(c).endswith(".vim") or str(c).endswith(".lua")
        ]
        logging.info(f"repo ({self.repo.url}) collect colors:{colors}")
        return colors


@dataclass
class RepoConfig:
    branch: Optional[str] = None

    def __str__(self) -> str:
        return f"<RepoConfig branch:{self.branch}>"


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
        return f"<Repo url:{self.url}, stars:{self.stars}, last_update:{self.last_update.isoformat() if self.last_update else None}, priority:{self.priority}, config:{self.config}>"

    def __hash__(self):
        return hash(self.url.lower())

    def __eq__(self, other):
        return isinstance(other, Repo) and self.url.lower() == other.url.lower()

    def get_github_url(self):
        return f"https://github.com/{self.url}"

    def save(self) -> None:
        count = DataStore.count(self)
        if count <= 0:
            DataStore.append(self)

    @staticmethod
    def get_all() -> list:
        return DataStore.get_all()
