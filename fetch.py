#!/usr/bin/env python3

import datetime
import logging
from typing import Iterable, Optional

from selenium.webdriver import Chrome, ChromeOptions, DesiredCapabilities
from selenium.webdriver.common.by import By
from selenium.webdriver.remote.webelement import WebElement
from selenium.webdriver.support import expected_conditions
from selenium.webdriver.support.wait import WebDriverWait
from util import (
    HEADLESS,
    LASTCOMMIT,
    STARS,
    TIMEOUT,
    CliOptions,
    RepoObject,
    blacklist,
    init_logging,
    parse_number,
    parse_options,
)

OPTIONS = Optional[CliOptions]


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


class Vimcolorscheme:
    def pages(self) -> Iterable[str]:
        i = 0
        while True:
            if i == 0:
                yield "https://vimcolorschemes.com/top"
            else:
                yield f"https://vimcolorschemes.com/top/page/{i+1}"
            i += 1

    def parse_repo(self, element: WebElement) -> RepoObject:
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
        return RepoObject(url, stars, last_update, source="vimcolorschemes.com/top")

    def fetch(self) -> None:
        with make_driver() as driver:
            for page_url in self.pages():
                driver.get(page_url)
                any_valid_stars = False
                for element in find_elements(driver, "//article[@class='card']"):
                    repo = self.parse_repo(element)
                    logging.info(f"vsc repo:{repo}")
                    if blacklist(repo):
                        logging.info(f"asc skip for blacklist - repo:{repo}")
                        continue
                    if repo.stars < STARS:
                        logging.info(f"vsc skip for stars - repo:{repo}")
                        continue
                    assert isinstance(repo.last_update, datetime.datetime)
                    if (
                        repo.last_update.timestamp() + LASTCOMMIT
                        < datetime.datetime.now().timestamp()
                    ):
                        logging.info(f"vsc skip for last_update - repo:{repo}")
                        continue
                    logging.info(f"vsc get - repo:{repo}")
                    repo.add()
                    any_valid_stars = True
                if not any_valid_stars:
                    logging.info(f"vsc no valid stars, exit")
                    break


class AwesomeNeovim:
    def parse_repo(self, element: WebElement) -> RepoObject:
        a = element.find_element(By.XPATH, "./a").text
        a_splits = a.split("(")
        repo = a_splits[0]
        stars = parse_number(a_splits[1])
        return RepoObject(
            repo, stars, None, priority=100, source="awesome-neovim#colorscheme"
        )

    def parse_color(self, driver: Chrome, tag_id: str) -> list[RepoObject]:
        repositories = []
        colors_group = find_element(
            driver,
            f"//main[@class='markdown-body']/h4[@id='{tag_id}']/following-sibling::ul",
        )
        for e in colors_group.find_elements(By.XPATH, "./li"):
            repo = self.parse_repo(e)
            logging.info(f"acs repo:{repo}")
            repositories.append(repo)
        return repositories

    def fetch(self) -> None:
        with make_driver() as driver:
            driver.get(
                "https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme"
            )
            treesitter_repos = self.parse_color(
                driver, "tree-sitter-supported-colorscheme"
            )
            lua_repos = self.parse_color(driver, "lua-colorscheme")
            repos = treesitter_repos + lua_repos
            for repo in repos:
                if blacklist(repo):
                    logging.info(f"asc skip for blacklist - repo:{repo}")
                    continue
                if repo.stars < STARS:
                    logging.info(f"asc skip for stars - repo:{repo}")
                    continue
                logging.info(f"acs get - repo:{repo}")
                repo.add()


# main
OPTIONS = parse_options()
init_logging(OPTIONS)
RepoObject.reset()
AwesomeNeovim().fetch()
Vimcolorscheme().fetch()
