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
    "docs/guide/installation.md",
    "docs/guide/usage.md",
    "docs/guide/languages.md",
    "docs/guide/keymaps.md",
    "docs/reference/architecture.md",
    "docs/reference/compatibility.md",
    "docs/reference/dependencies.md",
    "docs/reference/plugins.md",
    "docs/maintenance/workflow.md",
    "docs/maintenance/roadmap.md",
    "docs/maintenance/history.md",
)
REQUIRED_SUPPORT_FILES = (
    ".gitattributes",
    ".stylua.toml",
    "scripts/check-compat.py",
    "scripts/check-lua-format.py",
    "scripts/compat-smoke.lua",
)

README_NAV_TARGETS = tuple(path for path in REQUIRED_DOCS if path != "README.md")
OWNER_DOCS = (
    "docs/guide/languages.md",
    "docs/guide/keymaps.md",
    "docs/reference/architecture.md",
    "docs/reference/plugins.md",
)
LEGACY_DOC_PATHS = (
    "docs/project/",
    "docs/planning/",
    "docs/user/",
    "../project/",
    "../planning/",
    "../user/",
    "maintenance-policy.md",
    "change-template.md",
    "repository-audit.md",
    "usage-zh.md",
    "keybindings-zh.md",
    "suspended.md",
    "todo.md",
)

LINK_RE = re.compile(r"!?\[[^\]]*\]\(([^)]+)\)")
LAZY_PLUGIN_RE = re.compile(r'["\']([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)["\']')
COMMIT_RE = re.compile(r"^[0-9a-f]{40}$")
LAZY_COMMIT_RE = re.compile(r'^local lazy_commit = "([0-9a-f]{40})"$', re.MULTILINE)
LANGUAGE_ENTRY_RE = re.compile(r"^\s*([a-z][a-z0-9_]*)\s*=\s*(true|false)\s*,?\s*$")
COMPAT_ENTRY_RE = re.compile(
    r"^\s*([a-z][a-z0-9_]*)\s*=\s*\{\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\}\s*,?\s*$"
)
ABSOLUTE_HOME_RE = re.compile(r"/(?:home|Users)/[^/\s`]+/")
CORE_KEYMAP_RE = re.compile(r'^\s*keymap\([^,]+,\s*"([^"]+)"')
LSP_KEYMAP_RE = re.compile(r'^\s*map\("([^"]+)"')
VIM_KEYMAP_RE = re.compile(r'vim\.keymap\.set\(\s*"[^"]+"\s*,\s*"([^"]+)"')
VIM_TABLE_KEYMAP_RE = re.compile(r'vim\.keymap\.set\(\s*\{[^}]+\}\s*,\s*"([^"]+)"')
CMP_KEYMAP_RE = re.compile(r'^\s*\["([^"]+)"\]\s*=\s*cmp\.mapping')
TABLE_KEYMAP_RE = re.compile(r'^\s*\["([^"]+)"\]\s*=')
TELESCOPE_BARE_KEYMAP_RE = re.compile(r"^\s*(q|N|h)\s*=")
OPTION_KEYMAP_RE = re.compile(r'^\s*(?:line|above|eol|map)\s*=\s*"([^"]+)"')
LAZY_KEY_RE = re.compile(r'^\s*\{\s*"([^"]+)"')


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
    for relative in REQUIRED_SUPPORT_FILES:
        if not (ROOT / relative).is_file():
            errors.append(f"missing required support file: {relative}")


def check_support_ownership(errors: list[str]) -> None:
    owners = "\n".join(
        read(relative)
        for relative in (
            "docs/guide/installation.md",
            "docs/reference/architecture.md",
            "docs/reference/compatibility.md",
            "docs/maintenance/workflow.md",
        )
    )
    for relative in REQUIRED_SUPPORT_FILES:
        if f"`{relative}`" not in owners:
            errors.append(f"support file has no documented owner: {relative}")


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


def check_legacy_paths(errors: list[str]) -> None:
    for relative in REQUIRED_DOCS:
        content = read(relative)
        for legacy in LEGACY_DOC_PATHS:
            if legacy in content:
                errors.append(f"legacy documentation path in {relative}: {legacy}")


def check_source_ownership(errors: list[str]) -> None:
    owner_text = "\n".join(read(relative) for relative in OWNER_DOCS)
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
    inventory = read("docs/reference/plugins.md")
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


def parse_table_entries(relative: str, opening: str, pattern: re.Pattern[str]) -> dict[str, tuple[str, ...]]:
    entries: dict[str, tuple[str, ...]] = {}
    in_table = False
    for line in read(relative).splitlines():
        if line.strip() == opening:
            in_table = True
            continue
        if in_table and line.strip() == "}":
            break
        if in_table:
            match = pattern.match(line)
            if match:
                entries[match.group(1)] = match.groups()[1:]
    return entries


def check_language_table(errors: list[str]) -> None:
    entries = parse_table_entries(
        "lua/darkroam/languages.lua", "M.syntax = {", LANGUAGE_ENTRY_RE
    )
    if not entries:
        errors.append("no language switches parsed from lua/darkroam/languages.lua")
        return
    content = read("docs/guide/languages.md")
    for language, values in sorted(entries.items()):
        state = "启用" if values[0] == "true" else "禁用"
        expected = f"| `{language}` | {state} |"
        if expected not in content:
            errors.append(f"language table mismatch: expected row prefix {expected}")


