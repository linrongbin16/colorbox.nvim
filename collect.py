#!/usr/bin/env python3

import datetime
import logging
import os
import pathlib
import shutil
import subprocess
import sys
import typing
from dataclasses import dataclass

from tinydb import Query, TinyDB

STARS = 900
LASTCOMMIT = 3 * 365 * 24 * 3600  # 3 years * 365 days * 24 hours * 3600 seconds
DATETIME_FORMAT = "%Y-%m-%dT%H:%M:%S"


WEBDRIVER = {"HEADLESS": True, "TIMEOUT": 30}

CANDIDATE_DIR = "candidate"


def init_logging(log_level: typing.Optional[int]) -> None:
    assert isinstance(log_level, int) or log_level is None
    log_level = logging.WARNING if log_level is None else log_level
    logging.basicConfig(
        format="%(asctime)s %(levelname)s [%(filename)s:%(lineno)d]%(funcName)s - %(message)s",
        level=log_level,
        handlers=[logging.StreamHandler(), logging.FileHandler(f"{sys.argv[0]}.log")],
    )


def in_blacklist(repo) -> bool:
    assert isinstance(repo, RepoMeta)
    blacklists = [
        "rafi/awesome-vim-colorschemes",
        "sonph/onehalf",
        "mini.nvim#minischeme",
        "mini.nvim#colorschemes",
        "olimorris/onedarkpro.nvim",
    ]
    return any([True for b in blacklists if repo.url.find(b) >= 0])


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
    return (
        value.strftime(DATETIME_FORMAT)
        if isinstance(value, datetime.datetime)
        else None
    )


def datetime_fromstring(
    value: typing.Optional[str],
) -> typing.Optional[datetime.datetime]:
    return (
        datetime.datetime.strptime(value, DATETIME_FORMAT)
        if isinstance(value, str) and len(value.strip()) > 0
        else None
    )


@dataclass
class RepoMetaConfig:
    branch: typing.Optional[str] = None

    def __str__(self) -> str:
        return f"<RepoMetaConfig branch:{self.branch}>"


REPO_META_CONFIG = {}


class RepoMeta:
    DB = TinyDB("db.json")
    URL = "url"
    STARS = "stars"
    LAST_UPDATE = "last_update"
    PRIORITY = "priority"
    SOURCE = "source"

    def __init__(
        self,
        url: str,
        stars: int,
        last_update: typing.Optional[datetime.datetime] = None,
        priority: int = 0,
        source: typing.Optional[str] = None,
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
        self.source = source
        self.config = self._init_config(url)

    def _init_url(self, url: str) -> str:
        url = url.strip()
        while url.startswith("/"):
            url = url[1:]
        while url.endswith("/"):
            url = url[:-1]
        return url

    def _init_config(self, url: str) -> typing.Optional[RepoMetaConfig]:
        return REPO_META_CONFIG[url] if url in REPO_META_CONFIG else None

    def __str__(self):
        return f"<RepoMeta url:{self.url}, stars:{self.stars}, last_update:{datetime_tostring(self.last_update)}, priority:{self.priority}, config:{self.config}>"

    def __hash__(self):
        return hash(self.url.lower())

    def __eq__(self, other):
        return isinstance(other, RepoMeta) and self.url.lower() == other.url.lower()

    def github_url(self):
        return f"https://github.com/{self.url}"

    def configured_branch(self) -> typing.Optional[str]:
        return (
            self.config.branch
            if self.config
            and isinstance(self.config.branch, str)
            and len(self.config.branch.strip()) > 0
            else None
        )

    def add(self) -> None:
        q = Query()
        count = RepoMeta.DB.search(q.url == self.url)
        if len(count) <= 0:
            RepoMeta.DB.insert(
                {
                    RepoMeta.URL: self.url,
                    RepoMeta.STARS: self.stars,
                    RepoMeta.LAST_UPDATE: datetime_tostring(self.last_update),
                    RepoMeta.PRIORITY: self.priority,
                    RepoMeta.SOURCE: self.source,
                }
            )
        else:
            logging.error(f"failed to add repo ({self}), it's already exist!")

    def update_last_update(self) -> None:
        q = Query()
        count = RepoMeta.DB.search(q.url == self.url)
        assert len(count) == 1
        assert isinstance(self.last_update, datetime.datetime)
        RepoMeta.DB.update(
            {
                RepoMeta.LAST_UPDATE: datetime_tostring(self.last_update),
            },
            q.url == self.url,
        )

    def remove(self) -> None:
        query = Query()
        RepoMeta.DB.remove(query.url == self.url)

    @staticmethod
    def truncate() -> None:
        RepoMeta.DB.truncate()

    @staticmethod
    def all() -> list:
        try:
            records = RepoMeta.DB.all()
            return [
                RepoMeta(
                    url=j[RepoMeta.URL],
                    stars=j[RepoMeta.STARS],
                    last_update=datetime_fromstring(j[RepoMeta.LAST_UPDATE]),
                    priority=j[RepoMeta.PRIORITY],
                    source=j[RepoMeta.SOURCE],
                )
                for j in records
            ]
        except:
            return []


class GitObj:
    def __init__(self, repo: RepoMeta) -> None:
        assert isinstance(repo, RepoMeta)
        self.repo = repo
        self.root = pathlib.Path(CANDIDATE_DIR)
        self.root.mkdir(parents=True, exist_ok=True)
        self.path = pathlib.Path(f"{self.root}/{self.repo.url}")

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
                f"git clone --depth=1 --single-branch --branch {specific_branch} {self.repo.github_url()} {self.path}"
                if specific_branch
                else f"git clone --depth=1 {self.repo.github_url()} {self.path}"
            )
            logging.debug(clone_cmd)
            if self.path.exists() and self.path.is_dir():
                shutil.rmtree(self.path)
            os.system(clone_cmd)
        except Exception as e:
            logging.exception(
                f"failed to git clone candidate:{self.repo.github_url()}", e
            )

    def get_last_commit_datetime(self) -> datetime.datetime:
        saved = os.getcwd()
        os.chdir(self.path)
        last_commit_time = subprocess.check_output(
            ["git", "log", "-1", '--format="%at"'], encoding="UTF-8"
        ).strip()
        last_commit_time = trim_quotes(last_commit_time)
        dt = datetime.datetime.fromtimestamp(int(last_commit_time))
        logging.debug(f"repo ({self.repo}) last git commit time:{dt}")
        os.chdir(saved)
        return dt

    def get_color_files(self) -> list[pathlib.Path]:
        colors_dir = pathlib.Path(f"{self.path}/colors")
        if not colors_dir.exists() or not colors_dir.is_dir():
            return []
        return [f for f in colors_dir.iterdir() if f.is_file()]

    def get_colors(self) -> list[str]:
        color_files = self.get_color_files()
        colors = [
            str(c.name)[:-4]
            for c in color_files
            if str(c).endswith(".vim") or str(c).endswith(".lua")
        ]
        logging.debug(f"repo ({self.repo}) contains colors:{colors}")
        return colors
