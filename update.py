#!/usr/bin/env python3

import logging
import sys
import typing

import click


def init_logging(log_level: typing.Optional[int]) -> None:
    assert isinstance(log_level, int) or log_level is None
    log_level = logging.WARNING if log_level is None else log_level
    logging.basicConfig(
        format="%(asctime)s %(levelname)s [%(filename)s:%(lineno)d]%(funcName)s - %(message)s",
        level=log_level,
        handlers=[
            logging.StreamHandler(),
            logging.FileHandler(f"{sys.argv[0]}.log", mode="w"),
        ],
    )


@click.command()
@click.option(
    "-d",
    "--debug",
    "debug_opt",
    is_flag=True,
    help="enable debug",
)
def update(debug_opt):
    init_logging(logging.DEBUG if debug_opt else logging.INFO)
    logging.debug(f"debug_opt:{debug_opt}")
    logging.info(f"update")


if __name__ == "__main__":
    update()
