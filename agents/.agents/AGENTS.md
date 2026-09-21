# Global agent instructions

Canonical file for every coding agent (Cursor, Claude Code, Codex, Gemini, …).
Tool-specific wrappers only import this file. Do not duplicate these rules elsewhere.

Chat in French. Write all code, commits, and file contents in English.

## Zero $HOME pollution

Never create files or directories in `$HOME`.

Allowed exceptions only:

- `~/.zshenv` — zsh bootstrap (XDG + `ZDOTDIR` only)
- `~/.ssh` — OpenSSH is hardcoded
- `~/.agents` — this file (global AGENTS.md + skills)
- `~/.cursor`, `~/.claude`, `~/.codex` — tool homes (thin wrappers only)
- macOS: `~/Library`, `~/Desktop`, `~/.Trash`, `~/.DS_Store`, `~/.CFUserTextEncoding`

Everything else uses XDG:

| Kind | Path |
|------|------|
| Config | `~/.config` |
| Data | `~/.local/share` |
| State / history | `~/.local/state` |
| Cache | `~/.cache` |
| Binaries | `~/.local/bin` |
| Dotfiles repo | `~/.dotfiles` |

Do:

- `ZDOTDIR=$XDG_CONFIG_HOME/zsh` — never `~/.zshrc` / `~/.p10k.zsh`
- Oh My Zsh → `$XDG_DATA_HOME/oh-my-zsh`
- Git → `~/.config/git` — never `~/.gitconfig`
- Runtimes → mise — never `~/.nvm` / `~/.pyenv`
- macOS PATH in `$ZDOTDIR/.zprofile` (after `path_helper`)
- Backups → `$XDG_STATE_HOME/dotfiles-backup-*`

Do not create: `~/.zshrc`, `~/.oh-my-zsh`, `~/.nvm`, `~/.npm`, `~/.gitconfig`, `~/dotfiles`, `~/AGENTS.md`.

## Stack

TypeScript only. React, Next.js, Fastify, Drizzle ORM.

DDD + Clean / Hexagonal architecture. TDD when possible, otherwise SOLID.

Services talk to repositories. Controllers import services, never repositories.
Presenter pattern in controllers. Type responses with `ReturnType<typeof presenter>`.

Prefer:

```
if (condition)
  doSomething()
```

Blank lines between logical groups. Minimal code.

## Git

Only commit when asked. Never `git config`, never force-push to main, never `--no-verify`.

## Secrets

This repo is public-safe config only. Never add:

- SSH / GPG keys, tokens, cookies, `.env`, `.netrc`, `hosts.yml`
- Git identity: email and signing key live in `~/.config/git/local` (untracked)
- Tool auth: `~/.codex/auth.json`, Claude/Cursor local settings

If an installer writes a secret into `$HOME` or this repo, move it out or gitignore it. Do not commit it.
