#!/usr/bin/env python3

import datetime
import json
import logging
import os
import pathlib
import shutil
import subprocess
import sys
import typing
from dataclasses import dataclass

import click
from mdutils.mdutils import MdUtils
from selenium.webdriver import Chrome, ChromeOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.remote.webelement import WebElement
from selenium.webdriver.support import expected_conditions
from selenium.webdriver.support.wait import WebDriverWait
from tinydb import Query, TinyDB

# github
STARS = 900
LASTCOMMIT = 3 * 365 * 24 * 3600  # 3 years * 365 days * 24 hours * 3600 seconds
BACKLIST = [
    "rafi/awesome-vim-colorschemes",
    "sonph/onehalf",
    "mini.nvim#minischeme",
    "mini.nvim#colorschemes",
    "olimorris/onedarkpro.nvim",
]


# chrome webdriver
HEADLESS = True
TIMEOUT = 30

# git object
DATETIME_FORMAT = "%Y-%m-%dT%H:%M:%S"
CANDIDATE_DIR = "candidate"


def init_logging(log_level: typing.Optional[int]) -> None:
    assert isinstance(log_level, int) or log_level is None
    log_level = logging.WARNING if log_level is None else log_level
    logging.basicConfig(
        format="%(asctime)s %(levelname)s [%(filename)s:%(lineno)d]%(funcName)s - %(message)s",
        level=log_level,
        handlers=[logging.StreamHandler(), logging.FileHandler(f"{sys.argv[0]}.log")],
    )


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


def path2str(p: pathlib.Path) -> str:
    result = str(p)
    if result.find("\\") >= 0:
        result = result.replace("\\", "/")
    return result


def retrieve_last_git_commit_datetime(repo_path: pathlib.Path) -> datetime.datetime:
    saved = os.getcwd()
    os.chdir(repo_path)
    last_commit_time = subprocess.check_output(
        ["git", "log", "-1", '--format="%at"'], encoding="UTF-8"
    ).strip()
    last_commit_time = trim_quotes(last_commit_time)
    dt = datetime.datetime.fromtimestamp(int(last_commit_time))
    logging.debug(f"repo ({repo_path}) last git commit time:{dt}")
    os.chdir(saved)
    return dt


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
    OBJ_NAME = "obj_name"

    def __init__(
        self,
        url: str,
        stars: int,
        last_update: typing.Optional[datetime.datetime] = None,
        priority: int = 0,
        source: typing.Optional[str] = None,
        obj_name: typing.Optional[str] = None,
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
        self.obj_name = self.url.replace("/", "-")
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

    def save(self) -> None:
        q = Query()
        count = RepoMeta.DB.search(q.url == self.url)
        obj = {
            RepoMeta.URL: self.url,
            RepoMeta.STARS: self.stars,
            RepoMeta.LAST_UPDATE: datetime_tostring(self.last_update),
            RepoMeta.PRIORITY: self.priority,
            RepoMeta.SOURCE: self.source,
            RepoMeta.OBJ_NAME: self.obj_name,
        }
        if len(count) <= 0:
            RepoMeta.DB.insert(obj)
        else:
            RepoMeta.DB.update(obj, q.url == self.url)
            logging.debug(f"failed to add repo ({self}), it's already exist!")

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
                    obj_name=j[RepoMeta.OBJ_NAME],
                )
                for j in records
            ]
        except:
            return []


class GitObject:
    def __init__(self, repo: RepoMeta) -> None:
        assert isinstance(repo, RepoMeta)
        self.repo = repo
        self.root = pathlib.Path(CANDIDATE_DIR)
        self.root.mkdir(parents=True, exist_ok=True)
        self.path = pathlib.Path(f"{self.root}/{self.repo.url}")

    def clone(self) -> None:
        try:
            specific_branch = (
                self.repo.config.branch
                if (
                    self.repo.config is not None and self.repo.config.branch is not None
                )
                else None
            )
            logging.debug(
                f"{self.path} exist: {self.path.exists()}, isdir: {self.path.is_dir()}"
            )
            if self.path.exists() and self.path.is_dir():
                logging.info(f"{self.path} already exist, skip...")
            else:
                clone_cmd = (
                    f"git clone --depth=1 --single-branch --branch {specific_branch} {self.repo.github_url()} {self.path}"
                    if specific_branch
                    else f"git clone --depth=1 {self.repo.github_url()} {self.path}"
                )
                logging.debug(clone_cmd)
                os.system(clone_cmd)
        except Exception as e:
            logging.exception(
                f"failed to git clone candidate:{self.repo.github_url()}", e
            )

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


