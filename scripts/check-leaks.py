#!/usr/bin/env python3
"""Fail closed if tracked files, the index, or a push range look like secrets."""

from __future__ import annotations

import re
import shutil
import subprocess
import sys
from pathlib import Path

SKIP_SUFFIXES = {".png", ".jpg", ".jpeg", ".gif", ".webp", ".ico", ".woff", ".woff2", ".ttf"}
MAX_BYTES = 1_000_000
ZERO = "0" * 40

FILENAME_DENY = re.compile(
    r"""(?ix)
    (^|/)(
      \.env($|\.) |
      \.netrc$ |
      \.npmrc$ |
      \.pypirc$ |
      \.git-credentials$ |
      \.pgpass$ |
      credentials(\.json)?$ |
      service-account.*\.json$ |
      application_default_credentials\.json$ |
      hosts\.yml$ |
      id_(rsa|dsa|ecdsa|ed25519|github|gitlab)$ |
      (.*)\.(pem|p12|pfx|p8|key)$
    )
    """
)

CONTENT_RULES = [
    ("private-key", re.compile(r"-----BEGIN (?:RSA |OPENSSH |EC |DSA |PGP |ENCRYPTED )?PRIVATE KEY-----")),
    ("age-secret", re.compile(r"\bAGE-SECRET-KEY-1[A-Z0-9]{50,}\b")),
    ("aws-access-key", re.compile(r"\bAKIA[0-9A-Z]{16}\b")),
    ("github-pat", re.compile(r"\b(?:ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{36,}\b")),
    ("github-fine-grained", re.compile(r"\bgithub_pat_[A-Za-z0-9_]{20,}\b")),
    ("gitlab-pat", re.compile(r"\bglpat-[A-Za-z0-9_\-]{20,}\b")),
    ("slack-token", re.compile(r"\bxox[baprs]-(?:[0-9]+-){2}[A-Za-z0-9]{16,}\b")),
    ("slack-webhook", re.compile(r"https://hooks\.slack\.com/services/T[A-Z0-9]+/B[A-Z0-9]+/[A-Za-z0-9]{16,}")),
    ("openai-key", re.compile(r"\bsk-(?:proj-|svcacct-)?[A-Za-z0-9_-]{20,}\b")),
    ("anthropic-key", re.compile(r"\bsk-ant-[A-Za-z0-9\-_]{20,}\b")),
    ("stripe-live", re.compile(r"\b(?:sk|rk)_live_[A-Za-z0-9]{16,}\b")),
    ("google-api", re.compile(r"\bAIza[0-9A-Za-z\-_]{35}\b")),
    ("npm-token", re.compile(r"\bnpm_[A-Za-z0-9]{36,}\b")),
    ("huggingface", re.compile(r"\bhf_[A-Za-z0-9]{20,}\b")),
    ("groq", re.compile(r"\bgsk_[A-Za-z0-9]{20,}\b")),
    ("telegram-bot", re.compile(r"\b\d{8,}:AA[A-Za-z0-9_\-]{20,}\b")),
    ("discord-webhook", re.compile(r"https://discord(?:app)?\.com/api/webhooks/\d+/[A-Za-z0-9_\-]+")),
    ("jwt", re.compile(r"\beyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\b")),
    ("connection-string", re.compile(r"(?i)(?:postgres|mysql|mongodb|redis)://[^\s:]+:[^\s@]+@")),
    ("generic-secret-assign", re.compile(r"""(?i)(api[_-]?key|secret|password|token)\s*[=:]\s*['\"][^'\"]{12,}['\"]""")),
]

ALLOW_LINE = re.compile(r"YOUR_EMAIL|example\.com|changeme", re.I)


def repo_root() -> Path:
    raw = subprocess.check_output(["git", "rev-parse", "--show-toplevel"], text=True)
    return Path(raw.strip())


def git_files(root: Path, staged: bool) -> list[Path]:
    cmd = ["git", "diff", "--cached", "--name-only", "-z"] if staged else ["git", "ls-files", "-z"]
    raw = subprocess.check_output(cmd, cwd=root)
    names = [n for n in raw.decode().split("\0") if n]
    return [root / n for n in names]


def is_binary(data: bytes) -> bool:
    return b"\0" in data[:8192]


def scan_line(line: str) -> str | None:
    if ALLOW_LINE.search(line) and not any(p.search(line) for _, p in CONTENT_RULES):
        return None
    for name, pattern in CONTENT_RULES:
        if pattern.search(line):
            return name
    return None


def scan_file(root: Path, path: Path) -> list[str]:
    rel = path.relative_to(root).as_posix()
    hits: list[str] = []

    if not rel.endswith((".example", ".sample")) and FILENAME_DENY.search(rel):
        return [f"{rel}: filename looks like a secret"]

    if path.suffix.lower() in SKIP_SUFFIXES or not path.is_file():
        return hits

    try:
        size = path.stat().st_size
    except OSError:
        return hits

    if size > MAX_BYTES:
        return [f"{rel}: file too large to scan ({size} bytes)"]

    data = path.read_bytes()
    if is_binary(data):
        return hits

    try:
        text = data.decode("utf-8")
    except UnicodeDecodeError:
        text = data.decode("utf-8", errors="replace")

    for i, line in enumerate(text.splitlines(), 1):
        name = scan_line(line)
        if name:
            hits.append(f"{rel}:{i}: {name}")

    return hits


def scan_git_log(root: Path, spec: str) -> list[str]:
    diff = subprocess.check_output(
        ["git", "log", "-p", "--format=", spec],
        cwd=root,
        text=True,
        errors="replace",
    )
    hits: list[str] = []
    for i, line in enumerate(diff.splitlines(), 1):
        if not line.startswith("+") or line.startswith("+++"):
            continue
        name = scan_line(line[1:])
        if name:
            hits.append(f"git-history:{i}: {name}")
    return hits


def scan_push_stdin(root: Path) -> list[str]:
    hits: list[str] = []
    for raw in sys.stdin:
        parts = raw.split()
        if len(parts) < 4:
            continue
        local_sha, remote_sha = parts[1], parts[3]
        if local_sha == ZERO:
            continue
        spec = local_sha if remote_sha == ZERO else f"{remote_sha}..{local_sha}"
        hits.extend(scan_git_log(root, spec))
    return hits


def run_gitleaks(root: Path, staged: bool) -> int:
    if shutil.which("gitleaks") is None:
        return 0

    config = root / ".gitleaks.toml"
    cmd = ["gitleaks", "protect" if staged else "detect", "--redact", "--no-banner", "--exit-code", "1"]
    if config.exists():
        cmd += ["--config", str(config)]
    if staged:
        cmd.append("--staged")

    print("→ gitleaks")
    return subprocess.call(cmd, cwd=root)


def fail(hits: list[str]) -> int:
    print("secret scan failed:")
    for hit in hits:
        print(f"  {hit}")
    print("remove the secret or add it to .gitignore — never --no-verify")
    return 1


def main() -> int:
    staged = "--staged" in sys.argv
    pushing = "--push" in sys.argv
    root = repo_root()
    hits: list[str] = []

    for path in git_files(root, staged=staged):
        hits.extend(scan_file(root, path))

    if pushing:
        hits.extend(scan_push_stdin(root))

    if hits:
        return fail(hits)

    gitleaks_rc = run_gitleaks(root, staged=staged)
    if gitleaks_rc != 0:
        return gitleaks_rc

    print(f"✓ secret scan clean ({'push' if pushing else 'staged' if staged else 'tree'})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