def check_compatibility_table(errors: list[str]) -> None:
    entries = parse_table_entries(
        "lua/darkroam/compat.lua", "local minimum = {", COMPAT_ENTRY_RE
    )
    if not entries:
        errors.append("no compatibility gates parsed from lua/darkroam/compat.lua")
        return
    content = read("docs/reference/compatibility.md")
    for feature, version in sorted(entries.items()):
        expected = f"| `{feature}` | `{'.'.join(version)}` |"
        if expected not in content:
            errors.append(f"compatibility table mismatch: expected row prefix {expected}")


def extract_lazy_keys(path: Path) -> set[str]:
    keys: set[str] = set()
    in_keys = False
    depth = 0
    for line in path.read_text(encoding="utf-8-sig").splitlines():
        if not in_keys and re.search(r"\bkeys\s*=\s*\{", line):
            in_keys = True
            depth = line.count("{") - line.count("}")
            continue
        if not in_keys:
            continue
        match = LAZY_KEY_RE.match(line)
        if match:
            keys.add(match.group(1))
        depth += line.count("{") - line.count("}")
        if depth <= 0:
            in_keys = False
    return keys


def normalize_key(key: str) -> str:
    return key.replace("<leader>", ",")


def check_custom_keymaps(errors: list[str]) -> None:
    keys: set[str] = set()
    core = read("lua/darkroam/keymaps.lua")
    keys.update(CORE_KEYMAP_RE.findall(core))

    lsp = read("lua/darkroam/plugins/lsp.lua")
    keys.update(LSP_KEYMAP_RE.findall(lsp))

    for relative in (
        "lua/darkroam/plugins/ui.lua",
        "lua/darkroam/plugins/treesitter.lua",
    ):
        content = read(relative)
        keys.update(VIM_KEYMAP_RE.findall(content))
        keys.update(VIM_TABLE_KEYMAP_RE.findall(content))

    completion = read("lua/darkroam/plugins/completion.lua")
    keys.update(CMP_KEYMAP_RE.findall(completion))
    keys.update(OPTION_KEYMAP_RE.findall(read("lua/darkroam/plugins/editor.lua")))

    telescope = read("lua/darkroam/plugins/telescope.lua")
    keys.update(TABLE_KEYMAP_RE.findall(telescope))
    keys.update(TELESCOPE_BARE_KEYMAP_RE.findall(telescope))

    for path in sorted((ROOT / "lua/darkroam/plugins").glob("*.lua")):
        keys.update(extract_lazy_keys(path))

    documented = read("docs/guide/keymaps.md")
    for key in sorted(normalize_key(key) for key in keys):
        if f"`{key}`" not in documented:
            errors.append(f"custom keymap missing from guide: {key}")


def check_maintenance_roles(errors: list[str]) -> None:
    roadmap = read("docs/maintenance/roadmap.md")
    history = read("docs/maintenance/history.md")
    if re.search(r"^- \[[xX]\]", roadmap, re.MULTILINE):
        errors.append("roadmap.md contains completed checklist items")
    if re.search(r"^- \[ \]", history, re.MULTILINE):
        errors.append("history.md contains incomplete checklist items")
    if "## 暂缓" not in roadmap:
        errors.append("roadmap.md has no deferred-work section")


def check_portability(errors: list[str]) -> None:
    for relative in REQUIRED_DOCS:
        if ABSOLUTE_HOME_RE.search(read(relative)):
            errors.append(f"machine-specific absolute home path in {relative}")

    attributes = {
        line.strip()
        for line in read(".gitattributes").splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    }
    if "* text=auto eol=lf" not in attributes:
        errors.append(".gitattributes is missing the tracked-text LF contract")

    expected = {
        "lazy-lock.json: text: auto",
        "lazy-lock.json: eol: lf",
    }
    actual = set(git_lines("check-attr", "text", "eol", "--", "lazy-lock.json"))
    if actual != expected:
        errors.append(
            "lazy-lock.json has unexpected Git attributes: "
            + ", ".join(sorted(actual))
        )


def main() -> int:
    errors: list[str] = []
    try:
        check_required(errors)
        if not errors:
            check_readme_navigation(errors)
            check_markdown_links(errors)
            check_legacy_paths(errors)
            check_support_ownership(errors)
            check_source_ownership(errors)
            check_lazy_inventory(errors)
            check_language_table(errors)
            check_compatibility_table(errors)
            check_custom_keymaps(errors)
            check_maintenance_roles(errors)
            check_portability(errors)
    except (OSError, RuntimeError, UnicodeError) as exc:
        errors.append(f"checker failed: {exc}")

    if errors:
        print("documentation check failed:")
        for error in errors:
            print(f"- {error}")
        return 1

    print(
        "documentation check passed: structure, navigation, links, source ownership, "
        "support scripts, Lazy inventory/lockfile, compatibility gates, language state, "
        "custom keymaps, maintenance roles, portability, and LF attributes"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
