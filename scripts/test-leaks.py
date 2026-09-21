#!/usr/bin/env python3
"""Integration tests for gitignore + leak scanner + git hooks."""

from __future__ import annotations

import os
import shutil
import stat
import subprocess
import sys
import tempfile
from pathlib import Path

DOTFILES = Path(__file__).resolve().parents[1]
SCANNER = DOTFILES / "scripts" / "check-leaks.py"
GITIGNORE = DOTFILES / ".gitignore"
HOOKS = DOTFILES / ".githooks"
GITLEAKS_TOML = DOTFILES / ".gitleaks.toml"

# Built at runtime so this file never contains a complete secret literal.
FAKE = {
    "aws": "AKIA" + "A" * 16,
    "ghp": "ghp_" + "a" * 36,
    "gho": "gho_" + "b" * 36,
    "github_pat": "github_pat_" + "c" * 22,
    "glpat": "glpat-" + "d" * 20,
    "slack": "xoxb-" + "1234567890-" + "1234567890123-" + "a" * 24,
    "openai": "sk-proj-" + "e" * 48,
    "openai_old": "sk-" + "f" * 48,
    "anthropic": "sk-ant-" + "g" * 40,
    "stripe": "sk_live_" + "h" * 24,
    "google": "AIza" + "i" * 35,
    "npm": "npm_" + "j" * 36,
    "telegram": "1234567890:AA" + "k" * 33,
    "discord": "https://discord.com/api/webhooks/123456789012345678/" + "A" * 40,
    "jwt": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4ifQ." + "a" * 16,
    "postgres": "postgres://user:" + "hunter2secret@localhost:5432/db",
    "assign": "api_key = '" + "supersecretvalue123" + "'",
    "age": "AGE-SECRET-KEY-1" + "Q" * 59,
    "hf": "hf_" + "m" * 34,
    "gsk": "gsk_" + "n" * 48,
    "slack_hook": "https://hooks.slack.com/services/" + "T00000000/B00000000/" + "X" * 24,
    "openssh": "-----BEGIN " + "OPENSSH PRIVATE KEY-----\nb3BlbnNzaC1rZXktdjEAAAAABG5vbmU=\n-----END OPENSSH PRIVATE KEY-----",
}

MUST_IGNORE = [
    ".env",
    ".env.production",
    ".netrc",
    ".npmrc",
    ".pypirc",
    "id_rsa",
    "id_github",
    "id_ed25519",
    "foo.pem",
    "foo.key",
    "secrets.json",
    "credentials.json",
    "hosts.yml",
    "auth.json",
    ".git-credentials",
    "service-account.json",
    "kubeconfig",
    ".aws/credentials",
    ".config/git/local",
    "git/.config/git/local",
    "npm-token",
]

MUST_NOT_IGNORE = [
    "AGENTS.md",
    "CLAUDE.md",
    "README.md",
    "scripts/check-leaks.py",
    "scripts/test-leaks.py",
    ".githooks/pre-commit",
    ".githooks/pre-push",
    ".gitleaks.toml",
    "git/.config/git/local.example",
    "npm/.config/npm/npmrc",
    "zsh/.zshenv",
    ".env.example",
]


def run(cmd, cwd, check=True, input=None):
    return subprocess.run(
        cmd,
        cwd=cwd,
        check=check,
        capture_output=True,
        text=True,
        input=input,
    )


def check_ignore(rel: str) -> bool:
    r = subprocess.run(
        ["git", "check-ignore", "-q", rel],
        cwd=DOTFILES,
        capture_output=True,
    )
    return r.returncode == 0


def test_gitignore() -> list[str]:
    errors = []
    for path in MUST_IGNORE:
        if not check_ignore(path):
            errors.append(f"gitignore MISS: {path} should be ignored")
    for path in MUST_NOT_IGNORE:
        if check_ignore(path):
            errors.append(f"gitignore FALSE POSITIVE: {path} should be tracked")
    return errors


