#!/usr/bin/env python3
"""Run the repository's Neovim compatibility smoke matrix without downloads."""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import signal
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LOCKFILE = ROOT / "lazy-lock.json"
SMOKE_SCRIPT = ROOT / "scripts" / "compat-smoke.lua"
VERSION_RE = re.compile(r"^\d+\.\d+\.\d+$")
NVIM_VERSION_RE = re.compile(r"^NVIM v(\d+\.\d+\.\d+)", re.MULTILINE)
OUTPUT_ERRORS = (
    ("Error detected", re.compile(r"Error detected", re.IGNORECASE)),
    ("Vim error code", re.compile(r"(?:^|\s)E\d{3,}:")),
    ("traceback", re.compile(r"traceback", re.IGNORECASE)),
    ("provider error", re.compile(r"provider\s+error", re.IGNORECASE)),
    ("smoke failure marker", re.compile(r"DARKROAM_COMPAT_FAIL")),
)
PROXY_VARIABLES = (
    "http_proxy",
    "https_proxy",
    "all_proxy",
    "HTTP_PROXY",
    "HTTPS_PROXY",
    "ALL_PROXY",
    "no_proxy",
    "NO_PROXY",
)


class CompatibilityError(RuntimeError):
    """A deterministic compatibility precondition or check failure."""


@dataclass(frozen=True)
class MatrixCase:
    version: str
    binary: Path


@dataclass(frozen=True)
class CommandResult:
    returncode: int
    output: str
    timed_out: bool = False


@dataclass(frozen=True)
class CaseResult:
    case: MatrixCase
    passed: bool
    reasons: tuple[str, ...]
    output: str
    log: str
    temp_root: Path | None


def parse_case(raw: str) -> MatrixCase:
    version, separator, binary_raw = raw.partition("=")
    if not separator or not VERSION_RE.fullmatch(version) or not binary_raw:
        raise argparse.ArgumentTypeError("case must use VERSION=/path/to/nvim")

    binary = Path(binary_raw).expanduser().resolve()
    if not binary.is_file():
        raise argparse.ArgumentTypeError(f"Neovim binary does not exist: {binary}")
    if not os.access(binary, os.X_OK):
        raise argparse.ArgumentTypeError(f"Neovim binary is not executable: {binary}")
    return MatrixCase(version=version, binary=binary)


def command(
    args: list[str],
    *,
    cwd: Path,
    env: dict[str, str] | None = None,
    timeout: int = 30,
) -> CommandResult:
    try:
        process = subprocess.Popen(
            args,
            cwd=cwd,
            env=env,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            start_new_session=os.name == "posix",
        )
    except OSError as exc:
        return CommandResult(127, f"failed to execute {args[0]}: {exc}\n")
    try:
        output, _ = process.communicate(timeout=timeout)
        return CommandResult(process.returncode, output or "")
    except subprocess.TimeoutExpired:
        try:
            if os.name == "posix":
                os.killpg(process.pid, signal.SIGKILL)
            else:
                process.kill()
        except ProcessLookupError:
            pass
        output, _ = process.communicate()
        return CommandResult(124, output or "", timed_out=True)


def git_output(checkout: Path, *args: str) -> str:
    result = command(["git", "-C", str(checkout), *args], cwd=ROOT, timeout=10)
    if result.returncode != 0:
        raise CompatibilityError(
            f"git {' '.join(args)} failed for {checkout}:\n{result.output.rstrip()}"
        )
    return result.output.strip()


