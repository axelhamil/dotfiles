import os
import subprocess
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.realpath(__file__))))

from projects import DIM, RESET, ansi  # noqa: E402
from workspace import (  # noqa: E402
    ICON_BRANCH,
    ICON_WORKTREE,
    STATE_COLORS,
    STATE_ICONS,
    AgentRecord,
    live_records,
    locate,
    state_rank,
)

FOCUS_SCRIPT = os.path.join(os.path.dirname(os.path.realpath(__file__)), "focus_agent.py")
ICON_TMUX = ""


def age(timestamp: float) -> str:
    minutes = int((time.time() - timestamp) // 60)
    if minutes < 1:
        return "now"
    if minutes < 60:
        return f"{minutes}m"
    return f"{minutes // 60}h{minutes % 60:02d}"


def format_agent(record: AgentRecord) -> str:
    location = locate(record.cwd)
    icon = ansi(STATE_COLORS.get(record.state, 0x7F849C), f"{STATE_ICONS.get(record.state, '?')} {record.state:<7}")
    name = ansi(location.color(), location.project) if location.is_repo else location.project
    worktree = f" {ICON_WORKTREE} {location.worktree}" if location.worktree else ""
    branch = f" {DIM}{ICON_BRANCH} {location.branch}{RESET}" if location.branch else ""
    tmux = f" {DIM}{ICON_TMUX} {record.tmux_session}{RESET}" if record.tmux_session else ""
    message = f"  {record.message}" if record.message else ""
    return f"{icon} {DIM}{age(record.updated_at):>5}{RESET}  {name}{worktree}{branch}{tmux}{message}\t{record.session_id}"


def main() -> None:
    records = sorted(live_records(), key=lambda record: (state_rank(record.state), -record.updated_at))

    if not records:
        print("No Claude agent running.")
        input()
        return

    result = subprocess.run(
        ["fzf", "--ansi", "--delimiter=\t", "--with-nth=1", "--no-sort", "--layout=reverse", "--border=rounded", "--prompt=claude ❯ "],
        input="\n".join(format_agent(record) for record in records),
        stdout=subprocess.PIPE,
        text=True,
        check=False,
    )
    session_id = result.stdout.strip().rpartition("\t")[2]

    if session_id:
        subprocess.run([sys.executable, FOCUS_SCRIPT, session_id], check=False)


if __name__ == "__main__":
    main()