def test_scanner_detects() -> list[str]:
    errors = []
    with tempfile.TemporaryDirectory() as tmp:
        repo = Path(tmp) / "repo"
        setup_repo(repo)
        for name, payload in FAKE.items():
            victim = repo / f"leak-{name}.md"
            victim.write_text(f"config:\n  value: {payload}\n", encoding="utf-8")
            run(["git", "add", "-f", str(victim.name)], cwd=repo)
            r = subprocess.run(
                ["python3", str(SCANNER), "--staged"],
                cwd=repo,
                capture_output=True,
                text=True,
            )
            if r.returncode == 0:
                errors.append(f"scanner MISS on {name}: {r.stdout}{r.stderr}")
            run(["git", "reset", "-q", "HEAD"], cwd=repo, check=False)
            victim.unlink()
    return errors


def test_scanner_allows_clean() -> list[str]:
    errors = []
    with tempfile.TemporaryDirectory() as tmp:
        repo = Path(tmp) / "repo"
        setup_repo(repo)
        (repo / "notes.md").write_text(
            "email = YOUR_EMAIL\nexport PATH=\"$HOME/.local/bin\"\n",
            encoding="utf-8",
        )
        run(["git", "add", "notes.md"], cwd=repo)
        r = subprocess.run(
            ["python3", str(SCANNER), "--staged"],
            cwd=repo,
            capture_output=True,
            text=True,
        )
        if r.returncode != 0:
            errors.append(f"scanner FALSE POSITIVE on clean file: {r.stdout}{r.stderr}")
    return errors


def test_allow_line_not_a_backdoor() -> list[str]:
    """A real key must still be caught even if the line also contains <tag> or xxx."""
    errors = []
    with tempfile.TemporaryDirectory() as tmp:
        repo = Path(tmp) / "repo"
        setup_repo(repo)
        (repo / "sneaky.md").write_text(
            f"AKIA{'B' * 16} <!-- ignore --> xxx placeholder\n",
            encoding="utf-8",
        )
        run(["git", "add", "-f", "sneaky.md"], cwd=repo)
        r = subprocess.run(
            ["python3", str(SCANNER), "--staged"],
            cwd=repo,
            capture_output=True,
            text=True,
        )
        if r.returncode == 0:
            errors.append("ALLOW_LINE backdoor: tagged AWS key was not caught")
    return errors


def setup_repo(repo: Path) -> None:
    repo.mkdir()
    run(["git", "init", "-q"], cwd=repo)
    run(["git", "config", "user.name", "leak-test"], cwd=repo)
    run(["git", "config", "user.email", "leak-test@example.com"], cwd=repo)
    run(["git", "config", "commit.gpgsign", "false"], cwd=repo)
    shutil.copy(GITIGNORE, repo / ".gitignore")
    shutil.copy(SCANNER, repo / "check-leaks.py")
    shutil.copy(GITLEAKS_TOML, repo / ".gitleaks.toml")
    hooks = repo / ".githooks"
    hooks.mkdir()
    for name in ("pre-commit", "pre-push"):
        text = (HOOKS / name).read_text()
        text = text.replace('"$ROOT/scripts/check-leaks.py"', '"$ROOT/check-leaks.py"')
        dest = hooks / name
        dest.write_text(text)
        dest.chmod(dest.stat().st_mode | stat.S_IEXEC)
    run(["git", "config", "core.hooksPath", ".githooks"], cwd=repo)
    (repo / "README.md").write_text("clean\n")
    run(["git", "add", "README.md", ".gitignore", "check-leaks.py", ".gitleaks.toml", ".githooks"], cwd=repo)
    r = subprocess.run(["git", "commit", "-q", "-m", "init"], cwd=repo, capture_output=True, text=True)
    if r.returncode != 0:
        raise RuntimeError(f"init commit failed:\n{r.stdout}\n{r.stderr}")


