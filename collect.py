#!/usr/bin/env python3

import datetime
import logging
import math
import os
import pathlib
import shutil
import subprocess
import sys
import time
import typing
from dataclasses import dataclass

import click
import luadata
from mdutils.mdutils import MdUtils
from selenium.webdriver import Chrome, ChromeOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.remote.webelement import WebElement
from selenium.webdriver.support import expected_conditions
from selenium.webdriver.support.wait import WebDriverWait
from tinydb import Query, TinyDB

# constants {

# github
GITHUB_STARS = 500
LAST_GIT_COMMIT = 10 * 365 * 24 * 3600  # 10 years * 365 days * 24 hours * 3600 seconds
BLACKLIST = [
    "rafi/awesome-vim-colorschemes",
    "mini.nvim#minischeme",
    "mini.nvim#colorschemes",
    "text-to-colorscheme",
    "flazz/vim-colorschemes",
]


# chrome webdriver
WEBDRIVER_HEADLESS = True
WEBDRIVER_TIMEOUT = 30

# git object
DATETIME_FORMAT = "%Y-%m-%dT%H:%M:%S"
DATE_FORMAT = "%Y-%m-%d"
CANDIDATE_DIR = "candidate"

# data
DB = TinyDB("db.json")

# constants }

# utils {


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


def datetime_fromstring(
    value: typing.Optional[str],
) -> typing.Optional[datetime.datetime]:
    return (
        datetime.datetime.strptime(value, DATETIME_FORMAT)
        if isinstance(value, str) and len(value.strip()) > 0
        else None
    )


def date_tostring(value: typing.Optional[datetime.datetime]) -> typing.Optional[str]:
    return value.strftime(DATE_FORMAT) if isinstance(value, datetime.datetime) else None


