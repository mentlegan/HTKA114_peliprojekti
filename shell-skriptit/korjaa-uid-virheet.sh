#!/usr/bin/env bash

# Tarkistetaan, löytyykö seuraavia binäärejä.
if ! which readlink dirname find perl > /dev/null; then
    echo "Tarvittavia binäärejä ei löytynyt, lopetetaan..."
    exit 1
fi

cat << EOF
VAROITUS: Muokkaa projektin jokaista tscn ja tres-tiedostoa.
Varmista, että viimeisimmät muokkaukset on tallennettu repoon ennen suoritusta.

Suoritetaanko skripti? (y/N)
EOF

# Suoritetaan skripti pelkästään, jos ollaan vastattu tarkalleen 'y' tai 'Y'
read vastaus
if [[ "$vastaus" == y || "$vastaus" == Y ]]; then
    # Absoluuttinen polku suoritettuun skriptiin
    skriptin_polku="$(readlink -f "$0")"

    # Projektin root-kansion absoluuttinen polku
    projektikansion_polku="$(readlink -f "$(dirname "$skriptin_polku")/..")"

    if [[ ! -d "$projektikansion_polku/.git/" ]]; then
        # Jos .git kansiota ei ole root-kansiossa, skripti on väärässä polussa
        echo "Skripti on väärässä polussa: '$skriptin_polku', lopetetaan..."
        exit 1
    fi

    # Komento Godotin issue-listalta:
    # https://github.com/godotengine/godot/issues/68661#issuecomment-1372115461
    find "$projektikansion_polku/scenet/" \
        -name \*.tscn \
        -exec perl -i -pe 's/ ?uid=\"uid:\/\/[a-zA-Z0-9]+?\"//g' {} \;

    find "$projektikansion_polku/tres-tiedostot/" \
        -name \*.tres \
        -exec perl -i -pe 's/ ?uid=\"uid:\/\/[a-zA-Z0-9]+?\"//g' {} \;
fi
