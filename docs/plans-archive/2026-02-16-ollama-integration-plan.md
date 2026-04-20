# Ollama Integration — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Intégrer Ollama dans le workflow quotidien avec fabric (CLI), oterm (TUI), Immersive Translate (pages web), et Voxtype (dictée vocale).

**Architecture:** Ollama comme serveur central (systemd), VRAM libérée après chaque usage (keep_alive=30s). 3 modèles Mistral (nemo 12b, codestral 22b, small 24b). Outils qui tapent l'API localhost:11434.

**Tech Stack:** Ollama, fabric (Go/AUR), oterm (Python/uvx), Voxtype (AUR), Immersive Translate (Brave extension), ZSH functions.

---

### Task 1: Configurer Ollama systemd (env vars)

**Files:**
- Create: `/etc/systemd/system/ollama.service.d/override.conf` (via `sudo systemctl edit ollama`)

**Context:** Ne PAS modifier `/etc/systemd/system/ollama.service` directement — utiliser un drop-in override pour survivre aux updates d'Ollama.

**Step 1: Créer le drop-in override**

```bash
sudo mkdir -p /etc/systemd/system/ollama.service.d
```

Écrire dans `/etc/systemd/system/ollama.service.d/override.conf` :

```ini
[Service]
Environment="OLLAMA_KEEP_ALIVE=30s"
Environment="OLLAMA_ORIGINS=*"
```

**Step 2: Recharger et redémarrer**

```bash
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

**Step 3: Vérifier**

```bash
systemctl show ollama --property=Environment
```

Expected: Les 3 `Environment=` (PATH original + les 2 nouveaux).

```bash
curl -s http://localhost:11434/api/version | jq .
```

Expected: Réponse JSON avec la version Ollama.

---

### Task 2: Pull des modèles Mistral

**Step 1: Pull mistral-nemo (daily driver, ~7 GB)**

```bash
ollama pull mistral-nemo
```

**Step 2: Pull codestral (code, ~13 GB)**

```bash
ollama pull codestral
```

**Step 3: Pull mistral-small (heavy reasoning, ~14 GB)**

```bash
ollama pull mistral-small
```

**Step 4: Vérifier**

```bash
ollama list
```

Expected: 3 modèles listés.

**Step 5: Test rapide**

```bash
ollama run mistral-nemo "Dis bonjour en une phrase."
```

Expected: Réponse en français, puis le modèle se décharge de la VRAM après 30s.

Vérifier le déchargement :

```bash
sleep 35 && nvidia-smi --query-gpu=memory.used --format=csv,noheader
```

Expected: VRAM retombée à ~300-500 MB (Ollama idle).

---

### Task 3: Installer fabric (CLI)

**Step 1: Installer via AUR**

```bash
yay -S fabric
```

Si pas dispo dans AUR, installer via le script officiel :

```bash
curl -fsSL https://raw.githubusercontent.com/danielmiessler/fabric/main/scripts/installer/install.sh | bash
```

**Step 2: Configurer fabric avec Ollama**

```bash
fabric --setup
```

Pendant le setup :
- Quand il demande un provider : sélectionner **Ollama**
- URL : `http://localhost:11434`
- Default model : `mistral-nemo`

**Step 3: Vérifier**

```bash
echo "Bonjour, comment ça va ?" | fabric -p summarize
```

Expected: Réponse de mistral-nemo via fabric.

```bash
fabric --listpatterns | head -20
```

Expected: Liste des patterns disponibles.

**Step 4: Tester des patterns utiles**

```bash
echo "j'ai manger des pomme hier soir avec mon ami" | fabric -p improve_writing
```

Expected: Texte corrigé avec bonne orthographe.

---

### Task 4: Installer oterm (TUI)

**Step 1: Installer via uvx**

```bash
uvx oterm
```

Note : `uvx` exécute directement. Pour installer de façon permanente :

```bash
uv tool install oterm
```

**Step 2: Lancer et vérifier**

```bash
oterm
```

Expected: TUI qui se lance, montre les modèles Ollama disponibles. Quitter avec Ctrl+C.

---

### Task 5: Créer module ZSH pour Ollama

**Files:**
- Create: `~/.dotfiles/zsh/.config/zsh/ollama.zsh`
- Modify: `~/.dotfiles/zsh/.zshrc` (sourcer le nouveau module)

**Step 1: Vérifier la structure du .zshrc**

Lire `~/.dotfiles/zsh/.zshrc` pour voir comment les modules sont sourcés, afin de suivre le même pattern.

**Step 2: Créer le fichier ollama.zsh**

