#!/bin/bash
# Script pour changer de wallpaper avec awww

WALLPAPER_DIR="$HOME/Images/wallpapers"
TRANSITION_TYPE="${1:-wipe}"
TRANSITION_FPS=60
TRANSITION_DURATION=2

# Si un fichier est passé en argument, l'utiliser
if [[ -f "$1" ]]; then
    awww img "$1" \
        --transition-type "$TRANSITION_TYPE" \
        --transition-fps $TRANSITION_FPS \
        --transition-duration $TRANSITION_DURATION
    exit 0
fi

# Sinon, sélectionner aléatoirement un wallpaper
if [[ -d "$WALLPAPER_DIR" ]]; then
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | shuf -n 1)

    if [[ -n "$WALLPAPER" ]]; then
        awww img "$WALLPAPER" \
            --transition-type "$TRANSITION_TYPE" \
            --transition-fps $TRANSITION_FPS \
            --transition-duration $TRANSITION_DURATION
        echo "Wallpaper changé: $WALLPAPER"
    else
        echo "Aucun wallpaper trouvé dans $WALLPAPER_DIR"
        exit 1
    fi
else
    echo "Dossier $WALLPAPER_DIR non trouvé"
    exit 1
fi
