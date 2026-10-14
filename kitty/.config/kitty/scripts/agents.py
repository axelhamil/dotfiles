import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.realpath(__file__))))

from projects import DIM, RESET, ansi, kitten, kitty_windows, window_cwd  # noqa: E402
from workspace import (  # noqa: E402
    CLAUDE_VAR,
    ICON_BRANCH,
    ICON_WORKTREE,
    STATE_COLORS,
    STATE_ICONS,
    STATE_PRIORITY,
    locate,
)

TITLE_NOISE = re.compile(r"^[^\w]+")


def format_agent(window: dict) -> str:
    state = window["user_vars"][CLAUDE_VAR]
    location = locate(window_cwd(window))
    icon = ansi(STATE_COLORS.get(state, 0x7F849C), f"{STATE_ICONS.get(state, '?')} {state:<7}")
    name = ansi(location.color(), location.project) if location.is_repo else location.project
    worktree = f" {ICON_WORKTREE} {location.worktree}" if location.worktree else ""
    branch = f" {DIM}{ICON_BRANCH} {location.branch}{RESET}" if location.branch else ""
    task = TITLE_NOISE.sub("", window.get("title", "")).strip()
    session = f"  {DIM}[{window['session_name']}]{RESET}" if window.get("session_name") else ""
    return f"{icon} {name}{worktree}{branch}  {task}{session}\t{window['id']}"


def priority(window: dict) -> int:
    state = window["user_vars"][CLAUDE_VAR]
    return STATE_PRIORITY.index(state) if state in STATE_PRIORITY else len(STATE_PRIORITY)


def main() -> None:
    agents = [window for window in kitty_windows() if CLAUDE_VAR in window["user_vars"]]

    if not agents:
        print("No Claude session running in kitty.")
        input()
        return

    agents.sort(key=priority)

    result = subprocess.run(
        ["fzf", "--ansi", "--delimiter=\t", "--with-nth=1", "--no-sort", "--layout=reverse", "--border=rounded", "--prompt=claude ❯ "],
        input="\n".join(format_agent(window) for window in agents),
        stdout=subprocess.PIPE,
        text=True,
        check=False,
    )
    window_id = result.stdout.strip().rpartition("\t")[2]

    if window_id:
        kitten("focus-window", "--match", f"id:{window_id}")


if __name__ == "__main__":
    main()
