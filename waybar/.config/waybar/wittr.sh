#!/bin/bash
# wittr.sh — Meteo pour waybar (wttr.in, francais, jq)
# Usage: wittr.sh <ville>

CITY="${1:-Romorantin-Lanthenay}"

# Fetch JSON data from wttr.in
DATA=$(curl -sf "https://wttr.in/${CITY}?format=j1&lang=fr" 2>/dev/null)
[ -z "$DATA" ] && jq -cn '{text: "--", tooltip: "Meteo indisponible"}' && exit 0

# Current conditions (French descriptions)
TEMP=$(echo "$DATA" | jq -r '.current_condition[0].temp_C')
FEELS=$(echo "$DATA" | jq -r '.current_condition[0].FeelsLikeC')
DESC=$(echo "$DATA" | jq -r '.current_condition[0].lang_fr[0].value')
HUMIDITY=$(echo "$DATA" | jq -r '.current_condition[0].humidity')
WIND_KMH=$(echo "$DATA" | jq -r '.current_condition[0].windspeedKmph')
WIND_DIR=$(echo "$DATA" | jq -r '.current_condition[0].winddir16Point')
UV=$(echo "$DATA" | jq -r '.current_condition[0].uvIndex')
VISIBILITY=$(echo "$DATA" | jq -r '.current_condition[0].visibility')
PRESSURE=$(echo "$DATA" | jq -r '.current_condition[0].pressure')
PRECIP=$(echo "$DATA" | jq -r '.current_condition[0].precipMM')
CLOUD=$(echo "$DATA" | jq -r '.current_condition[0].cloudcover')

# Nearest area
AREA=$(echo "$DATA" | jq -r '.nearest_area[0].areaName[0].value')
REGION=$(echo "$DATA" | jq -r '.nearest_area[0].region[0].value')

TEXT="${TEMP}C"

# Wind direction translation
case "$WIND_DIR" in
    N) VENT_DIR="Nord" ;; NNE) VENT_DIR="Nord-NE" ;; NE) VENT_DIR="Nord-Est" ;;
    ENE) VENT_DIR="Est-NE" ;; E) VENT_DIR="Est" ;; ESE) VENT_DIR="Est-SE" ;;
    SE) VENT_DIR="Sud-Est" ;; SSE) VENT_DIR="Sud-SE" ;; S) VENT_DIR="Sud" ;;
    SSW) VENT_DIR="Sud-SO" ;; SW) VENT_DIR="Sud-Ouest" ;; WSW) VENT_DIR="Ouest-SO" ;;
    W) VENT_DIR="Ouest" ;; WNW) VENT_DIR="Ouest-NO" ;; NW) VENT_DIR="Nord-Ouest" ;;
    NNW) VENT_DIR="Nord-NO" ;; *) VENT_DIR="$WIND_DIR" ;;
esac

# Build tooltip with real newlines (jq handles escaping)
TT="${AREA}, ${REGION}"$'\n'
TT+="${DESC}"$'\n'
TT+="---"$'\n'
TT+="Temperature: ${TEMP}C (ressenti ${FEELS}C)"$'\n'
TT+="Vent: ${WIND_KMH} km/h ${VENT_DIR}"$'\n'
TT+="Humidite: ${HUMIDITY}% | Couverture nuageuse: ${CLOUD}%"$'\n'
TT+="Pression: ${PRESSURE} hPa | Precipitations: ${PRECIP} mm"$'\n'
TT+="Visibilite: ${VISIBILITY} km | UV: ${UV}"

# 3-day forecast with hourly detail
TT+=$'\n'$'\n'"Previsions"$'\n'"---"

for i in 0 1 2; do
    DATE=$(echo "$DATA" | jq -r ".weather[$i].date")
    MAX=$(echo "$DATA" | jq -r ".weather[$i].maxtempC")
    MIN=$(echo "$DATA" | jq -r ".weather[$i].mintempC")
    SUNRISE=$(echo "$DATA" | jq -r ".weather[$i].astronomy[0].sunrise")
    SUNSET=$(echo "$DATA" | jq -r ".weather[$i].astronomy[0].sunset")
    DAY=$(date -d "$DATE" "+%A" 2>/dev/null || echo "$DATE")
    DAY="${DAY^}"

    MATIN=$(echo "$DATA" | jq -r ".weather[$i].hourly[3].lang_fr[0].value")
    APREM=$(echo "$DATA" | jq -r ".weather[$i].hourly[5].lang_fr[0].value")
    SOIR=$(echo "$DATA" | jq -r ".weather[$i].hourly[7].lang_fr[0].value")
    TEMP_M=$(echo "$DATA" | jq -r ".weather[$i].hourly[3].tempC")
    TEMP_A=$(echo "$DATA" | jq -r ".weather[$i].hourly[5].tempC")
    TEMP_S=$(echo "$DATA" | jq -r ".weather[$i].hourly[7].tempC")
    RAIN=$(echo "$DATA" | jq -r ".weather[$i].hourly[5].chanceofrain")

    TT+=$'\n'"${DAY} (${MIN}/${MAX}C) - Pluie: ${RAIN}%"$'\n'
    TT+="  Matin: ${TEMP_M}C ${MATIN}"$'\n'
    TT+="  Aprem: ${TEMP_A}C ${APREM}"$'\n'
    TT+="  Soir: ${TEMP_S}C ${SOIR}"$'\n'
    TT+="  Soleil: ${SUNRISE} - ${SUNSET}"
done

jq -cn --arg text "$TEXT" --arg tooltip "$TT" \
    '{text: $text, tooltip: $tooltip}'