```bash
# ~/.dotfiles/zsh/.config/zsh/ollama.zsh
# Ollama aliases & functions

# Quick ask — one-shot question
ask() {
  ollama run mistral-nemo "$*"
}

# Fix spelling/grammar (French)
fix() {
  echo "$*" | fabric -p improve_writing
}

# Generate a title from text
title() {
  echo "$*" | ollama run mistral-nemo "Génère un titre court et percutant pour ce texte. Réponds uniquement avec le titre, sans guillemets :"
}

# Summarize text
resume() {
  echo "$*" | fabric -p summarize
}

# Translate FR -> EN
tren() {
  echo "$*" | ollama run mistral-nemo "Traduis ce texte en anglais. Réponds uniquement avec la traduction :"
}

# Translate EN -> FR
trfr() {
  echo "$*" | ollama run mistral-nemo "Traduis ce texte en français. Réponds uniquement avec la traduction :"
}

# Generate commit message from staged diff
commit-msg() {
  git diff --cached | ollama run codestral "Génère un message de commit concis (conventionnal commits, en anglais) pour ce diff. Réponds uniquement avec le message :"
}

# Chat TUI
alias chat="oterm"
```

**Step 3: Sourcer dans .zshrc**

Ajouter la ligne source pour `ollama.zsh` en suivant le pattern existant des autres modules.

**Step 4: Restow et recharger**

```bash
cd ~/.dotfiles && stow zsh
source ~/.zshrc
```

**Step 5: Vérifier**

```bash
ask "Quelle est la capitale de la France ?"
```

Expected: "Paris" (ou une phrase contenant Paris).

```bash
fix "j'ai manger des pomme hier"
```

Expected: Texte corrigé.

---

### Task 6: Configurer Immersive Translate dans Brave

**Step 1: Installer l'extension**

Ouvrir dans Brave : `https://chromewebstore.google.com/detail/immersive-translate/bpoadfkcbjbfhfodiogcnhhhpibjhbnh`

Cliquer "Add to Brave".

**Step 2: Configurer le backend Ollama**

Dans les settings d'Immersive Translate :
1. Translation Service → Custom (OpenAI compatible)
2. API URL : `http://localhost:11434/v1/chat/completions`
3. API Key : `ollama` (n'importe quoi, Ollama n'authentifie pas)
4. Model : `mistral-nemo`

**Step 3: Vérifier**

Ouvrir une page en anglais, activer Immersive Translate. Vérifier que la traduction bilingue s'affiche avec mistral-nemo.

> Note : cette task est manuelle (browser GUI). L'utilisateur doit la faire lui-même.

---

### Task 7: Installer Voxtype (dictée vocale)

**Step 1: Vérifier la disponibilité AUR**

```bash
yay -Ss voxtype
```

Si pas dans AUR, installer via la méthode alternative (pip, cargo, ou build from source — à déterminer selon ce que yay retourne).

**Step 2: Télécharger le modèle Whisper**

```bash
voxtype download large-v3-turbo
```

Si `voxtype` n'est pas dispo en AUR, alternative avec **whisper.cpp** :

```bash
yay -S whisper.cpp-cuda
```

Puis télécharger le modèle :

```bash
whisper-cpp-download-ggml-model large-v3-turbo
```

**Step 3: Configurer le keybind Hyprland**

Modifier `~/.dotfiles/hypr/.config/hypr/hyprland.conf`.

Ajouter après la section screenshots (ligne ~353) :

```conf
# Dictée vocale (Voxtype push-to-talk)
bind = $mainMod SHIFT, D, exec, voxtype record start
bindr = $mainMod SHIFT, D, exec, voxtype record stop
```

Note : `SUPER+SHIFT+D` (D pour Dictation). `SUPER+V` est déjà pris (togglefloating).

**Step 4: Recharger Hyprland**

```bash
hyprctl reload
```

**Step 5: Tester**

Maintenir `SUPER+SHIFT+D`, parler, relâcher. Vérifier que le texte s'insère.

> Note : si Voxtype n'est pas dispo, on adaptera avec whisper-overlay ou une solution custom basée sur whisper.cpp + wtype.

---

### Task 8: Vérification finale et commit dotfiles

**Step 1: Vérifier tous les composants**

```bash
# Ollama
curl -s http://localhost:11434/api/version | jq .version

# Modèles
ollama list

# fabric
echo "test" | fabric -p summarize

# oterm
oterm --help

# ZSH functions
ask "test"

# VRAM libre
nvidia-smi --query-gpu=memory.used --format=csv,noheader
```

**Step 2: Commit des dotfiles**

```bash
cd ~/.dotfiles
git add zsh/.config/zsh/ollama.zsh hypr/.config/hypr/hyprland.conf
git commit -m "feat: add Ollama integration (aliases, Voxtype keybind)"
```

**Step 3: Vérifier le stow**

```bash
ls -la ~/.config/zsh/ollama.zsh
ls -la ~/.config/hypr/hyprland.conf
```

Expected: Symlinks pointant vers `~/.dotfiles/`.
