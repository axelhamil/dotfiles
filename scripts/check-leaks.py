#!/usr/bin/env python3
"""Fail closed if tracked or staged files look like secrets."""

from __future__ import annotations

import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

SKIP_SUFFIXES = {".png", ".jpg", ".jpeg", ".gif", ".webp", ".ico", ".woff", ".woff2", ".ttf"}
MAX_BYTES = 1_000_000

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
    ("aws-access-key", re.compile(r"\bAKIA[0-9A-Z]{16}\b")),
    ("github-pat", re.compile(r"\b(?:ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{36,}\b")),
    ("github-fine-grained", re.compile(r"\bgithub_pat_[A-Za-z0-9_]{20,}\b")),
    ("gitlab-pat", re.compile(r"\bglpat-[A-Za-z0-9_\-]{20,}\b")),
    ("slack-token", re.compile(r"\bxox[baprs]-[A-Za-z0-9-]{10,}\b")),
    ("openai-key", re.compile(r"\bsk-[A-Za-z0-9]{20,}\b")),
    ("anthropic-key", re.compile(r"\bsk-ant-[A-Za-z0-9\-_]{20,}\b")),
    ("stripe-live", re.compile(r"\bsk_live_[A-Za-z0-9]{16,}\b")),
    ("google-api", re.compile(r"\bAIza[0-9A-Za-z\-_]{35}\b")),
    ("npm-token", re.compile(r"\bnpm_[A-Za-z0-9]{36,}\b")),
    ("telegram-bot", re.compile(r"\b\d{8,}:AA[A-Za-z0-9_\-]{20,}\b")),
    ("discord-webhook", re.compile(r"https://discord(?:app)?\.com/api/webhooks/\d+/[A-Za-z0-9_\-]+")),
    ("jwt", re.compile(r"\beyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\b")),
    ("connection-string", re.compile(r"(?i)(?:postgres|mysql|mongodb|redis)://[^\s:]+:[^\s@]+@")),
    ("generic-secret-assign", re.compile(r"""(?i)(api[_-]?key|secret|password|token)\s*[=:]\s*['\"][^'\"]{12,}['\"]""")),
]

ALLOW_LINE = re.compile(
    r"YOUR_EMAIL|example\.com|placeholder|changeme|xxx+|TODO|<.+>|\$\{",
    re.I,
)


def git_files(staged: bool) -> list[Path]:
    cmd = ["git", "diff", "--cached", "--name-only", "-z"] if staged else ["git", "ls-files", "-z"]
    raw = subprocess.check_output(cmd, cwd=ROOT)
    names = [n for n in raw.decode().split("\0") if n]
    return [ROOT / n for n in names]


def is_binary(data: bytes) -> bool:
    return b"\0" in data[:8192]


def scan_file(path: Path) -> list[str]:
    rel = path.relative_to(ROOT).as_posix()
    hits: list[str] = []

    if not rel.endswith((".example", ".sample")) and FILENAME_DENY.search(rel):
        hits.append(f"{rel}: filename looks like a secret")
        return hits

    if path.suffix.lower() in SKIP_SUFFIXES or not path.is_file():
        return hits

    try:
        size = path.stat().st_size
    except OSError:
        return hits

    if size > MAX_BYTES:
        hits.append(f"{rel}: file too large to scan ({size} bytes)")
        return hits

    data = path.read_bytes()
    if is_binary(data):
        return hits

    try:
        text = data.decode("utf-8")
    except UnicodeDecodeError:
        text = data.decode("utf-8", errors="replace")

    for i, line in enumerate(text.splitlines(), 1):
        if ALLOW_LINE.search(line):
            continue
        for name, pattern in CONTENT_RULES:
            if pattern.search(line):
                hits.append(f"{rel}:{i}: {name}")

    return hits


def run_gitleaks(staged: bool) -> int:
    if shutil.which("gitleaks") is None:
        return 0

    config = ROOT / ".gitleaks.toml"
    cmd = ["gitleaks", "protect" if staged else "detect", "--redact", "--no-banner", "--exit-code", "1"]
    if config.exists():
        cmd += ["--config", str(config)]
    if staged:
        cmd.append("--staged")

    print("→ gitleaks")
    return subprocess.call(cmd, cwd=ROOT)


def main() -> int:
    staged = "--staged" in sys.argv
    files = git_files(staged=staged)
    hits: list[str] = []

    for path in files:
        hits.extend(scan_file(path))

    gitleaks_rc = run_gitleaks(staged=staged)

    if hits:
        print("secret scan failed:")
        for hit in hits:
            print(f"  {hit}")
        print("remove the secret or add it to .gitignore — never --no-verify")
        return 1

    if gitleaks_rc != 0:
        return gitleaks_rc

    print(f"✓ secret scan clean ({len(files)} files)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
