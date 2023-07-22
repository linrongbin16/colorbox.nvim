#!/usr/bin/env python3

import datetime
import logging
import os
import pathlib
import shutil
import subprocess
import sys
from dataclasses import dataclass
from typing import Optional

from tinydb import Query, TinyDB

STARS = 500
LASTCOMMIT = 3 * 365 * 24 * 3600  # 3 years * 365 days * 24 hours * 3600 seconds
INDENT_SIZE = 4
INDENT = " " * INDENT_SIZE
HEADLESS = True
TIMEOUT = 30
CANDIDATE_DIR = "candidate"


@dataclass
class CliOptions:
    log_level: int = logging.WARNING
    headless: bool = False


def parse_options() -> CliOptions:
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
        format="%(asctime)s %(levelname)s [%(filename)s:%(lineno)d]%(funcName)s - %(message)s",
        level=log_level,
        handlers=[logging.StreamHandler(), logging.FileHandler(f"{sys.argv[0]}.log")],
    )


def blacklist(repo) -> bool:
    assert isinstance(repo, RepoObject)
    blacklists = [
        "rafi/awesome-vim-colorschemes",
        "sonph/onehalf",
        "mini.nvim#minischeme",
        "mini.nvim#colorschemes",
        "olimorris/onedarkpro.nvim",
    ]
    return any([True for b in blacklists if repo.url.find(b) >= 0])


def backup_file(src: pathlib.Path):
    """backup file"""
    assert isinstance(src, pathlib.Path)
    if src.is_symlink() or src.exists():
        dest = f"{src}.{datetime.datetime.now().strftime('%Y-%m-%d.%H-%M-%S.%f')}"
        src.rename(dest)
        logging.debug(f"backup '{src}' to '{dest}'")


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


def trim_quotes(s: str) -> str:
    if s.startswith('"') or s.startswith("'"):
        s = s[1:]
    if s.endswith('"') or s.endswith("'"):
        s = s[:-1]
    return s


class GitObject:
    def __init__(self, repo) -> None:
        assert isinstance(repo, RepoObject)
        self.root = pathlib.Path(CANDIDATE_DIR)
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
            logging.debug(clone_cmd)
            if self.path.exists() and self.path.is_dir():
                shutil.rmtree(self.path)
            os.system(clone_cmd)
        except Exception as e:
            logging.exception(
                f"failed to git clone candidate:{self.repo.get_github_url()}", e
            )

    def last_commit_datetime(self) -> datetime.datetime:
        cwd = os.getcwd()
        os.chdir(self.path)
        last_commit_time = subprocess.check_output(
            ["git", "log", "-1", '--format="%at"'], encoding="UTF-8"
        ).strip()
        last_commit_time = trim_quotes(last_commit_time)
        dt = datetime.datetime.fromtimestamp(int(last_commit_time))
        logging.debug(f"repo ({self.repo}) last git commit time:{dt}")
        os.chdir(cwd)
        return dt

    def _init_colors(self) -> list[str]:
        colors_dir = pathlib.Path(f"{self.path}/colors")
        if not colors_dir.exists() or not colors_dir.is_dir():
            return []
        colors_files = [f for f in colors_dir.iterdir() if f.is_file()]
        colors = [
            str(c.name)[:-4]
            for c in colors_files
            if str(c).endswith(".vim") or str(c).endswith(".lua")
        ]
        logging.debug(f"repo ({self.repo}) contains colors:{colors}")
        return colors


@dataclass
class RepoConfig:
    branch: Optional[str] = None

    def __str__(self) -> str:
        return f"<RepoConfig branch:{self.branch}>"


REPO_CONFIG = {
    "projekt0n/github-nvim-theme": RepoConfig(branch="0.0.x"),
}