def find_element(driver: Chrome, xpath: str) -> WebElement:
    WebDriverWait(driver, TIMEOUT).until(
        expected_conditions.presence_of_element_located((By.XPATH, xpath))
    )
    return driver.find_element(By.XPATH, xpath)


def find_elements(driver: Chrome, xpath: str) -> list[WebElement]:
    WebDriverWait(driver, TIMEOUT).until(
        expected_conditions.presence_of_element_located((By.XPATH, xpath))
    )
    return driver.find_elements(By.XPATH, xpath)


def make_driver() -> Chrome:
    options = ChromeOptions()
    if HEADLESS:
        options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--single-process")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--allow-running-insecure-content")
    options.add_argument("--ignore-certificate-errors")
    options.add_argument("--allow-insecure-localhost")
    options.add_argument("--disable-blink-features=AutomationControlled")
    options.add_experimental_option("useAutomationExtension", False)
    options.add_experimental_option("excludeSwitches", ["enable-automation"])

    return Chrome(options=options)


# https://vimcolorschemes.com/top
class VimColorSchemes:
    def _pages(self) -> typing.Iterable[str]:
        i = 0
        while True:
            if i == 0:
                yield "https://vimcolorschemes.com/top"
            else:
                yield f"https://vimcolorschemes.com/top/page/{i+1}"
            i += 1

    def _parse_repo(self, element: WebElement) -> RepoMeta:
        url = "/".join(
            element.find_element(By.XPATH, "./a[@class='card__link']")
            .get_attribute("href")
            .split("/")[-2:]
        )
        stars = int(
            element.find_element(
                By.XPATH,
                "./a/section/header[@class='meta-header']//div[@class='meta-header__statistic']//b",
            ).text
        )
        creates_updates = element.find_elements(
            By.XPATH,
            "./a/section/footer[@class='meta-footer']//div[@class='meta-footer__column']//p[@class='meta-footer__row']",
        )
        last_update = datetime.datetime.strptime(
            creates_updates[1]
            .find_element(By.XPATH, "./b/time")
            .get_attribute("datetime"),
            "%Y-%m-%dT%H:%M:%S.%fZ",
        )
        return RepoMeta(
            url,
            stars,
            last_update,
            priority=0,
            source="https://vimcolorschemes.com/top",
        )

    def fetch(self) -> list[RepoMeta]:
        repos: list[RepoMeta] = []
        with make_driver() as driver:
            for page_url in self._pages():
                driver.get(page_url)
                need_more_scan = False
                for element in find_elements(driver, "//article[@class='card']"):
                    repo = self._parse_repo(element)
                    logging.debug(f"vsc repo:{repo}")
                    if repo.stars < STARS:
                        logging.info(f"vsc skip for stars - repo:{repo}")
                        continue
                    logging.info(f"vsc get - repo:{repo}")
                    need_more_scan = True
                    repos.append(repo)
                if not need_more_scan:
                    logging.info(f"vsc no valid stars, exit")
                    break
        return repos


# https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/#colorscheme
class AwesomeNeovimColorScheme:
    def _parse_repo(self, element: WebElement) -> RepoMeta:
        a = element.find_element(By.XPATH, "./a").text
        a_splits = a.split("(")
        repo = a_splits[0]
        stars = parse_number(a_splits[1])
        return RepoMeta(
            repo,
            stars,
            None,
            priority=100,
            source="https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/#colorscheme",
        )

    def _parse_color(self, driver: Chrome, tag_id: str) -> list[RepoMeta]:
        repos = []
        colors_group = find_element(
            driver,
            f"//h3[@id='{tag_id}']/following-sibling::p/following-sibling::ul",
        )
        for e in colors_group.find_elements(By.XPATH, "./li"):
            repo = self._parse_repo(e)
            logging.info(f"acs repo:{repo}")
            repos.append(repo)
        return repos

    def fetch(self) -> list[RepoMeta]:
        repos = []
        with make_driver() as driver:
            driver.get(
                "https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme"
            )
            treesitter_repos = self._parse_color(
                driver, "tree-sitter-supported-colorscheme"
            )
            lua_repos = self._parse_color(driver, "lua-colorscheme")
            repos = treesitter_repos + lua_repos
        return repos


