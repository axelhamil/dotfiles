import json
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.realpath(__file__))))

from kitty_link import KittyTarget, kitten, resolve_target  # noqa: E402
from workspace import AgentRecord, read_record, record_path  # noqa: E402


def kitty_pid(socket: str) -> int:
    suffix = socket.rsplit("-", 1)[-1]
    return int(suffix) if suffix.isdigit() else 0


def window_title(target: KittyTarget) -> str:
    result = kitten(target.socket, "ls", "--match", f"id:{target.window_id}")

    try:
        os_windows = json.loads(result.stdout)
    except ValueError:
        return ""

    return next((window["title"] for os_window in os_windows for tab in os_window["tabs"] for window in tab["windows"]), "")


def hyprland_address(pid: int, title: str) -> str:
    output = subprocess.run(["hyprctl", "clients", "-j"], capture_output=True, text=True, check=False).stdout
    clients = [client for client in json.loads(output or "[]") if client["pid"] == pid]
    exact = next((client for client in clients if client["title"] == title), None)
    chosen = exact or (clients[0] if clients else None)
    return chosen["address"] if chosen else ""


def raise_os_window(target: KittyTarget) -> None:
    kitten(target.socket, "focus-window", "--match", f"id:{target.window_id}")

    address = hyprland_address(kitty_pid(target.socket), window_title(target))
    if address:
        subprocess.run(["hyprctl", "eval", f'hl.dispatch(hl.dsp.focus({{ window = "address:{address}" }}))'], capture_output=True, check=False)


def find_target(record: AgentRecord) -> KittyTarget | None:
    if record.tmux_pane:
        return resolve_target(record.tmux_pane)

    if record.kitty_socket:
        return KittyTarget(record.kitty_socket, record.kitty_window)

    return None


def focus(record: AgentRecord) -> None:
    if record.tmux_pane:
        subprocess.run(["tmux", "select-window", "-t", record.tmux_pane], check=False)
        subprocess.run(["tmux", "select-pane", "-t", record.tmux_pane], check=False)

    target = find_target(record)
    if target is not None:
        raise_os_window(target)
        return

    if record.tmux_session:
        subprocess.Popen(["kitty", "--single-instance", "tmux", "attach-session", "-t", record.tmux_session], start_new_session=True)


def main() -> None:
    record = read_record(record_path(sys.argv[1]))
    if record is not None:
        focus(record)


if __name__ == "__main__":
    main()
