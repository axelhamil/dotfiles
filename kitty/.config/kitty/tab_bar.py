import os
import sys

from kitty.fast_data_types import Screen, get_boss, wcswidth
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb, draw_tab_with_powerline

sys.path.insert(0, os.path.dirname(__file__))

from workspace import (  # noqa: E402
    CLAUDE_VAR,
    ICON_BRANCH,
    ICON_FOLDER,
    ICON_WORKTREE,
    STATE_COLORS,
    STATE_ICONS,
    locate,
    worst_state,
)

RADAR_STATES = ("waiting", "done")


def sgr_fg(color: int) -> str:
    return f"\x1b[38:2:{color >> 16 & 255}:{color >> 8 & 255}:{color & 255}m"


def claude_state(tab) -> str:
    return worst_state(window.user_vars.get(CLAUDE_VAR, "") for window in tab)


def tab_location(tab):
    return locate(tab.get_cwd_of_active_window(oldest=True) or "")


def build_title(tab, location, index: int, is_active: bool, inactive_fg: int) -> str:
    color = location.color() if location.is_repo else inactive_fg
    state = claude_state(tab)
    parts = [str(index)]

    if state:
        icon = STATE_ICONS[state]
        parts.append(icon if is_active else f"{sgr_fg(STATE_COLORS[state])}{icon}{sgr_fg(color)}")

    if location.is_repo:
        parts.append(location.project)
        parts.append(f"{ICON_WORKTREE} {location.worktree}" if location.worktree else "")
        parts.append(f"{ICON_BRANCH} {location.branch}")
    else:
        parts.append(f"{ICON_FOLDER} {location.project}")

    return " ".join(part for part in parts if part)


def with_project_color(tab_data: TabBarData, location) -> TabBarData:
    if not location.is_repo:
        return tab_data

    color = location.color()
    return tab_data._replace(active_bg=color, inactive_fg=color)


def colored(tab_data: TabBarData | None) -> TabBarData | None:
    live_tab = get_boss().tab_for_id(tab_data.tab_id) if tab_data else None
    if live_tab is None:
        return tab_data

    return with_project_color(tab_data, tab_location(live_tab))


def radar(active_session: str) -> list[tuple[str, int]]:
    sessions: dict[str, list[str]] = {}

    for window in get_boss().all_windows:
        state = window.user_vars.get(CLAUDE_VAR, "")
        session = window.created_in_session_name
        if state in RADAR_STATES and session and session != active_session:
            sessions.setdefault(session, []).append(state)

    entries = []
    for session, states in sorted(sessions.items()):
        state = worst_state(states)
        entries.append((f"{STATE_ICONS[state]} {session}", STATE_COLORS[state]))

    return entries


def draw_radar(draw_data: DrawData, screen: Screen, active_session: str, tabs_end: int) -> None:
    entries = radar(active_session)
    if not entries:
        return

    text_width = sum(wcswidth(label) + 2 for label, _ in entries)
    start = screen.columns - text_width
    if start <= tabs_end + 1:
        return

    screen.cursor.x = start
    screen.cursor.bg = as_rgb(int(draw_data.default_bg))
    for label, color in entries:
        screen.cursor.fg = as_rgb(color)
        screen.draw(f" {label} ")


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_tab_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    live_tab = get_boss().tab_for_id(tab.tab_id)

    if live_tab is not None:
        location = tab_location(live_tab)
        title = build_title(live_tab, location, index, tab.is_active, int(draw_data.inactive_fg))
        tab = with_project_color(tab._replace(title=title), location)
        screen.cursor.bg = as_rgb(draw_data.tab_bg(tab))
        screen.cursor.fg = as_rgb(draw_data.tab_fg(tab))

    extra_data.next_tab = colored(extra_data.next_tab)

    end = draw_tab_with_powerline(draw_data, screen, tab, before, max_tab_length, index, is_last, extra_data)

    if is_last:
        draw_radar(draw_data, screen, tab.active_session_name, end)

    return end