def load_lockfile() -> dict[str, dict[str, str]]:
    try:
        lock = json.loads(LOCKFILE.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise CompatibilityError(f"cannot read {LOCKFILE}: {exc}") from exc
    if not isinstance(lock, dict) or not lock:
        raise CompatibilityError(f"invalid or empty lockfile: {LOCKFILE}")
    return lock


def validate_data_home(data_home: Path, lock: dict[str, dict[str, str]]) -> Path:
    lazy_root = data_home / "nvim" / "lazy"
    if not lazy_root.is_dir():
        raise CompatibilityError(f"Lazy data root does not exist: {lazy_root}")

    failures: list[str] = []
    for name, record in sorted(lock.items()):
        if not isinstance(record, dict):
            failures.append(f"invalid lockfile record: {name}")
            continue
        expected = record.get("commit")
        checkout = lazy_root / name
        if not (checkout / ".git").exists():
            failures.append(f"missing checkout: {name}")
            continue
        try:
            actual = git_output(checkout, "rev-parse", "HEAD")
            dirty = git_output(checkout, "status", "--short", "--untracked-files=no")
        except CompatibilityError as exc:
            failures.append(str(exc))
            continue
        if actual != expected:
            failures.append(f"checkout mismatch: {name}: expected {expected}, got {actual}")
        if dirty:
            failures.append(f"tracked checkout changes: {name}:\n{dirty}")

    if failures:
        raise CompatibilityError("Lazy data preflight failed:\n- " + "\n- ".join(failures))
    return lazy_root


def verify_binary(case: MatrixCase) -> str | None:
    result = command([str(case.binary), "--version"], cwd=ROOT, timeout=10)
    if result.returncode != 0:
        return f"--version exited {result.returncode}: {result.output.rstrip()}"
    match = NVIM_VERSION_RE.search(result.output)
    if not match:
        return f"cannot parse Neovim version from: {result.output.rstrip()}"
    actual = match.group(1)
    if actual != case.version:
        return f"declared version {case.version} does not match binary version {actual}"
    return None


def offline_environment(root: Path, case: MatrixCase) -> dict[str, str]:
    env = os.environ.copy()
    for variable in PROXY_VARIABLES:
        env.pop(variable, None)

    env.update(
        {
            "HOME": str(root / "home"),
            "XDG_CONFIG_HOME": str(root / "config"),
            "XDG_DATA_HOME": str(root / "data"),
            "XDG_STATE_HOME": str(root / "state"),
            "XDG_CACHE_HOME": str(root / "cache"),
            "XDG_RUNTIME_DIR": str(root / "runtime"),
            "NVIM_LOG_FILE": str(root / "nvim.log"),
            "DARKROAM_EXPECT_VERSION": case.version,
            "GIT_TERMINAL_PROMPT": "0",
            "GIT_CONFIG_COUNT": "1",
            "GIT_CONFIG_KEY_0": "url.file:///nonexistent/darkroam-offline/.insteadOf",
            "GIT_CONFIG_VALUE_0": "https://",
        }
    )
    return env


def prepare_root(case: MatrixCase, lazy_root: Path) -> Path:
    prefix = f"darkroam-nvim-{case.version.replace('.', '')}-"
    root = Path(tempfile.mkdtemp(prefix=prefix))
    for relative in ("home", "config", "data/nvim", "state", "cache", "runtime", "workspace"):
        (root / relative).mkdir(parents=True, exist_ok=True)
    (root / "runtime").chmod(0o700)
    (root / "config" / "nvim").symlink_to(ROOT, target_is_directory=True)
    (root / "data" / "nvim" / "lazy").symlink_to(lazy_root, target_is_directory=True)
    (root / "workspace" / "sample.txt").write_text("darkroam compatibility smoke\n", encoding="utf-8")
    return root


def scan_output(output: str) -> list[str]:
    return [label for label, pattern in OUTPUT_ERRORS if pattern.search(output)]


def run_case(case: MatrixCase, lazy_root: Path, keep_temp: bool) -> CaseResult:
    version_error = verify_binary(case)
    if version_error:
        return CaseResult(case, False, (version_error,), "", "", None)

    try:
        root = prepare_root(case, lazy_root)
    except OSError as exc:
        return CaseResult(case, False, (f"cannot prepare temporary root: {exc}",), "", "", None)
    log_path = root / "nvim.log"
    lua_command = f"lua dofile({json.dumps(str(SMOKE_SCRIPT), ensure_ascii=False)})"
    result = command(
        [str(case.binary), "--headless", "-c", lua_command, "-c", "qa!"],
        cwd=root / "workspace",
        env=offline_environment(root, case),
        timeout=60,
    )
    log = log_path.read_text(encoding="utf-8", errors="replace") if log_path.exists() else ""
    reasons: list[str] = []
    if result.timed_out:
        reasons.append("Neovim timed out after 60 seconds")
    elif result.returncode != 0:
        reasons.append(f"Neovim exited with status {result.returncode}")

    marker = f"DARKROAM_COMPAT_OK version={case.version} "
    if marker not in result.output:
        reasons.append("success marker is missing")
    for label in scan_output(result.output):
        reasons.append(f"output contains {label}")
    if log:
        reasons.append("NVIM_LOG_FILE is not empty")

    passed = not reasons
    retained = root if keep_temp else None
    if not keep_temp:
        shutil.rmtree(root)
    return CaseResult(case, passed, tuple(reasons), result.output, log, retained)


def print_result(result: CaseResult) -> None:
    label = f"{result.case.version} ({result.case.binary})"
    if result.passed:
        marker = next(
            line.strip() for line in result.output.splitlines() if "DARKROAM_COMPAT_OK" in line
        )
        print(f"PASS {label}: {marker}")
        return

    print(f"FAIL {label}", file=sys.stderr)
    for reason in result.reasons:
        print(f"  - {reason}", file=sys.stderr)
    if result.output:
        print("  Neovim output:", file=sys.stderr)
        print(result.output.rstrip(), file=sys.stderr)
    if result.log:
        print("  NVIM_LOG_FILE:", file=sys.stderr)
        print(result.log.rstrip(), file=sys.stderr)
    if result.temp_root:
        print(f"  retained temp root: {result.temp_root}", file=sys.stderr)


def arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--data-home",
        required=True,
        type=lambda value: Path(value).expanduser().resolve(),
        help="pre-restored XDG data home containing nvim/lazy",
    )
    parser.add_argument(
        "--case",
        action="append",
        required=True,
        type=parse_case,
        dest="cases",
        metavar="VERSION=NVIM_PATH",
        help="expected exact version and Neovim binary; repeat for a matrix",
    )
    parser.add_argument(
        "--keep-temp",
        action="store_true",
        help="retain per-case temporary roots for debugging",
    )
    return parser.parse_args()


def main() -> int:
    args = arguments()
    versions = [case.version for case in args.cases]
    if len(versions) != len(set(versions)):
        print("duplicate --case versions are not allowed", file=sys.stderr)
        return 2

    try:
        lock = load_lockfile()
        lazy_root = validate_data_home(args.data_home, lock)
    except CompatibilityError as exc:
        print(exc, file=sys.stderr)
        return 2

    results = [run_case(case, lazy_root, args.keep_temp) for case in args.cases]
    for result in results:
        print_result(result)
    failures = sum(not result.passed for result in results)
    if failures:
        print(f"compatibility matrix failed: {failures}/{len(results)} case(s)", file=sys.stderr)
        return 1
    print(f"compatibility matrix passed: {len(results)} case(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
