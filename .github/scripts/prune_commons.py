#!/usr/bin/env python3
"""Prune unused files and functions from the vendored `lua/colorbox/commons`.

`commons.nvim` is copied into `lua/colorbox/commons` by
`.github/workflows/bump-commons.yml`. colorbox.nvim only uses a small part of
it, so this script strips everything that is not used by the plugin. It runs
after every bump to keep the vendored copy identical to the committed one.

Every removal is asserted: a freshly bumped copy is pruned strictly, so if
upstream renames or drops something the script fails loudly instead of
silently leaving dead code behind. Running it again on an already pruned tree
is a no-op, which keeps local re-runs cheap.
"""

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
COMMONS = ROOT / "lua" / "colorbox" / "commons"

REMOVE_FILES = [
    "path.lua",
    "platform.lua",
    "async/misc.lua",
]

# Functions (and their doc comments) to delete, keyed by file.
REMOVE_FUNCS = {
    "async.lua": [
        "is_closing",
        "pcall",
        "sleep",
        "timeout",
    ],
    "async/_util.lua": ["gc_fun"],
    "fio.lua": ["asyncreadfile", "writefile"],
    "num.lua": ["min", "max", "lt", "le", "ge"],
    "str.lua": [
        "find",
        "rfind",
        "endswith",
        "replace",
        "isspace",
        "isalnum",
        "isdigit",
        "isxdigit",
        "isalpha",
        "islower",
        "isupper",
        "setchar",
        "tochars",
    ],
    "tbl.lua": [
        "tbl_not_empty",
        "tbl_contains",
        "list_empty",
        "list_not_empty",
        "list_contains",
    ],
}

# Whole `do --- M.foo() ... end` blocks to delete, keyed by file.
REMOVE_BLOCKS = {
    "async.lua": [
        "do --- M.iter(), M.await_all(), M.await_any()",
        "do --- M.semaphore()",
        "do --- M._inspect_tree()",
    ],
}

# Module-level `local X = { ... }` tables that are no longer referenced.
REMOVE_LOCAL_TABLES = {
    "log.lua": ["LogHighlights"],
}

# Entries of the exported table to delete, keyed by file.
REMOVE_TABLE_ENTRIES = {
    "log.lua": ["log", "throw"],
}

# Contiguous doc blocks advertising removed features.
REMOVE_DOC_BLOCKS = {
    "async.lua": [
        [
            "--- - **Concurrency Utilities:** `await_all`, `await_any`, and `iter` provide",
            "---   powerful tools for managing groups of tasks.",
            "---",
            "--- - **Synchronization Primitives:** `event`, `queue`, and `semaphore` are",
            "---   available for more complex coordination patterns.",
            "---",
        ],
    ],
}

# Doc lines that mention a removed function, rewritten instead of deleted.
REPLACE_LINES = {
    "async.lua": [
        (
            "--- The source line that created this task, used for inspect().",
            "--- The source line that created this task.",
        ),
    ],
}

FUNC_START = re.compile(
    r"^(?:M\.(?P<assign>\w+) = function|function M\.(?P<decl>\w+)\(|local function (?P<local>\w+)\()"
)
LOCAL_DECL = re.compile(r"^local (?P<name>\w+) = ")


def fail(msg: str) -> None:
    sys.exit(f"prune_commons: {msg}")


def pruned_files() -> list[str]:
    """Files that have at least one removal configured."""
    return sorted(
        set(REMOVE_FUNCS)
        | set(REMOVE_BLOCKS)
        | set(REMOVE_TABLE_ENTRIES)
        | set(REMOVE_LOCAL_TABLES)
        | set(REMOVE_DOC_BLOCKS)
        | set(REPLACE_LINES)
    )


def has_target(lines: list[str], rel_path: str) -> bool:
    """True if `lines` still contains anything configured for removal."""
    for header in REMOVE_BLOCKS.get(rel_path, []):
        if header in lines:
            return True
    for name in REMOVE_LOCAL_TABLES.get(rel_path, []):
        if f"local {name} = {{" in lines:
            return True
    for name in REMOVE_FUNCS.get(rel_path, []):
        for line in lines:
            m = FUNC_START.match(line)
            if m and name in (m.group("assign"), m.group("decl"), m.group("local")):
                return True
    for entry in REMOVE_TABLE_ENTRIES.get(rel_path, []):
        pattern = re.compile(rf"^\s*{re.escape(entry)} = {re.escape(entry)},$")
        if any(pattern.match(line) for line in lines):
            return True
    for block in REMOVE_DOC_BLOCKS.get(rel_path, []):
        size = len(block)
        if any(lines[start : start + size] == block for start in range(len(lines) - size + 1)):
            return True
    for old, _ in REPLACE_LINES.get(rel_path, []):
        if old in lines:
            return True
    return False


def is_pruned() -> bool:
    """True when every configured removal has already been applied."""
    if any((COMMONS / rel_path).exists() for rel_path in REMOVE_FILES):
        return False
    for rel_path in pruned_files():
        path = COMMONS / rel_path
        if path.is_file() and has_target(path.read_text().split("\n"), rel_path):
            return False
    return True


