# Ollama aliases & functions (via fabric + ollama)

# Quick ask — one-shot question
ask() {
  ollama run mistral-nemo "$*"
}

# Fix spelling/grammar (French)
fix() {
  if [ -t 0 ]; then
    echo "$*" | fabric -p fix_typos
  else
    fabric -p fix_typos
  fi
}

# Improve writing style
improve() {
  if [ -t 0 ]; then
    echo "$*" | fabric -p improve_writing
  else
    fabric -p improve_writing
  fi
}

# Summarize text
resume() {
  if [ -t 0 ]; then
    echo "$*" | fabric -p create_summary
  else
    fabric -p create_summary
  fi
}

# Generate a title from text
gentitle() {
  if [ -t 0 ]; then
    echo "$*" | ollama run mistral-nemo "Génère un titre court et percutant pour ce texte. Réponds uniquement avec le titre, sans guillemets :"
  else
    ollama run mistral-nemo "Génère un titre court et percutant pour ce texte. Réponds uniquement avec le titre, sans guillemets :"
  fi
}

# Translate (auto-detect direction)
translate() {
  if [ -t 0 ]; then
    echo "$*" | fabric -p translate
  else
    fabric -p translate
  fi
}

# Translate FR -> EN
tren() {
  if [ -t 0 ]; then
    echo "$*" | ollama run mistral-nemo "Traduis ce texte en anglais. Réponds uniquement avec la traduction :"
  else
    ollama run mistral-nemo "Traduis ce texte en anglais. Réponds uniquement avec la traduction :"
  fi
}

# Translate EN -> FR
trfr() {
  if [ -t 0 ]; then
    echo "$*" | ollama run mistral-nemo "Traduis ce texte en français. Réponds uniquement avec la traduction :"
  else
    ollama run mistral-nemo "Traduis ce texte en français. Réponds uniquement avec la traduction :"
  fi
}

# Generate commit message from staged diff
commit-msg() {
  git diff --cached | fabric -p create_git_diff_commit
}

# Chat TUI
alias chat="oterm"
