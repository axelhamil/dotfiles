# Ollama aliases & functions

# Quick ask — one-shot question
ask() {
  ollama run mistral-nemo "$*"
}

# Fix spelling/grammar (French)
fix() {
  echo "$*" | ollama run mistral-nemo "Corrige l'orthographe et la grammaire de ce texte français. Réponds uniquement avec le texte corrigé, sans explication :"
}

# Generate a title from text (pipe or arg)
title() {
  if [ -t 0 ]; then
    echo "$*" | ollama run mistral-nemo "Génère un titre court et percutant pour ce texte. Réponds uniquement avec le titre, sans guillemets :"
  else
    ollama run mistral-nemo "Génère un titre court et percutant pour ce texte. Réponds uniquement avec le titre, sans guillemets :"
  fi
}

# Summarize text (pipe or arg)
resume() {
  if [ -t 0 ]; then
    echo "$*" | ollama run mistral-nemo "Résume ce texte en 2-3 phrases. Réponds uniquement avec le résumé :"
  else
    ollama run mistral-nemo "Résume ce texte en 2-3 phrases. Réponds uniquement avec le résumé :"
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
  git diff --cached | ollama run codestral "Generate a concise conventional commit message for this diff. Reply only with the commit message, no explanation :"
}

# Chat TUI
alias chat="oterm"
