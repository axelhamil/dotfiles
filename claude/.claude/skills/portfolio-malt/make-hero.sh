#!/usr/bin/env bash
set -euo pipefail



W=1600; H=900
BG="#ffffff"; ENCRE="#0a0a0a"; SECOND="#525252"; BORDURE="#e5e5e5"
TITRE_FONT="SpaceGrotesk-Bold"
TEXTE_FONT="Inter-Medium"
MONO_FONT="Geist-Mono-Bold"

magick -list font | grep -q "Font: ${TITRE_FONT}$" || TITRE_FONT="Inter-Display-Bold"
magick -list font | grep -q "Font: ${MONO_FONT}$" || MONO_FONT="DejaVu-Sans-Mono-Bold"

compose() {
  local out="$1" shot="$2" eyebrow="$3" titre="$4" accent="$5"; shift 5
  local badges=("$@")
  local tmp; tmp="$(mktemp -d)"

  magick -size ${W}x${H} xc:"$BG" "$tmp/bg.png"

  magick "$shot" -resize 1010x570 \
    -bordercolor "$BORDURE" -border 1 \
    \( +clone -alpha extract \
       -draw 'fill black polygon 0,0 0,14 14,0 fill white circle 14,14 14,0' \
       \( +clone -flip \) -compose Multiply -composite \
       \( +clone -flop \) -compose Multiply -composite \) \
    -alpha off -compose CopyOpacity -composite "$tmp/shot.png"

  magick "$tmp/bg.png" \
    -fill "$accent" -draw "rectangle 0,0 ${W},7" \
    \( "$tmp/shot.png" -background "rgba(10,10,10,0.16)" -shadow 40x18+0+10 \) \
    -geometry +472+282 -composite \
    "$tmp/shot.png" -geometry +490+272 -composite \
    "$tmp/base.png"

  local badge_x=96 badge_y=300 badge_w=356 badge_h=72 gap=20
  local boxes=() labels=() puces=()
  local y=$badge_y
  for b in "${badges[@]}"; do
    boxes+=( -fill none -stroke "$BORDURE" -strokewidth 1.5
             -draw "roundrectangle ${badge_x},${y} $((badge_x+badge_w)),$((y+badge_h)) 12,12" )
    puces+=( -fill "$accent" -stroke none
             -draw "circle $((badge_x+28)),$((y+badge_h/2+2)) $((badge_x+33)),$((y+badge_h/2+2))" )
    labels+=( -font "$TEXTE_FONT" -pointsize 21 -fill "$ENCRE" -stroke none
              -annotate +$((badge_x+48))+$((y+badge_h/2+8)) "$b" )
    y=$((y + badge_h + gap))
  done

  magick "$tmp/base.png" \
    "${boxes[@]}" "${puces[@]}" \
    -gravity NorthWest \
    -font "$MONO_FONT" -pointsize 22 -fill "$accent" -stroke none \
    -annotate +96+140 "$eyebrow" \
    -font "$TITRE_FONT" -pointsize 62 -fill "$ENCRE" \
    -annotate +94+205 "$titre" \
    "${labels[@]}" \
    -font "$TEXTE_FONT" -pointsize 21 -fill "$SECOND" \
    -annotate +96+806 "${URL:-}" \
    -quality 94 "$out"

  rm -rf "$tmp"
  echo "$out"
}

usage() {
  cat <<'EOF'
Compose une image hero de portfolio Malt (1600x900), style editorial clair.

Usage:
  make-hero.sh -s <capture> -o <sortie.jpg> -e "<eyebrow>" -t "<titre>" -c "<#accent>" \
               -b "<badge>" [-b "<badge>" ...] [-u "<url affichee>"]

  -s  capture source          -o  fichier de sortie
  -e  sur-titre en mono       -t  titre principal
  -c  couleur accent du projet (filet haut + puces)
  -b  badge, repetable, 4 recommandes
  -u  url affichee en bas a gauche

Reprendre la couleur du projet presente, pas une palette generique.
Requiert ImageMagick 7. Utilise Space Grotesk et Inter si installees.
EOF
  exit "${1:-0}"
}

SHOT=""; OUT=""; EYEBROW=""; TITRE=""; ACCENT="#ff4d00"; URL=""; BADGES=()
while getopts "s:o:e:t:c:b:u:h" opt; do
  case "$opt" in
    s) SHOT="$OPTARG" ;; o) OUT="$OPTARG" ;; e) EYEBROW="$OPTARG" ;;
    t) TITRE="$OPTARG" ;; c) ACCENT="$OPTARG" ;; b) BADGES+=("$OPTARG") ;;
    u) URL="$OPTARG" ;; h) usage 0 ;; *) usage 1 ;;
  esac
done
[[ -z "$SHOT" || -z "$OUT" || -z "$TITRE" ]] && usage 1
[[ -f "$SHOT" ]] || { echo "Capture introuvable : $SHOT" >&2; exit 1; }

compose "$OUT" "$SHOT" "$EYEBROW" "$TITRE" "$ACCENT" "${BADGES[@]+"${BADGES[@]}"}"
