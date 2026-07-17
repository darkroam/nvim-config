#!/usr/bin/env python3
"""Validate the repository documentation contract without network access."""

from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path
from urllib.parse import unquote


ROOT = Path(__file__).resolve().parents[1]

REQUIRED_DOCS = (
    "AGENTS.md",
    "README.md",
    "docs/project/architecture.md",
    "docs/project/dependencies.md",
    "docs/project/plugins.md",
    "docs/project/maintenance-policy.md",
    "docs/planning/repository-audit.md",
    "docs/planning/change-template.md",
    "docs/planning/todo.md",
    "docs/planning/suspended.md",
    "docs/planning/history.md",
    "docs/user/usage-zh.md",
    "docs/user/keybindings-zh.md",
)

README_NAV_TARGETS = tuple(path for path in REQUIRED_DOCS if path != "README.md")

LINK_RE = re.compile(r"!?\[[^\]]*\]\(([^)]+)\)")
LAZY_PLUGIN_RE = re.compile(r'["\']([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)["\']')
COMMIT_RE = re.compile(r"^[0-9a-f]{40}$")
LAZY_COMMIT_RE = re.compile(r'^local lazy_commit = "([0-9a-f]{40})"$', re.MULTILINE)
LANGUAGE_ENTRY_RE = re.compile(r"^\s*([a-z][a-z0-9_]*)\s*=\s*(true|false)\s*,?\s*$")
ABSOLUTE_HOME_RE = re.compile(r"/(?:home|Users)/[^/\s`]+/")


def read(relative: str) -> str:
    return (ROOT / relative).read_text(encoding="utf-8-sig")


def git_lines(*args: str) -> list[str]:
    result = subprocess.run(
        ("git", *args),
        cwd=ROOT,
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or "git command failed")
    return [line for line in result.stdout.splitlines() if line]


def markdown_target(raw: str) -> str:
    target = raw.strip()
    if target.startswith("<") and ">" in target:
        return target[1 : target.index(">")]
    return target.split(maxsplit=1)[0]


def check_required(errors: list[str]) -> None:
    for relative in REQUIRED_DOCS:
        if not (ROOT / relative).is_file():
            errors.append(f"missing required document: {relative}")


def check_readme_navigation(errors: list[str]) -> None:
    readme = read("README.md")
    targets = {markdown_target(raw).split("#", 1)[0] for raw in LINK_RE.findall(readme)}
    for relative in README_NAV_TARGETS:
        if relative not in targets:
            errors.append(f"README navigation missing: {relative}")


def check_markdown_links(errors: list[str]) -> None:
    for relative in REQUIRED_DOCS:
        path = ROOT / relative
        if not path.is_file():
            continue
        for raw in LINK_RE.findall(read(relative)):
            target = markdown_target(raw)
            if not target or target.startswith(("#", "http://", "https://", "mailto:")):
                continue
            local = unquote(target.split("#", 1)[0].split("?", 1)[0])
            if not local:
                continue
            resolved = (path.parent / local).resolve()
            try:
                resolved.relative_to(ROOT)
            except ValueError:
                errors.append(f"link escapes repository: {relative} -> {target}")
                continue
            if not resolved.exists():
                errors.append(f"broken internal link: {relative} -> {target}")


def check_source_ownership(errors: list[str]) -> None:
    owner_text = "\n".join(
        read(relative)
        for relative in (
            "docs/project/architecture.md",
            "docs/project/plugins.md",
            "docs/user/usage-zh.md",
            "docs/user/keybindings-zh.md",
        )
    )
    for relative in git_lines(
        "ls-files", "--cached", "--others", "--exclude-standard", "--", "*.lua"
    ):
        if relative not in owner_text:
            errors.append(f"tracked Lua file has no documented owner: {relative}")