class RepoObject:
    DATETIME_FORMAT = "%Y-%m-%dT%H:%M:%S"
    DB = TinyDB("repo.json")
    URL = "url"
    STARS = "stars"
    LAST_UPDATE = "last_update"
    PRIORITY = "priority"
    SOURCE = "source"

    def __init__(
        self,
        url: str,
        stars: int,
        last_update: Optional[datetime.datetime] = None,
        priority: int = 0,
        source: Optional[str] = None,
    ) -> None:
        assert isinstance(url, str)
        assert isinstance(stars, int) and stars >= 0
        assert isinstance(last_update, datetime.datetime) or last_update is None
        assert isinstance(priority, int)
        assert isinstance(source, str) or source is None
        self.url = self._init_url(url)
        self.stars = stars
        self.last_update = last_update
        self.priority = priority
        self.config = self._init_config(url)
        self.source = source

    def _init_url(self, url: str) -> str:
        url = url.strip()
        while url.startswith("/"):
            url = url[1:]
        while url.endswith("/"):
            url = url[:-1]
        return url

    def _init_config(self, url: str) -> Optional[RepoConfig]:
        return REPO_CONFIG[url] if url in REPO_CONFIG else None

    def __str__(self):
        return f"<RepoObject url:{self.url}, stars:{self.stars}, last_update:{RepoObject.datetime_tostring(self.last_update)}, priority:{self.priority}, config:{self.config}>"

    def __hash__(self):
        return hash(self.url.lower())

    def __eq__(self, other):
        return isinstance(other, RepoObject) and self.url.lower() == other.url.lower()

    def get_github_url(self):
        return f"https://github.com/{self.url}"

    def altered_name(self) -> Optional[str]:
        url_splits = self.url.split("/")
        org = url_splits[0]
        repo = url_splits[1]

        def invalid(name: str) -> bool:
            return name in ["vim", "nvim", "neovim"]

        return org if invalid(repo) else None

    def altered_branch(self) -> Optional[str]:
        return (
            self.config.branch
            if self.config
            and isinstance(self.config.branch, str)
            and len(self.config.branch.strip()) > 0
            else None
        )

    def add(self) -> None:
        query = Query()
        count = RepoObject.DB.search(query.url == self.url)
        if len(count) <= 0:
            RepoObject.DB.insert(
                {
                    RepoObject.URL: self.url,
                    RepoObject.STARS: self.stars,
                    RepoObject.LAST_UPDATE: RepoObject.datetime_tostring(
                        self.last_update
                    ),
                    RepoObject.PRIORITY: self.priority,
                    RepoObject.SOURCE: self.source,
                }
            )
        else:
            logging.debug(f"failed to add repo ({self}), it's already exist!")

    def update_last_update(self) -> None:
        query = Query()
        count = RepoObject.DB.search(query.url == self.url)
        assert len(count) == 1
        assert isinstance(self.last_update, datetime.datetime)
        RepoObject.DB.update(
            {
                RepoObject.LAST_UPDATE: RepoObject.datetime_tostring(self.last_update),
            },
            query.url == self.url,
        )

    def remove(self) -> None:
        query = Query()
        RepoObject.DB.remove(query.url == self.url)

    @staticmethod
    def reset() -> None:
        RepoObject.DB.truncate()

    @staticmethod
    def get_all() -> list:
        try:
            records = RepoObject.DB.all()
            return [
                RepoObject(
                    url=j[RepoObject.URL],
                    stars=j[RepoObject.STARS],
                    last_update=RepoObject.datetime_fromstring(
                        j[RepoObject.LAST_UPDATE]
                    ),
                    priority=j[RepoObject.PRIORITY],
                )
                for j in records
            ]
        except:
            return []

    @staticmethod
    def datetime_tostring(value: Optional[datetime.datetime]) -> Optional[str]:
        return (
            value.strftime(RepoObject.DATETIME_FORMAT)
            if isinstance(value, datetime.datetime)
            else None
        )

    @staticmethod
    def datetime_fromstring(value: Optional[str]) -> Optional[datetime.datetime]:
        return (
            datetime.datetime.strptime(value, RepoObject.DATETIME_FORMAT)
            if isinstance(value, str) and len(value.strip()) > 0
            else None
        )
