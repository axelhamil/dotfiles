from typing import Any

from kitty.boss import Boss
from kitty.fast_data_types import current_focused_os_window_id
from kitty.window import Window

CLAUDE_VAR = "claude"


def redraw_tab_bars(boss: Boss) -> None:
    for tab_manager in boss.all_tab_managers:
        tab_manager.mark_tab_bar_dirty()


def is_seen(boss: Boss, window: Window) -> bool:
    return boss.active_window is window and current_focused_os_window_id() == window.os_window_id


def mark_seen(window: Window) -> None:
    if window.user_vars.get(CLAUDE_VAR) == "done":
        window.set_user_var(CLAUDE_VAR, "idle")


def on_set_user_var(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    if data["key"] != CLAUDE_VAR:
        return

    if is_seen(boss, window):
        mark_seen(window)

    redraw_tab_bars(boss)


def on_focus_change(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    if data["focused"]:
        mark_seen(window)


def on_close(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    if CLAUDE_VAR in window.user_vars:
        redraw_tab_bars(boss)
