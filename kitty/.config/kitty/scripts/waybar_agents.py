import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.realpath(__file__))))

from kitty_link import prune_dead  # noqa: E402

from workspace import STATE_ICONS, STATE_PRIORITY, live_records, locate, state_rank, worst_state  # noqa: E402

SHOWN_STATES = ("waiting", "done", "running")


def tooltip_line(record) -> str:
    location = locate(record.cwd)
    parts = [location.project, location.worktree, location.branch]
    return f"{STATE_ICONS.get(record.state, '?')}  {' · '.join(part for part in parts if part)}"


def main() -> None:
    prune_dead()
    records = sorted(live_records(), key=lambda record: state_rank(record.state))

    if not records:
        print(json.dumps({"text": "", "tooltip": "Aucun agent Claude", "class": "none"}, ensure_ascii=False))
        return

    counts = {state: sum(record.state == state for record in records) for state in STATE_PRIORITY}
    text = "  ".join(f"{STATE_ICONS[state]} {counts[state]}" for state in SHOWN_STATES if counts[state])
    tooltip = "\n".join(tooltip_line(record) for record in records)
    tooltip += "\n\nClic : choisir un agent"

    print(json.dumps({"text": text or f"{STATE_ICONS['idle']} {len(records)}", "tooltip": tooltip, "class": worst_state(record.state for record in records)}, ensure_ascii=False))


if __name__ == "__main__":
    main()
