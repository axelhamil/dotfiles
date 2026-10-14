import os
import time
import zlib
from dataclasses import dataclass

HOME = os.path.expanduser("~")

PROJECT_PALETTE = (
    0xF5E0DC,
    0xF2CDCD,
    0xF5C2E7,
    0xCBA6F7,
    0xEBA0AC,
    0xFAB387,
    0x94E2D5,
    0x89DCEB,
    0x74C7EC,
    0x89B4FA,
    0xB4BEFE,
)

STATE_PRIORITY = ("waiting", "done", "running", "idle")
STATE_COLORS = {"waiting": 0xF38BA8, "done": 0xA6E3A1, "running": 0xF9E2AF, "idle": 0x7F849C}
STATE_ICONS = {"waiting": "", "done": "", "running": "\U000f051f", "idle": "\U000f06a9"}

ICON_BRANCH = ""
ICON_WORKTREE = "\U000f0645"
ICON_FOLDER = ""

CLAUDE_VAR = "claude"
ROOT_CACHE_TTL = 10.0


@dataclass(frozen=True)
class Location:
    project: str
    worktree: str
    branch: str
    is_repo: bool

    def color(self) -> int:
        return PROJECT_PALETTE[zlib.crc32(self.project.encode()) % len(PROJECT_PALETTE)]


@dataclass(frozen=True)
class Repo:
    root: str
    git_dir: str
    project: str
    is_worktree: bool


_root_cache: dict[str, tuple[float, Repo | None]] = {}


def _read(path: str) -> str:
    try:
        with open(path) as f:
            return f.read().strip()
    except OSError:
        return ""


def _resolve_repo(root: str) -> Repo:
    dot_git = os.path.join(root, ".git")

    if os.path.isdir(dot_git):
        return Repo(root, dot_git, os.path.basename(root), False)

    git_dir = _read(dot_git).removeprefix("gitdir:").strip()
    git_dir = os.path.normpath(os.path.join(root, git_dir))
    common_dir = _read(os.path.join(git_dir, "commondir"))

    if not common_dir:
        return Repo(root, git_dir, os.path.basename(root), False)

    main_root = os.path.dirname(os.path.normpath(os.path.join(git_dir, common_dir)))
    return Repo(root, git_dir, os.path.basename(main_root), True)


def find_repo(path: str) -> Repo | None:
    cached = _root_cache.get(path)
    if cached and time.monotonic() - cached[0] < ROOT_CACHE_TTL:
        return cached[1]

    repo = None
    current = path
    while current and current != "/":
        if os.path.exists(os.path.join(current, ".git")):
            repo = _resolve_repo(current)
            break
        current = os.path.dirname(current)

    _root_cache[path] = (time.monotonic(), repo)
    return repo


def read_branch(git_dir: str) -> str:
    head = _read(os.path.join(git_dir, "HEAD"))

    if head.startswith("ref:"):
        return head.removeprefix("ref:").strip().removeprefix("refs/heads/")

    return head[:7]


def short_path(path: str) -> str:
    if path == HOME:
        return "~"
    return os.path.basename(path) or path


def locate(cwd: str) -> Location:
    repo = find_repo(cwd) if cwd else None

    if repo is None:
        return Location(short_path(cwd), "", "", False)

    worktree = os.path.basename(repo.root) if repo.is_worktree else ""
    return Location(repo.project, worktree, read_branch(repo.git_dir), True)


def worst_state(states) -> str:
    present = set(states)
    return next((state for state in STATE_PRIORITY if state in present), "")
