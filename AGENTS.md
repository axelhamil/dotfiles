# Dotfiles · macOS 2.0

This repository is the macOS machine config. Global agent rules live in `~/.agents/AGENTS.md` (stowed from `agents/.agents/AGENTS.md`).

- Never write app files into `$HOME`. The only zsh file there is `.zshenv`.
- Stow-style packages under `~/.dotfiles` → XDG dirs.
- Oh My Zsh → `~/.local/share/oh-my-zsh`. Git → `~/.config/git`.
- Original tree: branch `macos-legacy`. This tree: `macos-2.0`.
- Bootstrap: `./bootstrap.sh`. Optional packages: `aerospace`.
- Config only in git. Identity and secrets stay on the machine (`~/.config/git/local`, `~/.ssh`).
