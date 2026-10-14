import json
import os
import subprocess
import sys
from dataclasses import dataclass

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.realpath(__file__))))

from workspace import (  # noqa: E402
    CLAUDE_VAR,
    ICON_BRANCH,
    ICON_WORKTREE,
    STATE_COLORS,
    STATE_ICONS,
    locate,
    worst_state,
)

HOME = os.path.expanduser("~")
ROOTS = (os.path.join(HOME, "DEV"),)
EXTRA_REPOS = (os.path.join(HOME, ".dotfiles"),)
MAX_DEPTH = 3
SKIPPED_DIRS = {"node_modules", ".git", ".claude", "dist", "build", "target"}
SESSION_DIRS = (
    os.path.join(HOME, ".config", "kitty", "sessions"),
    os.path.join(HOME, ".local", "share", "kitty", "sessions"),
)
GENERATED_SESSION_DIR = SESSION_DIRS[1]
AGENT_WORKTREE_PREFIX = "agent-"
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


def open_states(windows: list[dict]) -> dict[str, list[str]]:
    states: dict[str, list[str]] = {}

    for window in windows:
        states.setdefault(window_cwd(window), []).append(window["user_vars"].get(CLAUDE_VAR, "open"))

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
    marker = ansi(STATE_COLORS[state], STATE_ICONS[state]) if state in STATE_ICONS else ("●" if state else " ")
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


def pick(lines: list[str]) -> str:
    result = subprocess.run(
        [
            "fzf",
            "--ansi",
            "--delimiter=\t",
            "--with-nth=1",
            "--no-sort",
            "--layout=reverse",
            "--border=rounded",
            "--prompt=project ❯ ",
            "--header=enter: open  ·  ● open  ·  \U000f051f running  ·   waiting  ·   done",
        ],
        input="\n".join(lines),
        stdout=subprocess.PIPE,
        text=True,
        check=False,
    )
    return result.stdout.strip().rpartition("\t")[2]


def session_file(entry: Entry, repo_path: str) -> str:
    for directory in SESSION_DIRS:
        candidate = os.path.join(directory, f"{entry.project}.kitty-session")
        if os.path.isfile(candidate):
            return candidate

    os.makedirs(GENERATED_SESSION_DIR, exist_ok=True)
    path = os.path.join(GENERATED_SESSION_DIR, f"{entry.project}.kitty-session")
    with open(path, "w") as f:
        f.write(f"new_tab {entry.project}\nlayout splits\ncd {repo_path}\nlaunch\n")
    return path


def kitten(*args: str) -> None:
    subprocess.run(["kitten", "@", *args], check=False)


def open_entry(entry: Entry, entries: list[Entry], windows: list[dict]) -> None:
    repo_path = next(candidate.path for candidate in entries if candidate.project == entry.project and not candidate.worktree)
    kitten("action", "goto_session", session_file(entry, repo_path))

    if not entry.worktree:
        return

    existing = next((window for window in windows if is_inside(window_cwd(window), entry.path)), None)
    if existing:
        kitten("focus-window", "--match", f"id:{existing['id']}")
        return

    kitten("launch", "--type=tab", f"--cwd={entry.path}", f"--add-to-session={entry.project}")


def main() -> None:
    entries = collect_entries()
    windows = kitty_windows()
    states = open_states(windows)
    scores = zoxide_scores()

    entry_states = {entry: state_for(entry, states) for entry in entries}
    entries.sort(key=lambda entry: sort_key(entry, entry_states[entry], scores))

    chosen_path = pick([format_entry(entry, entry_states[entry]) for entry in entries])
    chosen = next((entry for entry in entries if entry.path == chosen_path), None)

    if chosen:
        open_entry(chosen, entries, windows)


if __name__ == "__main__":
    main()