def check_lazy_inventory(errors: list[str]) -> None:
    spec_paths = sorted((ROOT / "lua/darkroam/plugins").glob("*.lua"))
    declarations = {
        plugin
        for path in spec_paths
        for plugin in LAZY_PLUGIN_RE.findall(path.read_text(encoding="utf-8-sig"))
    }
    inventory = read("docs/project/plugins.md")
    if not declarations:
        errors.append("no Lazy declarations parsed from lua/darkroam/plugins/*.lua")
        return
    declarations.add("folke/lazy.nvim")
    for plugin in sorted(declarations):
        if f"`{plugin}`" not in inventory:
            errors.append(f"Lazy declaration missing from plugin inventory: {plugin}")

    try:
        lock = json.loads(read("lazy-lock.json"))
    except (OSError, json.JSONDecodeError) as exc:
        errors.append(f"invalid lazy-lock.json: {exc}")
        return

    expected_keys = {plugin.rsplit("/", 1)[1] for plugin in declarations}
    for key in sorted(expected_keys - set(lock)):
        errors.append(f"Lazy declaration missing from lockfile: {key}")
    for key in sorted(set(lock) - expected_keys):
        errors.append(f"lockfile plugin has no Lazy declaration: {key}")
    for key, record in sorted(lock.items()):
        if not isinstance(record, dict):
            errors.append(f"invalid lockfile record for {key}")
            continue
        if not isinstance(record.get("branch"), str) or not record["branch"]:
            errors.append(f"lockfile plugin has no branch: {key}")
        commit = record.get("commit")
        if not isinstance(commit, str) or not COMMIT_RE.fullmatch(commit):
            errors.append(f"lockfile plugin has invalid commit: {key}")

    manager_match = LAZY_COMMIT_RE.search(read("lua/darkroam/lazy.lua"))
    if not manager_match:
        errors.append("lazy.nvim bootstrap commit is not pinned")
    elif lock.get("lazy.nvim", {}).get("commit") != manager_match.group(1):
        errors.append("lazy.nvim bootstrap commit differs from lazy-lock.json")


def check_language_tables(errors: list[str]) -> None:
    languages: dict[str, bool] = {}
    in_table = False
    for line in read("lua/darkroam/languages.lua").splitlines():
        if line.strip() == "M.syntax = {":
            in_table = True
            continue
        if in_table and line.strip() == "}":
            break
        if in_table:
            match = LANGUAGE_ENTRY_RE.match(line)
            if match:
                languages[match.group(1)] = match.group(2) == "true"

    if not languages:
        errors.append("no language switches parsed from lua/darkroam/languages.lua")
        return

    for relative in (
        "docs/project/architecture.md",
        "docs/project/dependencies.md",
        "docs/user/usage-zh.md",
    ):
        content = read(relative)
        for language, enabled in sorted(languages.items()):
            state = "启用" if enabled else "禁用"
            expected = f"| `{language}` | {state} |"
            if expected not in content:
                errors.append(
                    f"language table mismatch in {relative}: expected row prefix {expected}"
                )


def check_planning_roles(errors: list[str]) -> None:
    todo = read("docs/planning/todo.md")
    suspended = read("docs/planning/suspended.md")
    history = read("docs/planning/history.md")
    if re.search(r"^- \[[xX]\]", todo, re.MULTILINE):
        errors.append("todo.md contains completed checklist items")
    if re.search(r"^- \[[xX]\]", suspended, re.MULTILINE):
        errors.append("suspended.md contains completed checklist items")
    if re.search(r"^- \[ \]", history, re.MULTILINE):
        errors.append("history.md contains open checklist items")


def check_portability(errors: list[str]) -> None:
    for relative in REQUIRED_DOCS:
        path = ROOT / relative
        if path.is_file() and ABSOLUTE_HOME_RE.search(read(relative)):
            errors.append(f"machine-specific absolute home path in {relative}")


def main() -> int:
    errors: list[str] = []
    try:
        check_required(errors)
        if not errors:
            check_readme_navigation(errors)
            check_markdown_links(errors)
            check_source_ownership(errors)
            check_lazy_inventory(errors)
            check_language_tables(errors)
            check_planning_roles(errors)
            check_portability(errors)
    except (OSError, RuntimeError, UnicodeError) as exc:
        errors.append(f"checker failed: {exc}")

    if errors:
        print("documentation check failed:")
        for error in errors:
            print(f"- {error}")
        return 1

    print(
        "documentation check passed: required files, navigation, links, source "
        "ownership, Lazy inventory/lockfile, language tables, planning roles, portability"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
