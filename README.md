# Dotfiles · macOS 2.0

Clean-home setup for Apple Silicon. The old tree is frozen on [`macos-legacy`](https://github.com/axelhamil/dotfiles/tree/macos-legacy). Arch Linux lives on [`arch`](https://github.com/axelhamil/dotfiles/tree/arch).

**Rule:** `$HOME` stays empty of app dotfiles. One exception: `~/.zshenv` (sets `ZDOTDIR`).

| What | Where |
|------|--------|
| This repo | `~/.dotfiles` |
| Oh My Zsh | `~/.local/share/oh-my-zsh` |
| Zsh | `~/.config/zsh` (`ZDOTDIR`) |
| Git | `~/.config/git` |
| Kitty | `~/.config/kitty` (Catppuccin Mocha, same as Arch) |
| Node / runtimes | mise → `~/.local/share/mise` |
| PATH (Homebrew) | `$ZDOTDIR/path.zsh` — login via `.zprofile` (after `path_helper`), also interactive shells |
| Agent rules | `~/.agents/AGENTS.md` |

---

## Setup

```bash
git clone -b macos-2.0 git@github.com:axelhamil/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

Optional: `./bootstrap.sh zsh git npm mise agents kitty aerospace`

Toolchain (when Homebrew is installed):

```bash
brew bundle --file=~/.dotfiles/Brewfile
```

Copy `git/.config/git/local.example` → `~/.config/git/local` if it was not created.

---

## Layout

```
AGENTS.md        # this repo (Cursor / Codex / Copilot)
CLAUDE.md        # @AGENTS.md — Claude Code
agents/          # stowed to ~/.agents (global) + Codex/Claude adapters
bootstrap.sh
Brewfile
zsh/ git/ npm/ mise/ kitty/
aerospace/       # optional
scripts/macos-tweaks.sh
```

Cursor User Rules (one line, for workspaces that are not this repo):

```
Always follow ~/.agents/AGENTS.md
```

---

## Secrets

Nothing sensitive belongs in this repo. `.gitignore` drops keys, env files, tokens, cloud creds.

Local CI (enabled by `./bootstrap.sh`):

```bash
python3 scripts/check-leaks.py          # whole tree (also runs on git push)
python3 scripts/check-leaks.py --staged # index (also runs on git commit)
python3 scripts/test-leaks.py           # gitignore + hooks + history hole
```

Hooks live in `.githooks/` (`core.hooksPath`). Do not skip them.

---

## Requirements

- macOS + zsh
- Oh My Zsh + powerlevel10k (bootstrap)
- FiraCode Nerd Font in the terminal (Brewfile cask, or install the TTF files)
- Homebrew + Brewfile tools (optional, for eza/bat/mise/…)
