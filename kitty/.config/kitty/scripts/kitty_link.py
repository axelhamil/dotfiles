import json
import os
import re
import subprocess
import sys
from dataclasses import dataclass

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.realpath(__file__))))

from workspace import all_records, live_records, remove_record, worst_state  # noqa: E402

CLAUDE_VAR = "claude"
INSTANCE_SOCKET = re.compile(r"@kitty-\d+")


@dataclass(frozen=True)
class KittyTarget:
    socket: str
    window_id: int

    def is_focused(self) -> bool:
        for os_window in ls(self.socket):
            for tab in os_window["tabs"]:
                for window in tab["windows"]:
                    if window["id"] == self.window_id:
                        return os_window["is_focused"] and window["is_focused"]
        return False


def kitten(socket: str, *args: str) -> subprocess.CompletedProcess:
    return subprocess.run(["kitten", "@", "--to", socket, *args], capture_output=True, text=True, check=False)


def ls(socket: str) -> list[dict]:
    result = kitten(socket, "ls")
    if result.returncode != 0:
        return []

    try:
        return json.loads(result.stdout)
    except ValueError:
        return []


def sockets() -> list[str]:
    found = []
    preferred = os.environ.get("KITTY_LISTEN_ON", "")
    if preferred:
        found.append(preferred)

    try:
        with open("/proc/net/unix") as f:
            lines = f.read().splitlines()[1:]
    except OSError:
        return found

    for line in lines:
        path = line.rsplit(" ", 1)[-1]
        socket = f"unix:{path}"
        if INSTANCE_SOCKET.fullmatch(path) and socket not in found:
            found.append(socket)

    return found


def all_windows():
    for socket in sockets():
        for os_window in ls(socket):
            for tab in os_window["tabs"]:
                for window in tab["windows"]:
                    yield socket, window


def tmux_client_pids(pane: str) -> set[int]:
    session = subprocess.run(["tmux", "display-message", "-p", "-t", pane, "#{session_name}"], capture_output=True, text=True, check=False).stdout.strip()
    output = subprocess.run(["tmux", "list-clients", "-t", session, "-F", "#{client_pid}"], capture_output=True, text=True, check=False).stdout
    return {int(pid) for pid in output.split() if pid.isdigit()}


def window_pids(window: dict) -> set[int]:
    return {window.get("pid", 0), *(process["pid"] for process in window.get("foreground_processes") or [])}


def resolve_target(tmux_pane: str = "") -> KittyTarget | None:
    if not tmux_pane:
        window_id = os.environ.get("KITTY_WINDOW_ID", "")
        socket = os.environ.get("KITTY_LISTEN_ON", "")
        return KittyTarget(socket, int(window_id)) if window_id.isdigit() and socket else None

    client_pids = tmux_client_pids(tmux_pane)
    if not client_pids:
        return None

    for socket, window in all_windows():
        if window_pids(window) & client_pids:
            return KittyTarget(socket, window["id"])

    return None


def reset_dead(record) -> None:
    if record.tmux_pane:
        subprocess.run(["tmux", "set-option", "-p", "-u", "-t", record.tmux_pane, "@claude"], capture_output=True, check=False)

    if record.kitty_socket:
        target = KittyTarget(record.kitty_socket, record.kitty_window)
        states = [other.state for other in live_records() if other.kitty_socket == target.socket and other.kitty_window == target.window_id]
        set_claude_var(target, worst_state(states))


def prune_dead() -> None:
    for record in all_records():
        if not record.is_alive():
            remove_record(record.session_id)
            reset_dead(record)


def set_claude_var(target: KittyTarget, state: str) -> None:
    assignment = f"{CLAUDE_VAR}={state}" if state else CLAUDE_VAR
    kitten(target.socket, "set-user-vars", "--match", f"id:{target.window_id}", assignment)
