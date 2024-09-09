#!/usr/bin/env bash

# Tarkistetaan, löytyykö seuraavia binäärejä.
if ! which find perl readlink grep column > /dev/null; then
    echo "Tarvittavia binäärejä ei löytynyt, lopetetaan..."
    exit 1
fi

# Tulostaa assettien tiedostonimet, suhteellisena projektin root-kansioon
assettien_nimet () {
    find "$projektikansion_polku"/{audio,grafiikka} \
        -type f -not -name \*.import \
        | sed "s,^$projektikansion_polku/,,g"
}

# Tulostaa, mitä stdin:sta luettuja tiedostonimiä ei käytetä projektissa
kayttamattomat_assetit () {
    while read assetti; do
        if ! grep "\"res://$assetti\"" \
                "$projektikansion_polku/"{scenet,tres-tiedostot}/**.{tscn,tres} &> /dev/null; then
            echo "$assetti"
        fi
    done
}

# Absoluuttinen polku suoritettuun skriptiin
skriptin_polku="$(readlink -f "$0")"

# Projektin root-kansion absoluuttinen polku
projektikansion_polku="$(readlink -f "$(dirname "$skriptin_polku")/..")"

if [[ ! -d "$projektikansion_polku/.git/" ]]; then
    # Jos .git kansiota ei ole root-kansiossa, skripti on väärässä polussa
    echo "Skripti on väärässä polussa: '$skriptin_polku', lopetetaan..."
    exit 1
fi

assettien_nimet | kayttamattomat_assetit | column
