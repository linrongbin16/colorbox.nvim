#!/usr/bin/env python3

import datetime
import logging
import os
import pathlib
import shutil
import subprocess
import sys
import time
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
GITHUB_STARS = 500
LAST_GIT_COMMIT = 3 * 365 * 24 * 3600  # 3 years * 365 days * 24 hours * 3600 seconds
BLACKLIST = [
    "rafi/awesome-vim-colorschemes",
    "sonph/onehalf",
    "mini.nvim#minischeme",
    "mini.nvim#colorschemes",
    "olimorris/onedarkpro.nvim",
    "text-to-colorscheme",
]


# chrome webdriver
WEBDRIVER_HEADLESS = True
WEBDRIVER_TIMEOUT = 30

# git object
DATETIME_FORMAT = "%Y-%m-%dT%H:%M:%S"
DATE_FORMAT = "%Y-%m-%d"
CANDIDATE_DIR = "candidate"

if os.path.exists("db.json"):
    os.remove("db.json")


def init_logging(level: typing.Optional[int]) -> None:
    assert isinstance(level, int) or level is None
    level = logging.WARNING if level is None else level
    logging.basicConfig(
        format="%(asctime)s %(levelname)s [%(filename)s:%(lineno)d](%(funcName)s) - %(message)s",
        level=level,
        handlers=[
            logging.StreamHandler(),
            logging.FileHandler(f"{sys.argv[0]}.log", mode="w"),
        ],
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


def date_tostring(value: typing.Optional[datetime.datetime]) -> typing.Optional[str]:
    return value.strftime(DATE_FORMAT) if isinstance(value, datetime.datetime) else None


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


def retrieve_last_git_commit_datetime(git_path: pathlib.Path) -> datetime.datetime:
    saved_cwd = os.getcwd()
    os.chdir(git_path)
    last_commit_time = subprocess.check_output(
        ["git", "log", "-1", '--format="%at"'], encoding="UTF-8"
    ).strip()
    last_commit_time = trim_quotes(last_commit_time)
    dt = datetime.datetime.fromtimestamp(int(last_commit_time))
    logging.debug(f"repo ({git_path}) last git commit time:{dt}")
    os.chdir(saved_cwd)
    return dt


@dataclass
class ColorSpecConfig:
    git_branch: typing.Optional[str] = None

    def __str__(self) -> str:
        return f"<ColorSpecConfig git_branch:{self.git_branch if isinstance(self.git_branch, str) else 'None'}>"


REPO_META_CONFIG = {"lifepillar/vim-solarized8": ColorSpecConfig(git_branch="neovim")}


class ColorSpec:
    DB = TinyDB("db.json")
    HANDLE = "handle"
    URL = "url"
    GITHUB_STARS = "github_stars"
    PRIORITY = "priority"
    SOURCE = "source"
    LAST_GIT_COMMIT = "last_git_commit"
    GIT_PATH = "git_path"
    GIT_BRANCH = "git_branch"
    COLOR_NAMES = "color_names"

    def __init__(
        self,
        handle: str,
        github_stars: int,
        last_git_commit: typing.Optional[datetime.datetime] = None,
        priority: int = 0,
        source: typing.Optional[str] = None,
    ) -> None:
        assert isinstance(handle, str)
        assert isinstance(github_stars, int) and github_stars >= 0
        assert isinstance(last_git_commit, datetime.datetime) or last_git_commit is None
        assert isinstance(priority, int)
        assert isinstance(source, str) or source is None
        self.handle = self._init_url(handle)
        self.url = f"https://github.com/{self.handle}"
        self.github_stars = github_stars
        self.priority = priority
        self.source = source
        self.last_git_commit = last_git_commit
        self.git_path = self.handle.replace("/", "-")
        self.candidate_path = f"{CANDIDATE_DIR}/{self.git_path}"
        config = self._init_config(handle)
        self.git_branch = None
        if isinstance(config, ColorSpecConfig):
            if isinstance(config.git_branch, str):
                self.git_branch = config.git_branch
        self.color_names: list[str] = []
        # logging.debug(f"initialize ColorSpec:{self}")

    def _init_url(self, handle: str) -> str:
        handle = handle.strip()
        while handle.startswith("/"):
            handle = handle[1:]
        while handle.endswith("/"):
            handle = handle[:-1]
        return handle

    def _init_config(self, handle: str) -> typing.Optional[ColorSpecConfig]:
        return REPO_META_CONFIG[handle] if handle in REPO_META_CONFIG else None

    def __str__(self):
        return f"<ColorSpec handle:{self.handle}, url:{self.url}, github_stars:{self.github_stars}, priority:{self.priority}, last_git_commit:{datetime_tostring(self.last_git_commit)}, git_branch:{self.git_branch if isinstance(self.git_branch, str) else 'None'}>"

    def __hash__(self):
        return hash(self.handle.lower())

    def __eq__(self, other):
        return (
            isinstance(other, ColorSpec) and self.handle.lower() == other.handle.lower()
        )

    def save(self) -> None:
        q = Query()
        count = ColorSpec.DB.search(q.handle == self.handle)
        obj = {
            ColorSpec.HANDLE: self.handle,
            ColorSpec.URL: self.url,
            ColorSpec.GITHUB_STARS: self.github_stars,
            ColorSpec.LAST_GIT_COMMIT: datetime_tostring(self.last_git_commit),
            ColorSpec.PRIORITY: self.priority,
            ColorSpec.SOURCE: self.source,
            ColorSpec.GIT_PATH: self.git_path,
            ColorSpec.GIT_BRANCH: self.git_branch,
            ColorSpec.COLOR_NAMES: self.color_names,
        }
        if len(count) <= 0:
            ColorSpec.DB.insert(obj)
            logging.debug(f"add new repo: {self}")
        else:
            ColorSpec.DB.update(obj, q.handle == self.handle)
            logging.debug(f"add(update) existed repo: {self}")

    def update_last_git_commit(self, last_git_commit: datetime.datetime) -> None:
        q = Query()
        records = ColorSpec.DB.search(q.handle == self.handle)
        assert len(records) == 1
        assert isinstance(last_git_commit, datetime.datetime)
        self.last_git_commit = last_git_commit
        ColorSpec.DB.update(
            {
                ColorSpec.LAST_GIT_COMMIT: datetime_tostring(self.last_git_commit),
            },
            q.handle == self.handle,
        )

    def update_color_names(self, color_names: list[str]) -> None:
        q = Query()
        records = ColorSpec.DB.search(q.handle == self.handle)
        assert len(records) == 1
        assert isinstance(color_names, list)
        self.color_names = color_names
        ColorSpec.DB.update(
            {
                ColorSpec.COLOR_NAMES: self.color_names,
            },
            q.handle == self.handle,
        )

    def remove(self) -> None:
        query = Query()
        ColorSpec.DB.remove(query.handle == self.handle)

    @staticmethod
    def truncate() -> None:
        ColorSpec.DB.truncate()

    @staticmethod
    def all() -> list:
        try:
            records = ColorSpec.DB.all()
            # for i, r in enumerate(records):
            #     logging.debug(f"all records-{i}:{r}")
            return [
                ColorSpec(
                    handle=r[ColorSpec.HANDLE],
                    github_stars=r[ColorSpec.GITHUB_STARS],
                    last_git_commit=datetime_fromstring(r[ColorSpec.LAST_GIT_COMMIT]),
                    priority=r[ColorSpec.PRIORITY],
                    source=r[ColorSpec.SOURCE],
                )
                for r in records
            ]
        except:
            return []

    def download_git_object(self) -> bool:
        try:
            clone_cmd = None
            if isinstance(self.git_branch, str):
                clone_cmd = f"git clone --depth=1 --single-branch --branch {self.git_branch} {self.url} {self.candidate_path}"
            else:
                clone_cmd = f"git clone --depth=1 {self.url} {self.candidate_path}"
            # logging.debug(f"self:{self}, candidate_path:{self.candidate_path}")
            candidate_dir = pathlib.Path(f"{self.candidate_path}")
            logging.debug(
                f"{candidate_dir} exist: {candidate_dir.exists()}, isdir: {candidate_dir.is_dir()}"
            )
            if candidate_dir.exists() and candidate_dir.is_dir():
                logging.debug(f"{candidate_dir} already exist, skip...")
            else:
                logging.debug(clone_cmd)
                os.system(clone_cmd)
            return True
        except Exception as e:
            logging.exception(f"failed to download git object: {self.url}", e)
            return False

    def get_vim_color_names(self) -> list[str]:
        colors_dir = pathlib.Path(f"{self.candidate_path}/colors")
        if not colors_dir.exists() or not colors_dir.is_dir():
            return []
        color_files = [f for f in colors_dir.iterdir() if f.is_file()]
        colors = [
            str(c.name)[:-4]
            for c in color_files
            if str(c).endswith(".vim") or str(c).endswith(".lua")
        ]
        logging.debug(f"retrieve colors from spec ({self}): {colors}")
        return colors


def find_element(driver: Chrome, xpath: str) -> WebElement:
    WebDriverWait(driver, WEBDRIVER_TIMEOUT).until(
        expected_conditions.presence_of_all_elements_located((By.XPATH, xpath))
    )
    time.sleep(1.5)
    return driver.find_element(By.XPATH, xpath)


def find_elements(driver: Chrome, xpath: str) -> list[WebElement]:
    WebDriverWait(driver, WEBDRIVER_TIMEOUT).until(
        expected_conditions.presence_of_all_elements_located((By.XPATH, xpath))
    )
    time.sleep(1.5)
    return driver.find_elements(By.XPATH, xpath)


def make_driver() -> Chrome:
    options = ChromeOptions()
    if WEBDRIVER_HEADLESS:
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
    def __init__(self) -> None:
        self.counter = 1

    def _pages(self) -> typing.Iterable[str]:
        i = 0
        while True:
            if i == 0:
                yield "https://vimcolorschemes.com/top"
            else:
                yield f"https://vimcolorschemes.com/top/page/{i+1}"
            i += 1

    def _parse_spec(
        self, element: WebElement, source: str
    ) -> typing.Optional[ColorSpec]:
        logging.debug(f"parsing (vsc) spec element:{element}")
        try:
            url = element.find_element(
                By.XPATH, "./a[@class='card__link']"
            ).get_attribute("href")
            if url.endswith("/"):
                url = url[:-1]
            logging.debug(f"parsing (vsc) spec handle_elem:{url}")
            handle = "/".join(url.split("/")[-2:])
            logging.debug(f"parsing (vsc) spec handle:{handle}")
            github_stars = int(
                element.find_element(
                    By.XPATH,
                    "./a/section/header[@class='meta-header']//div[@class='meta-header__statistic']//b",
                ).text
            )
            logging.debug(f"parsing (vsc) spec github_stars:{github_stars}")
            creates_updates = element.find_elements(
                By.XPATH,
                "./a/section/footer[@class='meta-footer']//div[@class='meta-footer__column']//p[@class='meta-footer__row']",
            )
            logging.debug(f"parsing (vsc) spec creates_updates:{creates_updates}")
            return ColorSpec(
                handle,
                github_stars,
                last_git_commit=None,
                priority=0,
                source=source,
            )
        except Exception as e:
            logging.exception(f"failed to fetch vsc element: {element}", e)
            return None

    def fetch(self) -> None:
        with make_driver() as driver:
            for page_url in self._pages():
                driver.get(page_url)
                driver.execute_script("window.scrollBy(0,document.body.scrollHeight)")
                need_more_scan = False
                for element in find_elements(driver, "//article[@class='card']"):
                    spec = self._parse_spec(element, page_url)
                    logging.debug(f"vsc repo:{spec}")
                    if spec is None:
                        continue
                    if len(spec.handle.split("/")) != 2:
                        logging.debug(f"skip for invalid handle - (vcs) spec:{spec}")
                        continue
                    if spec.github_stars < GITHUB_STARS:
                        logging.debug(f"skip for lower stars - (vcs) spec:{spec}")
                        continue
                    logging.info(f"fetch (vcs) spec-{self.counter}:{spec}")
                    need_more_scan = True
                    spec.save()
                    self.counter = self.counter + 1
                if not need_more_scan:
                    logging.debug(f"no more enough github stars, exit...")
                    break


# https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/#colorscheme
class AwesomeNeovimColorScheme:
    def __init__(self) -> None:
        self.counter = 1

    def _parse_spec(self, element: WebElement, source: str) -> ColorSpec:
        a = element.find_element(By.XPATH, "./a").text
        a_splits = a.split("(")
        handle = a_splits[0]
        github_stars = parse_number(a_splits[1])
        return ColorSpec(
            handle,
            github_stars,
            last_git_commit=None,
            priority=100,
            source=source,
        )

    def _parse_colors_list(self, driver: Chrome, tag_id: str) -> list[ColorSpec]:
        repos = []
        colors_group = find_element(
            driver,
            f"//h3[@id='{tag_id}']/following-sibling::p/following-sibling::ul",
        )
        for e in colors_group.find_elements(By.XPATH, "./li"):
            spec = self._parse_spec(
                e,
                f"https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme#{tag_id}",
            )
            if len(spec.handle.split("/")) != 2:
                logging.debug(f"skip for invalid handle - (asn) spec:{spec}")
                continue
            if spec.github_stars < GITHUB_STARS:
                logging.debug(f"skip for lower stars - (asn) spec:{spec}")
                continue
            logging.info(f"fetch (asn) repo-{self.counter}:{spec}")
            repos.append(spec)
            self.counter = self.counter + 1
        return repos

    def fetch(self) -> None:
        with make_driver() as driver:
            driver.get(
                "https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme"
            )
            driver.execute_script("window.scrollBy(0,document.body.scrollHeight)")
            treesitter_specs = self._parse_colors_list(
                driver, "tree-sitter-supported-colorscheme"
            )
            for spec in treesitter_specs:
                spec.save()
            lua_specs = self._parse_colors_list(driver, "lua-colorscheme")
            for spec in lua_specs:
                spec.save()


def filter_color_specs() -> None:
    # logging.debug(f"before filter:{[str(s) for s in specs]}")

    def blacklist(sp: ColorSpec) -> bool:
        return any([True for b in BLACKLIST if sp.url.find(b) >= 0])

    for spec in ColorSpec.all():
        logging.debug(f"process filtering on spec:{spec}")
        if spec.github_stars < GITHUB_STARS:
            logging.debug(f"skip for lower stars - spec:{spec}")
            spec.remove()
            continue
        if blacklist(spec):
            logging.debug(f"skip for blacklist - spec:{spec}")
            spec.remove()
            continue
        else:
            logging.debug(f"no-skip for blacklist - spec:{spec}")


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
        for spec in ColorSpec.all():
            logging.debug(f"download spec:{spec}")
            assert isinstance(spec, ColorSpec)
            spec.download_git_object()
            last_update = retrieve_last_git_commit_datetime(
                pathlib.Path(spec.candidate_path)
            )
            spec.update_last_git_commit(last_update)
            assert isinstance(spec.last_git_commit, datetime.datetime)
            if (
                spec.last_git_commit.timestamp() + LAST_GIT_COMMIT
                < datetime.datetime.now().timestamp()
            ):
                logging.debug(f"skip for too old git commit - spec:{spec}")
                spec.remove()
                continue
            color_names = spec.get_vim_color_names()
            spec.update_color_names(color_names)
            if len(color_names) == 0:
                logging.debug(f"skip for no color files (.vim,.lua) - spec:{spec}")
                spec.remove()
                continue

    def _dedup(self) -> list[ColorSpec]:
        def greater_than(a: ColorSpec, b: ColorSpec) -> bool:
            if a.priority != b.priority:
                return a.priority > b.priority
            if a.github_stars != b.github_stars:
                return a.github_stars > b.github_stars
            assert isinstance(a.last_git_commit, datetime.datetime)
            assert isinstance(b.last_git_commit, datetime.datetime)
            return a.last_git_commit.timestamp() > b.last_git_commit.timestamp()

        specs_map: dict[str, ColorSpec] = dict()
        specs_set: set[ColorSpec] = set()

        for spec in ColorSpec.all():
            color_names = spec.get_vim_color_names()
            logging.debug(f"process dedup spec:{spec}, color names:{color_names}")
            for color in color_names:
                # detect duplicated color
                if color in specs_map:
                    old_spec = specs_map[color]
                    logging.debug(
                        f"detect duplicated color({color}), new:{spec}, old:{old_spec}"
                    )
                    # replace old repo if new repo has higher priority
                    if greater_than(spec, old_spec):
                        logging.debug(f"replace old repo({old_spec}) with new({spec})")
                        specs_map[color] = spec
                        specs_set.add(spec)
                        specs_set.remove(old_spec)
                else:
                    # add new color
                    specs_map[color] = spec
                    specs_set.add(spec)
        logging.debug(f"after dedup: {[str(s) for s in specs_set]}")
        return list(specs_set)

    def build(self) -> None:
        self._download()
        # dedup candidates
        deduped_specs = self._dedup()

        total = 0
        for spec in ColorSpec.all():
            if not spec in deduped_specs:
                logging.debug(f"remove for duplicate - repo:{spec}")
                spec.remove()
            else:
                total += 1

        md = MdUtils(file_name="COLORSCHEMES", title=f"ColorSchemes List ({total})")
        all_specs = sorted(ColorSpec.all(), key=lambda s: s.github_stars, reverse=True)
        for i, spec in enumerate(all_specs):
            logging.info(f"collect spec-{i}:{spec}")
            color_names = spec.get_vim_color_names()
            color_names = sorted(color_names)
            md.new_line(
                f"- {md.new_inline_link(link=spec.url, text=spec.handle)} (stars: {spec.github_stars}, last update: {date_tostring(spec.last_git_commit)})"
            )
            for cname in color_names:
                md.new_line(f"  - {cname}")
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
@click.option(
    "--skip-remove-db", "skip_remove_db_opt", is_flag=True, help="skip removing db.json"
)
def collect(debug_opt, no_headless_opt, skip_fetch_opt, skip_remove_db_opt):
    global WEBDRIVER_HEADLESS
    init_logging(logging.DEBUG if debug_opt else logging.INFO)
    logging.debug(f"debug_opt:{debug_opt}, no_headless_opt:{no_headless_opt}")
    if no_headless_opt:
        WEBDRIVER_HEADLESS = False
    if not skip_fetch_opt:
        vcs = VimColorSchemes()
        vcs.fetch()
        asn = AwesomeNeovimColorScheme()
        asn.fetch()
        filter_color_specs()
    builder = Builder(False if debug_opt else True)
    builder.build()


if __name__ == "__main__":
    collect()