def filter_repo_meta(repos: list[RepoMeta]) -> list[RepoMeta]:
    def blacklist(repo) -> bool:
        return any([True for b in BACKLIST if repo.url.find(b) >= 0])

    filtered_repos: list[RepoMeta] = []
    for repo in repos:
        if blacklist(repo):
            logging.info(f"skip for blacklist - repo:{repo}")
            continue
        if repo.stars < STARS:
            logging.info(f"skip for lower stars - repo:{repo}")
            continue
        repo.save()
    return filtered_repos


class Builder:
    def __init__(self, clean_old: bool) -> None:
        self.clean_old = clean_old

    def _download(self) -> None:
        # clean
        if self.clean_old:
            candidate_path = pathlib.Path("candidate")
            if candidate_path.exists() and candidate_path.is_dir():
                shutil.rmtree(candidate_path)

        # clone candidates
        for repo in RepoMeta.all():
            gobj = GitObject(repo)
            gobj.clone()
            last_update = retrieve_last_git_commit_datetime(gobj.path)
            repo.last_update = last_update
            repo.update_last_update()
            if (
                repo.last_update.timestamp() + LASTCOMMIT
                < datetime.datetime.now().timestamp()
            ):
                logging.info(f"clone skip for too old last_update - repo:{repo}")
                repo.remove()

    def _dedup(self) -> list[RepoMeta]:
        def greater_than(a: RepoMeta, b: RepoMeta) -> bool:
            if a.priority != b.priority:
                return a.priority > b.priority
            if a.stars != b.stars:
                return a.stars > b.stars
            assert isinstance(a.last_update, datetime.datetime)
            assert isinstance(b.last_update, datetime.datetime)
            return a.last_update.timestamp() > b.last_update.timestamp()

        colors: dict[str, RepoMeta] = dict()
        repos: set[RepoMeta] = set()

        for repo in RepoMeta.all():
            candidate = GitObject(repo)
            for color in candidate.get_colors():
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

    def build(self) -> None:
        self._download()
        # dedup candidates
        deduped_repos = self._dedup()

        for repo in RepoMeta.all():
            if not repo in deduped_repos:
                repo.remove()

        md = MdUtils(file_name="COLORSCHEMES", title="ColorSchemes List")
        for repo in RepoMeta.all():
            md.new_line(
                "- " + md.new_inline_link(link=repo.github_url(), text=repo.url)
            )
        md.create_md_file()


@click.command()
@click.option(
    "-d",
    "--debug",
    "debug_opt",
    is_flag=True,
    help="enable debug",
)
@click.option("--no-headless", "no_headless_opt", is_flag=True, help="disable headless")
@click.option("--skip-fetch", "skip_fetch_opt", is_flag=True, help="skip fetching")
@click.option("--skip-build", "skip_build_opt", is_flag=True, help="skip build")
def collect(debug_opt, no_headless_opt, skip_fetch_opt, skip_build_opt):
    global HEADLESS
    init_logging(logging.DEBUG if debug_opt else logging.INFO)
    logging.debug(
        f"debug_opt:{debug_opt}, no_headless_opt:{no_headless_opt}, skip_fetch_opt:{skip_fetch_opt}"
    )
    if no_headless_opt:
        HEADLESS = False
    if not skip_fetch_opt:
        fetched_repos = []
        vcs = VimColorSchemes()
        fetched_repos.extend(vcs.fetch())
        asn = AwesomeNeovimColorScheme()
        fetched_repos.extend(asn.fetch())
        filter_repo_meta(fetched_repos)
    if not skip_build_opt:
        builder = Builder(False if debug_opt else True)
        builder.build()


if __name__ == "__main__":
    collect()
