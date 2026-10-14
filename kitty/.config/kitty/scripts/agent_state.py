import json
import os
import subprocess
import sys
import time
import zlib

sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.realpath(__file__))))

from kitty_link import KittyTarget, prune_dead, resolve_target, set_claude_var  # noqa: E402
from workspace import AgentRecord, live_records, locate, read_record, record_lock, record_path, remove_record, worst_state, write_record  # noqa: E402

WAYBAR_SIGNAL = "-RTMIN+12"
NOTIFY_TIMEOUT_MS = 15000
FOCUS_SCRIPT = os.path.join(os.path.dirname(os.path.realpath(__file__)), "focus_agent.py")


def claude_pid() -> int:
    pid = os.getppid()

    while pid > 1:
        try:
            with open(f"/proc/{pid}/comm") as f:
                if f.read().strip() == "claude":
                    return pid
            with open(f"/proc/{pid}/stat") as f:
                pid = int(f.read().rsplit(")", 1)[1].split()[1])
        except (OSError, ValueError, IndexError):
            return 0

    return 0


def tmux(*args: str) -> str:
    result = subprocess.run(["tmux", *args], capture_output=True, text=True, check=False)
    return result.stdout.strip()


def tmux_session(pane: str) -> str:
    return tmux("display-message", "-p", "-t", pane, "#{session_name}") if pane else ""


def notification_id(session_id: str) -> str:
    return str(zlib.crc32(session_id.encode()) & 0x7FFFFFFF)


def describe(cwd: str) -> str:
    location = locate(cwd)
    parts = [location.project, location.worktree, location.branch]
    return " · ".join(part for part in parts if part)


def is_seen(record: AgentRecord, target: KittyTarget | None) -> bool:
    if target is None or not target.is_focused():
        return False

    if not record.tmux_pane:
        return True

    return tmux("display-message", "-p", "-t", record.tmux_pane, "#{window_active}#{pane_active}") == "11"


def notify(record: AgentRecord, target: KittyTarget | None) -> None:
    replace_id = notification_id(record.session_id)

    if record.state not in ("waiting", "done") or is_seen(record, target):
        subprocess.run(["dunstify", "-C", replace_id], check=False)
        return

    title = "Claude attend ta réponse" if record.state == "waiting" else "Claude a terminé"
    urgency = "critical" if record.state == "waiting" else "normal"
    body = describe(record.cwd)
    if record.message:
        body = f"{body}\n{record.message}"

    action = subprocess.run(
        ["dunstify", "-a", "Claude Code", "-u", urgency, "-t", str(NOTIFY_TIMEOUT_MS), "-r", replace_id, "-A", "default,Ouvrir", title, body],
        capture_output=True,
        text=True,
        check=False,
    ).stdout.strip()

    if action == "default":
        subprocess.run([sys.executable, FOCUS_SCRIPT, record.session_id], check=False)


def window_state(target: KittyTarget) -> str:
    states = [record.state for record in live_records() if record.kitty_socket == target.socket and record.kitty_window == target.window_id]
    return worst_state(states)


def sync_kitty(record: AgentRecord, target: KittyTarget | None) -> None:
    if target is None:
        return

    set_claude_var(target, window_state(target))


def sync_tmux(record: AgentRecord) -> None:
    if record.tmux_pane:
        tmux("set-option", "-p", "-t", record.tmux_pane, "@claude", record.state)


def clear(session_id: str) -> None:
    with record_lock(session_id):
        record = read_record(record_path(session_id))
    remove_record(session_id)

    if record is None:
        return

    if record.tmux_pane:
        tmux("set-option", "-p", "-u", "-t", record.tmux_pane, "@claude")

    if record.kitty_socket:
        target = KittyTarget(record.kitty_socket, record.kitty_window)
        set_claude_var(target, window_state(target))

    subprocess.run(["dunstify", "-C", notification_id(session_id)], check=False)


def update(state: str, payload: dict, pid: int, fired_at: float) -> None:
    session_id = payload["session_id"]

    record = build_record(state, payload, pid, fired_at)

    with record_lock(session_id):
        previous = read_record(record_path(session_id))
        if previous is not None and previous.updated_at > fired_at:
            return

        write_record(record)

    target = KittyTarget(record.kitty_socket, record.kitty_window) if record.kitty_socket else None
    sync_kitty(record, target)
    sync_tmux(record)
    prune_dead()
    subprocess.run(["pkill", WAYBAR_SIGNAL, "-x", "waybar"], check=False)

    if previous is None or previous.state != state:
        notify(record, target)


def build_record(state: str, payload: dict, pid: int, fired_at: float) -> AgentRecord:
    pane = os.environ.get("TMUX_PANE", "")
    target = resolve_target(pane)

    return AgentRecord(
        session_id=payload["session_id"],
        state=state,
        cwd=payload.get("cwd") or os.getcwd(),
        pid=pid,
        updated_at=fired_at,
        message=payload.get("message", "") if state == "waiting" else "",
        tmux_session=tmux_session(pane),
        tmux_pane=pane,
        kitty_socket=target.socket if target else "",
        kitty_window=target.window_id if target else 0,
    )


def main() -> None:
    state = sys.argv[1]
    payload = json.load(sys.stdin)
    pid = claude_pid()
    fired_at = time.time()

    if os.fork() != 0:
        return

    os.setsid()
    devnull = os.open(os.devnull, os.O_RDWR)
    for descriptor in (0, 1, 2):
        os.dup2(devnull, descriptor)

    if state == "clear":
        clear(payload["session_id"])
    else:
        update(state, payload, pid, fired_at)


if __name__ == "__main__":
    main()