def date_fromstring(
    value: typing.Optional[str],
) -> typing.Optional[datetime.datetime]:
    return (
        datetime.datetime.strptime(value, DATE_FORMAT)
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
    # logging.debug(f"repo ({git_path}) last git commit time:{dt}")
    os.chdir(saved_cwd)
    return dt


# utils }


@dataclass
class ColorSpecConfig:
    git_branch: typing.Optional[str] = None

    def __str__(self) -> str:
        return f"<ColorSpecConfig git_branch:{self.git_branch if isinstance(self.git_branch, str) else 'None'}>"


REPO_META_CONFIG = {
    "lifepillar/vim-solarized8": ColorSpecConfig(git_branch="neovim"),
    "lifepillar/vim-gruvbox8": ColorSpecConfig(git_branch="neovim"),
}


class ColorSpec:
    HANDLE = "handle"
    URL = "url"
    GITHUB_STARS = "github_stars"
    PRIORITY = "priority"
    SOURCE = "source"
    LAST_GIT_COMMIT = "last_git_commit"
    GIT_PATH = "git_path"
    GIT_BRANCH = "git_branch"
    COLOR_NAMES = "color_names"
    SCORE = "score"

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
        return handle.lower()

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
        count = DB.search(q.handle == self.handle)
        obj = {
            ColorSpec.HANDLE: self.handle,
            ColorSpec.URL: self.url,
            ColorSpec.GITHUB_STARS: self.github_stars,
            ColorSpec.LAST_GIT_COMMIT: date_tostring(self.last_git_commit),
            ColorSpec.PRIORITY: self.priority,
            ColorSpec.SOURCE: self.source,
            ColorSpec.GIT_PATH: self.git_path,
            ColorSpec.GIT_BRANCH: self.git_branch,
            ColorSpec.COLOR_NAMES: self.color_names,
        }
        if len(count) <= 0:
            DB.insert(obj)
            # logging.debug(f"add new repo: {self}")
        else:
            DB.update(obj, q.handle == self.handle)
            # logging.debug(f"add(update) existed repo: {self}")

    def update_last_git_commit(self, last_git_commit: datetime.datetime) -> None:
        q = Query()
        records = DB.search(q.handle == self.handle)
        assert len(records) == 1
        assert isinstance(last_git_commit, datetime.datetime)
        self.last_git_commit = last_git_commit
        DB.update(
            {
                ColorSpec.LAST_GIT_COMMIT: date_tostring(self.last_git_commit),
            },
            q.handle == self.handle,
        )

    def update_color_names(self, color_names: list[str]) -> None:
        q = Query()
        records = DB.search(q.handle == self.handle)
        assert len(records) == 1
        assert isinstance(color_names, list)
        self.color_names = color_names
        DB.update(
            {
                ColorSpec.COLOR_NAMES: self.color_names,
            },
            q.handle == self.handle,
        )

    def remove(self) -> None:
        q = Query()
        DB.remove(q.handle == self.handle)

    @staticmethod
    def all() -> list:
        try:
            records = DB.all()
            # for i, r in enumerate(records):
            #     logging.debug(f"all records-{i}:{r}")
            return [
                ColorSpec(
                    handle=r[ColorSpec.HANDLE],
                    github_stars=r[ColorSpec.GITHUB_STARS],
                    last_git_commit=date_fromstring(r[ColorSpec.LAST_GIT_COMMIT]),
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
            # logging.debug(
            #     f"{candidate_dir} exist: {candidate_dir.exists()}, isdir: {candidate_dir.is_dir()}"
            # )
            if candidate_dir.exists() and candidate_dir.is_dir():
                # logging.debug(f"{candidate_dir} already exist, skip...")
                pass
            else:
                # logging.debug(clone_cmd)
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
        # logging.debug(f"retrieve colors from spec ({self}): {colors}")
        return colors


def find_element(driver: Chrome, xpath: str) -> WebElement:
    WebDriverWait(driver, WEBDRIVER_TIMEOUT).until(
        expected_conditions.presence_of_all_elements_located((By.XPATH, xpath))
    )
    time.sleep(5)
    return driver.find_element(By.XPATH, xpath)


def find_elements(driver: Chrome, xpath: str) -> list[WebElement]:
    WebDriverWait(driver, WEBDRIVER_TIMEOUT).until(
        expected_conditions.presence_of_all_elements_located((By.XPATH, xpath))
    )
    time.sleep(5)
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
        self.counter = 0

    def _pages(self) -> typing.Iterable[str]:
        i = 0
        while True:
            if i == 0:
                yield "https://vimcolorschemes.com/i/top"
            else:
                yield f"https://vimcolorschemes.com/i/top/p.{i+1}"
            i += 1

    def _parse_spec(
        self, element: WebElement, page_url: str
    ) -> typing.Optional[ColorSpec]:
        # logging.debug(f"parsing (vsc) spec element:{element}, page url:{page_url}")
        try:
            a_elem = element.find_element(
                By.XPATH, "./a[starts-with(@class,'repositoryCard')]"
            )
            url: str = a_elem.get_attribute("href")  # type: ignore
            if url.endswith("/"):
                url = url[:-1]
            # logging.debug(f"parsing (vsc) spec handle_elem:{url}")
            handle = "/".join(url.split("/")[-2:])
            # logging.debug(f"parsing (vsc) spec handle:{handle}")
            github_stars = int(
                a_elem.find_element(
                    By.XPATH,
                    "./div[starts-with(@class,'repositoryTitle')]//div[starts-with(@class,'repositoryTitle_stats')]//p[starts-with(@class,'repositoryTitle_stat')]//strong",
                ).text
            )
            # logging.debug(f"parsing (vsc) spec github_stars:{github_stars}")
            return ColorSpec(
                handle,
                github_stars,
                last_git_commit=None,
                priority=0,
                source="vsc",
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
                for element in find_elements(driver, "//article"):
                    spec = self._parse_spec(element, page_url)
                    self.counter = self.counter + 1
                    # logging.debug(f"vsc repo-{self.counter}:{spec}")
                    if spec is None:
                        logging.info(
                            f"skip for parsing failure - (vcs) spec-{self.counter}:{spec}"
                        )
                        continue
                    if len(spec.handle.split("/")) != 2:
                        logging.info(
                            f"skip for invalid handle - (vcs) spec-{self.counter}:{spec}"
                        )
                        continue
                    if spec.github_stars < GITHUB_STARS:
                        logging.info(
                            f"skip for lower stars - (vcs) spec-{self.counter}:{spec}"
                        )
                        continue
                    logging.info(f"fetch (vcs) spec-{self.counter}:{spec}")
                    need_more_scan = True
                    spec.save()
                if not need_more_scan:
                    logging.info("no more enough github stars, exit...")
                    break


# https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/#colorscheme
class AwesomeNeovimColorScheme:
    def __init__(self) -> None:
        self.counter = 0

    def _parse_spec(
        self, element: WebElement, page_url: str
    ) -> typing.Optional[ColorSpec]:
        # logging.debug(f"parsing (asm) spec element:{element}, page url:{page_url}")
        try:
            a = element.find_element(By.XPATH, "./a").text
            a_splits = a.split("(")
            # logging.debug(f"parse asm element.a:{a}, a_splits:{a_splits}")
            handle = a_splits[0]
            github_stars = parse_number(a_splits[1]) if len(a_splits) > 1 else 0
            return ColorSpec(
                handle,
                github_stars,
                last_git_commit=None,
                priority=100,
                source="asm",
            )
        except Exception as e:
            logging.exception(f"failed to fetch asm element: {element}", e)
            return None

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
            self.counter = self.counter + 1
            # logging.debug(f"asm repo-{self.counter}:{spec}")
            if spec is None:
                logging.info(
                    f"skip for parsing failure - (asm) spec-{self.counter}:{spec}"
                )
                continue
            if len(spec.handle.split("/")) != 2:
                logging.info(
                    f"skip for invalid handle - (asm) spec-{self.counter}:{spec}"
                )
                continue
            if spec.github_stars < GITHUB_STARS:
                logging.info(f"skip for lower stars - (asm) spec-{self.counter}:{spec}")
                continue
            logging.info(f"fetch (asm) repo-{self.counter}:{spec}")
            repos.append(spec)
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
        return any([True for b in BLACKLIST if sp.url.lower().find(b.lower()) >= 0])

    for spec in ColorSpec.all():
        # logging.debug(f"process filtering on spec:{spec}")
        if spec.github_stars < GITHUB_STARS:
            logging.info(f"skip for lower stars - spec:{spec}")
            spec.remove()
            continue
        if blacklist(spec):
            logging.info(f"skip for blacklist - spec:{spec}")
            spec.remove()
            continue


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
            # logging.debug(f"download spec:{spec}")
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
                logging.info(f"skip for too old git commit - spec:{spec}")
                spec.remove()
                continue
            color_names = spec.get_vim_color_names()
            spec.update_color_names(color_names)
            if len(color_names) == 0:
                logging.info(f"skip for no color files (.vim,.lua) - spec:{spec}")
                spec.remove()
                continue

    def _dedup(self) -> list[ColorSpec]:
        def get_score(spec: ColorSpec, allspecs: list[ColorSpec]) -> int:
            score = 0
            if spec.priority > 0:
                score += 10
            max_github_stars = max([s.github_stars for s in allspecs])
            score += math.ceil(spec.github_stars / max_github_stars * 80)
            assert isinstance(spec.last_git_commit, datetime.datetime)
            newest_git_commit = max([s.last_git_commit.timestamp() for s in allspecs])  # type: ignore
            if spec.last_git_commit.timestamp() >= newest_git_commit:
                score += 10
            return score

        def greater_than(a: ColorSpec, b: ColorSpec) -> bool:
            a_score = 0
            b_score = 0
            if a.priority > 0:
                a_score += 10
            if b.priority > 0:
                b_score += 10
            max_github_stars = max(a.github_stars, b.github_stars)
            a_score += math.ceil(a.github_stars / max_github_stars * 80)
            b_score += math.ceil(b.github_stars / max_github_stars * 80)
            assert isinstance(a.last_git_commit, datetime.datetime)
            assert isinstance(b.last_git_commit, datetime.datetime)
            newest_git_commit = max(
                a.last_git_commit.timestamp(), b.last_git_commit.timestamp()
            )
            if a.last_git_commit.timestamp() >= newest_git_commit:
                a_score += 10
            if b.last_git_commit.timestamp() >= newest_git_commit:
                b_score += 10
            return a_score >= b_score

        specs_map: dict[str, ColorSpec] = dict()
        specs_set: set[ColorSpec] = set()

        for spec in ColorSpec.all():
            color_names = spec.get_vim_color_names()
            logging.debug(f"process dedup spec:{spec}, color names:{color_names}")
            found_duplicate = False
            drop_target = None
            replace_target = None
            for color in color_names:
                # detect duplicated color
                if color in specs_map:
                    old_spec = specs_map[color]
                    logging.info(
                        f"detect duplicated color:{color}, new spec:{spec}, old spec:{old_spec}"
                    )
                    # replace old repo if new repo has higher priority
                    spec_score = get_score(spec, [spec, old_spec])
                    old_spec_score = get_score(old_spec, [spec, old_spec])
                    logging.info(
                        f"new spec({spec_score}):{spec}, old spec({old_spec_score}):{old_spec}"
                    )
                    if spec_score >= old_spec_score:
                        logging.info(
                            f"replace old spec({old_spec}) with new spec({spec})"
                        )
                        specs_map[color] = spec
                        specs_set.add(spec)
                        specs_set.remove(old_spec)

                        replace_target = spec
                        drop_target = old_spec
                    else:
                        logging.info(
                            f"keep old spec({old_spec}), drop new spec({spec})"
                        )
                        replace_target = old_spec
                        drop_target = spec

                    found_duplicate = True
                    break
                else:
                    # add new color
                    logging.info(f"add new spec:{spec}, color names:{color_names}")
                    specs_map[color] = spec
                    specs_set.add(spec)

            logging.info(
                f"deduped for spec:{spec}, found_duplicate:{found_duplicate}, drop_target:{drop_target}, replace_target:{replace_target}"
            )
            if found_duplicate and drop_target and replace_target:
                logging.info(
                    f"deduped found for drop_target:{drop_target}, replace_target:{replace_target}"
                )
                if drop_target in specs_set:
                    logging.info(f"remove drop_target:{spec} from specs_set")
                    specs_set.remove(drop_target)
                if replace_target not in specs_set:
                    logging.info(f"add replace_target:{spec} to specs_set")
                    specs_set.add(replace_target)
                for color in drop_target.get_vim_color_names():
                    logging.info(f"pop drop_target color:{color} from specs_map")
                    if color in specs_map:
                        specs_map.pop(color)
                for color in replace_target.get_vim_color_names():
                    logging.info(f"update replace_target with color:{color}")
                    specs_map[color] = replace_target

        logging.debug(f"after dedup: {[str(s) for s in specs_set]}")
        return list(specs_set)

    def _build_lua_specs(self, all_specs: list[ColorSpec]) -> None:
        lspecs = {}
        lspecs_by_colorname = {}
        lspecs_by_gitpath = {}
        lcolornames = []

        for i, spec in enumerate(all_specs):
            logging.info(f"dump lua specs for spec-{i}:{spec}")
            lcolors = sorted(spec.get_vim_color_names())
            lobj = {
                ColorSpec.HANDLE: spec.handle,
                ColorSpec.URL: spec.url,
                ColorSpec.GITHUB_STARS: spec.github_stars,
                ColorSpec.LAST_GIT_COMMIT: date_tostring(spec.last_git_commit),
                ColorSpec.PRIORITY: spec.priority,
                ColorSpec.SOURCE: spec.source,
                ColorSpec.GIT_PATH: spec.git_path,
                ColorSpec.GIT_BRANCH: spec.git_branch,
                ColorSpec.COLOR_NAMES: lcolors,
            }
            lspecs[spec.handle] = lobj
            lspecs_by_gitpath[spec.git_path] = lobj
            for j, color in enumerate(lcolors):
                lcolornames.append(color)
                lspecs_by_colorname[color] = lobj

        lcolornames = sorted(lcolornames, key=lambda c: c.lower())
        luadata.write(
            "lua/colorbox/meta/specs.lua",
            lspecs,
            encoding="utf-8",
            indent="  ",
            prefix="return ",
        )
        luadata.write(
            "lua/colorbox/meta/specs_by_colorname.lua",
            lspecs_by_colorname,
            encoding="utf-8",
            indent="  ",
            prefix="return ",
        )
        luadata.write(
            "lua/colorbox/meta/specs_by_gitpath.lua",
            lspecs_by_gitpath,
            encoding="utf-8",
            indent="  ",
            prefix="return ",
        )
        luadata.write(
            "lua/colorbox/meta/colornames.lua",
            lcolornames,
            encoding="utf-8",
            indent="  ",
            prefix="return ",
        )

    def _build_md_list(self, all_specs: list[ColorSpec]) -> None:
        total = len(all_specs)
        md = MdUtils(file_name="COLORSCHEMES", title=f"ColorSchemes List ({total})")
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

    def build(self) -> None:
        self._download()
        # dedup candidates
        deduped_specs = self._dedup()

        for spec in ColorSpec.all():
            if spec not in deduped_specs:
                logging.debug(f"remove for duplicate - repo:{spec}")
                spec.remove()

        all_specs = sorted(ColorSpec.all(), key=lambda s: s.github_stars, reverse=True)
        self._build_md_list(all_specs)
        self._build_lua_specs(all_specs)


@click.command()
@click.option(
    "-d",
    "--debug",
    "debug_opt",
    is_flag=True,
    help="enable debug",
)
@click.option("--no-headless", "no_headless_opt", is_flag=True, help="disable headless")
@click.option("--skip-fetch", "skip_fetch_opt", is_flag=True, help="skip fetch")
@click.option("--skip-clone", "skip_clone_opt", is_flag=True, help="skip clone")
def collect(debug_opt, no_headless_opt, skip_fetch_opt, skip_clone_opt):
    # Initialize
    global WEBDRIVER_HEADLESS
    init_logging(logging.DEBUG if debug_opt else logging.INFO)
    logging.debug(
        f"debug_opt:{debug_opt}, no_headless_opt:{no_headless_opt}, skip_fetch_opt:{skip_fetch_opt}, skip_clone_opt:{skip_clone_opt}"
    )
    if no_headless_opt:
        WEBDRIVER_HEADLESS = False

    # Before updating data
    before = len(DB.all())
    logging.info(f"Before updating, DB count:{before}")
    with open("collect-before.log", "w") as result:
        result.write(f"{before}")

    # Collect data
    if not skip_fetch_opt:
        DB.truncate()
        vcs = VimColorSchemes()
        vcs.fetch()
        asm = AwesomeNeovimColorScheme()
        asm.fetch()
        filter_color_specs()
    clean_old_clones = True
    if debug_opt:
        clean_old_clones = False
    if skip_clone_opt:
        clean_old_clones = False

    # Build new data source
    builder = Builder(clean_old_clones)
    builder.build()

    # After updating data
    after = len(DB.all())
    logging.info(f"After updating, DB count:{after}")
    with open("collect-after.log", "w") as result:
        result.write(f"{after}")


if __name__ == "__main__":
    collect()
