import json
import os
import re
import shlex
import subprocess
import sys
from dataclasses import dataclass

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.realpath(__file__))))

from workspace import (  # noqa: E402
    ICON_BRANCH,
    ICON_WORKTREE,
    STATE_COLORS,
    STATE_ICONS,
    live_records,
    locate,
    worst_state,
)

HOME = os.path.expanduser("~")
ROOTS = (os.path.join(HOME, "DEV"),)
EXTRA_REPOS = (os.path.join(HOME, ".dotfiles"),)
MAX_DEPTH = 3
SKIPPED_DIRS = {"node_modules", ".git", ".claude", "dist", "build", "target"}
CUSTOM_SESSION_DIR = os.path.join(HOME, ".config", "kitty", "sessions")
GENERATED_SESSION_DIR = os.path.join(HOME, ".local", "share", "kitty", "sessions")
AGENT_WORKTREE_PREFIX = "agent-"
WORKTREE_DIR = ".claude/worktrees"
BASE_BRANCHES = ("dev", "develop", "main", "master")
DIM = "\x1b[38;2;108;112;134m"
RESET = "\x1b[0m"


@dataclass(frozen=True)
class Entry:
    path: str
    project: str
    worktree: str

    def is_agent(self) -> bool:
        return self.worktree.startswith(AGENT_WORKTREE_PREFIX)


def ansi(color: int, text: str) -> str:
    return f"\x1b[38;2;{color >> 16 & 255};{color >> 8 & 255};{color & 255}m{text}{RESET}"


def find_repos(root: str, depth: int = 0):
    if os.path.isdir(os.path.join(root, ".git")):
        yield root
        return

    if depth >= MAX_DEPTH:
        return

    try:
        children = sorted(entry.path for entry in os.scandir(root) if entry.is_dir() and entry.name not in SKIPPED_DIRS)
    except OSError:
        return

    for child in children:
        yield from find_repos(child, depth + 1)


def find_worktrees(repo: str):
    worktrees_dir = os.path.join(repo, ".git", "worktrees")

    try:
        names = sorted(os.listdir(worktrees_dir))
    except OSError:
        return

    for name in names:
        try:
            with open(os.path.join(worktrees_dir, name, "gitdir")) as f:
                path = os.path.dirname(f.read().strip())
        except OSError:
            continue
        if os.path.isdir(path):
            yield path


def zoxide_scores() -> dict[str, float]:
    try:
        output = subprocess.run(["zoxide", "query", "-ls"], capture_output=True, text=True, check=False).stdout
    except OSError:
        return {}

    scores = {}
    for line in output.splitlines():
        score, _, path = line.strip().partition(" ")
        scores[path.strip()] = float(score)
    return scores


def kitty_windows() -> list[dict]:
    result = subprocess.run(["kitten", "@", "ls"], capture_output=True, text=True, check=False)
    if result.returncode != 0:
        return []

    return [window for os_window in json.loads(result.stdout) for tab in os_window["tabs"] for window in tab["windows"]]


def window_cwd(window: dict) -> str:
    processes = sorted(window.get("foreground_processes") or [], key=lambda process: process["pid"])
    return processes[0]["cwd"] if processes else window.get("cwd", "")


def is_inside(path: str, root: str) -> bool:
    return path == root or path.startswith(f"{root}/")


def tmux_sessions() -> dict[str, str]:
    result = subprocess.run(["tmux", "list-sessions", "-F", "#{session_name}\t#{session_path}"], capture_output=True, text=True, check=False)
    return dict(line.split("\t", 1) for line in result.stdout.splitlines() if "\t" in line)


def open_states(windows: list[dict]) -> dict[str, list[str]]:
    states: dict[str, list[str]] = {}

    for path in tmux_sessions().values():
        states.setdefault(path, []).append("open")

    for window in windows:
        states.setdefault(window_cwd(window), []).append("open")

    for record in live_records():
        states.setdefault(record.cwd, []).append(record.state)

    return states


def collect_entries() -> list[Entry]:
    repos = [repo for root in ROOTS for repo in find_repos(root)]
    repos += [repo for repo in EXTRA_REPOS if os.path.isdir(os.path.join(repo, ".git"))]
    entries = []

    for repo in repos:
        project = os.path.basename(repo)
        entries.append(Entry(repo, project, ""))
        entries += [Entry(path, project, os.path.basename(path)) for path in find_worktrees(repo)]

    return entries


def state_for(entry: Entry, states: dict[str, list[str]]) -> str:
    found = [state for path, values in states.items() if is_inside(path, entry.path) for state in values]

    if not found:
        return ""

    return worst_state(found) or "open"


def format_entry(entry: Entry, state: str) -> str:
    location = locate(entry.path)
    marker = ansi(STATE_COLORS[state], STATE_ICONS[state]) if state in STATE_ICONS else ("\u25cf" if state else " ")
    name = ansi(location.color(), entry.project)
    worktree = f" {ICON_WORKTREE} {entry.worktree}" if entry.worktree else ""
    branch = f"{DIM} {ICON_BRANCH} {location.branch}{RESET}" if location.branch else ""
    label = f"{marker} {name}{worktree}{branch}"

    if entry.is_agent():
        label = f"{marker} {DIM}{entry.project}{worktree}{RESET}"

    shown_path = entry.path.replace(HOME, "~", 1)
    return f"{label}  {DIM}{shown_path}{RESET}\t{entry.path}"


