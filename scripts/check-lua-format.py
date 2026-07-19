#!/usr/bin/env python3
"""Validate encoding and StyLua formatting for tracked Lua files."""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CONFIG = ROOT / ".stylua.toml"
UTF8_BOM = b"\xef\xbb\xbf"


class CheckError(RuntimeError):
    """A deterministic precondition failure."""


def tracked_lua_files() -> list[Path]:
    result = subprocess.run(
        ("git", "ls-files", "-z", "--", "*.lua"),
        cwd=ROOT,
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if result.returncode != 0:
        raise CheckError(result.stderr.decode(errors="replace").strip() or "git ls-files failed")
    files = [ROOT / os.fsdecode(raw) for raw in result.stdout.split(b"\0") if raw]
    if not files:
        raise CheckError("no tracked Lua files found")
    return files


def encoding_errors(files: list[Path]) -> list[str]:
    errors: list[str] = []
    for path in files:
        relative = path.relative_to(ROOT)
        try:
            content = path.read_bytes()
        except OSError as exc:
            errors.append(f"cannot read {relative}: {exc}")
            continue
        if content.startswith(UTF8_BOM):
            errors.append(f"UTF-8 BOM is not allowed: {relative}")
        if b"\r" in content:
            errors.append(f"non-Unix line ending is not allowed: {relative}")
        if not content.endswith(b"\n"):
            errors.append(f"missing final newline: {relative}")
        try:
            content.decode("utf-8")
        except UnicodeDecodeError as exc:
            errors.append(f"invalid UTF-8: {relative}: {exc}")
    return errors


def executable(raw: str) -> Path | None:
    resolved = shutil.which(raw)
    return Path(resolved).resolve() if resolved else None


def find_stylua() -> Path:
    explicit = os.environ.get("STYLUA")
    if explicit is not None:
        provider = executable(explicit)
        if provider is None:
            raise CheckError(f"STYLUA is not executable: {explicit}")
        return provider

    provider = executable("stylua")
    if provider is not None:
        return provider

    data_home = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local" / "share")).expanduser()
    mason_provider = data_home / "nvim" / "mason" / "bin" / "stylua"
    if mason_provider.is_file() and os.access(mason_provider, os.X_OK):
        return mason_provider.resolve()

    raise CheckError("StyLua not found via STYLUA, PATH, or current XDG data Mason bin")


def main() -> int:
    try:
        files = tracked_lua_files()
        if not CONFIG.is_file():
            raise CheckError(f"missing format config: {CONFIG.relative_to(ROOT)}")
        errors = encoding_errors(files)
        if errors:
            print("Lua format precheck failed:", file=sys.stderr)
            for error in errors:
                print(f"- {error}", file=sys.stderr)
            return 1
        stylua = find_stylua()
    except CheckError as exc:
        print(f"Lua format check unverified: {exc}", file=sys.stderr)
        return 2

    version = subprocess.run(
        (str(stylua), "--version"),
        cwd=ROOT,
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    if version.returncode != 0:
        print(f"Lua format check unverified: StyLua --version exited {version.returncode}", file=sys.stderr)
        return 2

    command = (
        str(stylua),
        "--check",
        "--verify",
        "--config-path",
        str(CONFIG),
        *(str(path.relative_to(ROOT)) for path in files),
    )
    result = subprocess.run(command, cwd=ROOT, check=False)
    if result.returncode != 0:
        print(f"Lua format check failed: StyLua exited {result.returncode}", file=sys.stderr)
        return result.returncode

    print(f"Lua format check passed: {len(files)} tracked files with {version.stdout.strip()}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