def test_hooks_block_commit_and_force_add() -> list[str]:
    errors = []
    with tempfile.TemporaryDirectory() as tmp:
        repo = Path(tmp) / "repo"
        setup_repo(repo)

        (repo / "ok.md").write_text("hello\n")
        run(["git", "add", "ok.md"], cwd=repo)
        r = subprocess.run(["git", "commit", "-q", "-m", "ok"], cwd=repo, capture_output=True, text=True)
        if r.returncode != 0:
            errors.append(f"hook blocked a clean commit: {r.stdout}{r.stderr}")

        (repo / ".env").write_text("SECRET=1\n")
        add = subprocess.run(["git", "add", ".env"], cwd=repo, capture_output=True, text=True)
        staged = run(["git", "diff", "--cached", "--name-only"], cwd=repo)
        if ".env" in staged.stdout.splitlines():
            errors.append("gitignore failed: .env was staged without -f")

        (repo / "notes.md").write_text(f"key {FAKE['aws']}\n")
        run(["git", "add", "notes.md"], cwd=repo)
        r = subprocess.run(["git", "commit", "-m", "leak"], cwd=repo, capture_output=True, text=True)
        if r.returncode == 0:
            errors.append("pre-commit did not block AWS key in notes.md")

        (repo / ".env").write_text(f"AWS_KEY={FAKE['aws']}\n")
        run(["git", "add", "-f", ".env"], cwd=repo)
        r = subprocess.run(["git", "commit", "-m", "forced env"], cwd=repo, capture_output=True, text=True)
        if r.returncode == 0:
            errors.append("pre-commit did not block git add -f .env")

        (repo / "id_rsa").write_text(FAKE["openssh"])
        run(["git", "add", "-f", "id_rsa"], cwd=repo)
        r = subprocess.run(["git", "commit", "-m", "key"], cwd=repo, capture_output=True, text=True)
        if r.returncode == 0:
            errors.append("pre-commit did not block forced private key")

        # pre-push: create a commit with --no-verify then push should still fail
        (repo / "pushed.md").write_text(f"openai {FAKE['openai']}\n")
        run(["git", "add", "pushed.md"], cwd=repo)
        subprocess.run(["git", "commit", "--no-verify", "-q", "-m", "sneak"], cwd=repo, check=True)
        bare = Path(tmp) / "bare.git"
        run(["git", "init", "--bare", "-q", str(bare)], cwd=tmp)
        run(["git", "remote", "add", "origin", str(bare)], cwd=repo)
        r = subprocess.run(["git", "push", "-u", "origin", "HEAD"], cwd=repo, capture_output=True, text=True)
        if r.returncode == 0:
            errors.append("pre-push did not block a secret that skipped commit hook")
    return errors


def test_hooks_block_history_only_secret() -> list[str]:
    errors = []
    with tempfile.TemporaryDirectory() as tmp:
        repo = Path(tmp) / "repo"
        setup_repo(repo)
        (repo / "ghost.md").write_text(f"stripe {FAKE['stripe']}\n")
        run(["git", "add", "ghost.md"], cwd=repo)
        subprocess.run(["git", "commit", "--no-verify", "-q", "-m", "ghost"], cwd=repo, check=True)
        run(["git", "rm", "-q", "ghost.md"], cwd=repo)
        subprocess.run(["git", "commit", "--no-verify", "-q", "-m", "remove ghost"], cwd=repo, check=True)

        bare = Path(tmp) / "bare.git"
        run(["git", "init", "--bare", "-q", str(bare)], cwd=tmp)
        run(["git", "remote", "add", "origin", str(bare)], cwd=repo)
        r = subprocess.run(["git", "push", "-u", "origin", "HEAD"], cwd=repo, capture_output=True, text=True)
        if r.returncode == 0:
            errors.append("pre-push missed a secret that only exists in git history")
    return errors


def test_dotfiles_tree_clean() -> list[str]:
    r = subprocess.run(["python3", str(SCANNER)], cwd=DOTFILES, capture_output=True, text=True)
    if r.returncode != 0:
        return [f"current dotfiles tree is dirty:\n{r.stdout}{r.stderr}"]
    return []


def main() -> int:
    os.environ.setdefault("GIT_CONFIG_NOSYSTEM", "1")
    suites = [
        ("gitignore", test_gitignore),
        ("scanner detects", test_scanner_detects),
        ("scanner allows clean", test_scanner_allows_clean),
        ("no allow-line backdoor", test_allow_line_not_a_backdoor),
        ("hooks", test_hooks_block_commit_and_force_add),
        ("history-only secret", test_hooks_block_history_only_secret),
        ("dotfiles tree", test_dotfiles_tree_clean),
    ]
    failed = 0
    for name, fn in suites:
        errors = fn()
        if errors:
            failed += 1
            print(f"FAIL  {name}")
            for err in errors:
                print(f"  - {err}")
        else:
            print(f"PASS  {name}")
    if failed:
        print(f"\n{failed} suite(s) failed")
        return 1
    print("\nall leak tests passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