def sort_key(entry: Entry, state: str, scores: dict[str, float]):
    return (entry.is_agent(), not state, -scores.get(entry.path, 0.0), entry.project, entry.worktree)


def pick(lines: list[str]) -> tuple[str, str]:
    result = subprocess.run(
        [
            "fzf",
            "--ansi",
            "--delimiter=\t",
            "--with-nth=1",
            "--no-sort",
            "--layout=reverse",
            "--border=rounded",
            "--expect=ctrl-n",
            "--prompt=project \u276f ",
            "--header=enter: open  \u00b7  ctrl-n: new task worktree + claude",
        ],
        input="\n".join(lines),
        stdout=subprocess.PIPE,
        text=True,
        check=False,
    )
    key, _, selection = result.stdout.partition("\n")
    return key.strip(), selection.strip().rpartition("\t")[2]


def tmux_name(entry: Entry) -> str:
    name = f"{entry.project}-{entry.worktree}" if entry.worktree else entry.project
    return re.sub(r"[.:]", "_", name)


def attach_command(entry: Entry) -> str:
    return shlex.join(["tmux", "new-session", "-A", "-s", tmux_name(entry), "-c", entry.path])


def session_file(entry: Entry, repo: Entry) -> str:
    custom = os.path.join(CUSTOM_SESSION_DIR, f"{repo.project}.kitty-session")
    if os.path.isfile(custom):
        return custom

    os.makedirs(GENERATED_SESSION_DIR, exist_ok=True)
    path = os.path.join(GENERATED_SESSION_DIR, f"{repo.project}.kitty-session")
    with open(path, "w") as f:
        f.write(f"new_tab {repo.project}\nlayout splits\ncd {repo.path}\nlaunch {attach_command(repo)}\n")
    return path


def kitten(*args: str) -> None:
    subprocess.run(["kitten", "@", *args], check=False)


def shows_entry(window: dict, entry: Entry) -> bool:
    if is_inside(window_cwd(window), entry.path):
        return True

    command = [arg for process in window.get("foreground_processes") or [] for arg in process.get("cmdline") or []]
    return "tmux" in os.path.basename(command[0] if command else "") and tmux_name(entry) in command


def open_entry(entry: Entry, repo: Entry, windows: list[dict]) -> None:
    kitten("action", "goto_session", session_file(entry, repo))

    if not entry.worktree:
        return

    existing = next((window for window in windows if shows_entry(window, entry)), None)
    if existing:
        kitten("focus-window", "--match", f"id:{existing['id']}")
        return

    kitten("launch", "--type=tab", f"--cwd={entry.path}", f"--add-to-session={repo.project}", *shlex.split(attach_command(entry)))


def slugify(text: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")


def git(repo: str, *args: str) -> subprocess.CompletedProcess:
    return subprocess.run(["git", "-C", repo, *args], capture_output=True, text=True, check=False)


def base_branch(repo: str) -> str:
    return next((branch for branch in BASE_BRANCHES if git(repo, "rev-parse", "--verify", "--quiet", f"refs/heads/{branch}").returncode == 0), "HEAD")


def exclude_worktrees(repo: str) -> None:
    exclude = os.path.join(repo, ".git", "info", "exclude")
    pattern = f"/{WORKTREE_DIR}/"

    try:
        with open(exclude) as f:
            if pattern in f.read().splitlines():
                return
    except FileNotFoundError:
        os.makedirs(os.path.dirname(exclude), exist_ok=True)

    with open(exclude, "a") as f:
        f.write(f"\n{pattern}\n")


def create_task(repo: Entry) -> Entry | None:
    task = slugify(input(f"New task in {repo.project} (feat/<name>): "))
    if not task:
        return None

    path = os.path.join(repo.path, WORKTREE_DIR, task)
    base = base_branch(repo.path)
    created = git(repo.path, "worktree", "add", "-b", f"feat/{task}", path, base)

    if created.returncode != 0:
        print(created.stderr.strip())
        input()
        return None

    exclude_worktrees(repo.path)
    entry = Entry(path, repo.project, task)
    session = tmux_name(entry)
    if subprocess.run(["tmux", "has-session", "-t", f"={session}"], capture_output=True, check=False).returncode == 0:
        return entry

    subprocess.run(["tmux", "new-session", "-d", "-s", session, "-c", path], check=False)
    subprocess.run(["tmux", "send-keys", "-t", f"={session}:", "claude", "Enter"], check=False)
    return entry


def main() -> None:
    entries = collect_entries()
    windows = kitty_windows()
    states = open_states(windows)
    scores = zoxide_scores()

    entry_states = {entry: state_for(entry, states) for entry in entries}
    entries.sort(key=lambda entry: sort_key(entry, entry_states[entry], scores))

    key, chosen_path = pick([format_entry(entry, entry_states[entry]) for entry in entries])
    chosen = next((entry for entry in entries if entry.path == chosen_path), None)
    if chosen is None:
        return

    repo = next(entry for entry in entries if entry.project == chosen.project and not entry.worktree)
    if key == "ctrl-n":
        chosen = create_task(repo)
        if chosen is None:
            return

    open_entry(chosen, repo, windows)


if __name__ == "__main__":
    main()