def find_func_range(lines: list[str], name: str) -> tuple[int, int]:
    """Return the [start, end] line range of a top-level function definition."""
    starts = []
    for idx, line in enumerate(lines):
        m = FUNC_START.match(line)
        if m and name in (m.group("assign"), m.group("decl"), m.group("local")):
            starts.append(idx)
    if not starts:
        fail(f"function '{name}' not found")
    if len(starts) > 1:
        fail(f"function '{name}' defined {len(starts)} times")

    start = starts[0]
    # Walk up over the contiguous doc comment block.
    while start > 0 and lines[start - 1].startswith("---"):
        start -= 1

    for end in range(starts[0], len(lines)):
        if lines[end] == "end":
            return start, end
    fail(f"no closing 'end' for function '{name}'")


def find_block_range(lines: list[str], header: str) -> tuple[int, int]:
    """Return the [start, end] line range of a top-level `do ... end` block."""
    starts = [idx for idx, line in enumerate(lines) if line == header]
    if not starts:
        fail(f"block '{header}' not found")
    if len(starts) > 1:
        fail(f"block '{header}' found {len(starts)} times")

    for end in range(starts[0], len(lines)):
        if lines[end] == "end":
            return starts[0], end
    fail(f"no closing 'end' for block '{header}'")


def find_local_table_range(lines: list[str], name: str) -> tuple[int, int]:
    """Return the [start, end] line range of a `local name = { ... }` table."""
    header = f"local {name} = {{"
    starts = [idx for idx, line in enumerate(lines) if line == header]
    if not starts:
        fail(f"local table '{name}' not found")
    if len(starts) > 1:
        fail(f"local table '{name}' found {len(starts)} times")

    for end in range(starts[0], len(lines)):
        if lines[end] == "}":
            return starts[0], end
    fail(f"no closing '}}' for local table '{name}'")


def drop_ranges(lines: list[str], ranges: list[tuple[int, int]]) -> list[str]:
    drop: set[int] = set()
    for start, end in ranges:
        drop.update(range(start, end + 1))
    return [line for idx, line in enumerate(lines) if idx not in drop]


def drop_unused_locals(lines: list[str]) -> list[str]:
    """Remove `local x = ...` declarations whose name is not referenced elsewhere."""
    keep = []
    for idx, line in enumerate(lines):
        m = LOCAL_DECL.match(line)
        if m and not line.rstrip().endswith(("{", "(", "[[")):
            name = m.group("name")
            pattern = re.compile(rf"\b{re.escape(name)}\b")
            others = [other for j, other in enumerate(lines) if j != idx and pattern.search(other)]
            # `M` is the module table, never drop it.
            if name != "M" and not others:
                continue
        keep.append(line)
    return keep


def drop_doc_block(lines: list[str], block: list[str]) -> list[str]:
    """Remove an exact contiguous block of doc lines."""
    size = len(block)
    for start in range(len(lines) - size + 1):
        if lines[start : start + size] == block:
            return lines[:start] + lines[start + size :]
    fail(f"doc block {block[0]!r} not found")


def apply_replacements(lines: list[str], rel_path: str) -> list[str]:
    """Rewrite doc lines that still mention a removed function."""
    for old, new in REPLACE_LINES.get(rel_path, []):
        hits = [idx for idx, line in enumerate(lines) if line == old]
        if not hits:
            fail(f"line {old!r} not found in '{rel_path}'")
        for idx in hits:
            lines[idx] = new
    return lines


def collapse_blank_lines(lines: list[str]) -> list[str]:
    """Collapse runs of blank lines left behind by the removals."""
    out: list[str] = []
    for line in lines:
        if line == "" and out and out[-1] == "":
            continue
        out.append(line)
    while out and out[-1] == "":
        out.pop()
    return out


def prune_file(rel_path: str) -> None:
    path = COMMONS / rel_path
    if not path.is_file():
        fail(f"missing file '{rel_path}'")

    lines = path.read_text().split("\n")

    ranges = [find_block_range(lines, h) for h in REMOVE_BLOCKS.get(rel_path, [])]
    ranges += [find_local_table_range(lines, n) for n in REMOVE_LOCAL_TABLES.get(rel_path, [])]
    ranges += [find_func_range(lines, n) for n in REMOVE_FUNCS.get(rel_path, [])]
    lines = drop_ranges(lines, ranges)

    for entry in REMOVE_TABLE_ENTRIES.get(rel_path, []):
        pattern = re.compile(rf"^\s*{re.escape(entry)} = {re.escape(entry)},$")
        kept = [line for line in lines if not pattern.match(line)]
        if len(kept) == len(lines):
            fail(f"table entry '{entry}' not found in '{rel_path}'")
        lines = kept

    for doc_block in REMOVE_DOC_BLOCKS.get(rel_path, []):
        lines = drop_doc_block(lines, doc_block)

    lines = apply_replacements(lines, rel_path)
    lines = collapse_blank_lines(drop_unused_locals(lines))
    path.write_text("\n".join(lines) + "\n")


def main() -> None:
    if is_pruned():
        print("prune_commons: already pruned, nothing to do")
        return

    for rel_path in REMOVE_FILES:
        path = COMMONS / rel_path
        if not path.is_file():
            fail(f"missing file '{rel_path}'")
        path.unlink()

    for rel_path in pruned_files():
        prune_file(rel_path)

    print("prune_commons: done")


if __name__ == "__main__":
    main()
