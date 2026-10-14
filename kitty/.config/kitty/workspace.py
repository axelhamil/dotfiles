import fcntl
import json
import os
import time
import zlib
from contextlib import contextmanager
from dataclasses import asdict, dataclass, replace

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


REGISTRY_DIR = os.path.join(os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}"), "claude-agents")


@dataclass(frozen=True)
class AgentRecord:
    session_id: str
    state: str
    cwd: str
    pid: int
    updated_at: float
    message: str = ""
    tmux_session: str = ""
    tmux_pane: str = ""
    kitty_socket: str = ""
    kitty_window: int = 0

    def is_alive(self) -> bool:
        return self.pid > 0 and os.path.exists(f"/proc/{self.pid}")


def record_path(session_id: str) -> str:
    return os.path.join(REGISTRY_DIR, f"{session_id}.json")


@contextmanager
def record_lock(session_id: str, blocking: bool = True):
    os.makedirs(REGISTRY_DIR, exist_ok=True)

    with open(os.path.join(REGISTRY_DIR, f"{session_id}.lock"), "w") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX if blocking else fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            yield False
            return
        yield True


def read_record(path: str) -> AgentRecord | None:
    try:
        with open(path) as f:
            return AgentRecord(**json.load(f))
    except (OSError, ValueError, TypeError):
        return None


def write_record(record: AgentRecord) -> None:
    os.makedirs(REGISTRY_DIR, exist_ok=True)
    path = record_path(record.session_id)
    temporary = f"{path}.{os.getpid()}.tmp"

    with open(temporary, "w") as f:
        json.dump(asdict(record), f)

    os.replace(temporary, path)


def remove_record(session_id: str) -> None:
    for path in (record_path(session_id), os.path.join(REGISTRY_DIR, f"{session_id}.lock")):
        try:
            os.remove(path)
        except FileNotFoundError:
            pass


def all_records() -> list[AgentRecord]:
    try:
        names = os.listdir(REGISTRY_DIR)
    except FileNotFoundError:
        return []

    records = (read_record(os.path.join(REGISTRY_DIR, name)) for name in names if name.endswith(".json"))
    return [record for record in records if record is not None]


def live_records() -> list[AgentRecord]:
    return [record for record in all_records() if record.is_alive()]


def acknowledge_done(socket: str, window_id: int) -> None:
    for record in live_records():
        if record.state != "done" or record.kitty_socket != socket or record.kitty_window != window_id:
            continue

        with record_lock(record.session_id, blocking=False) as acquired:
            current = read_record(record_path(record.session_id)) if acquired else None
            if current is not None and current.state == "done":
                write_record(replace(current, state="idle"))


def state_rank(state: str) -> int:
    return STATE_PRIORITY.index(state) if state in STATE_PRIORITY else len(STATE_PRIORITY)
