#!/usr/bin/env bash
# Legt einen neuen Mod auf Basis von Philip1302-ExtremeStarter an.
# Nutzung: scripts/new-mod.sh <Namespace> <ModName>
set -euo pipefail

cd "$(dirname "$0")/.."

if [ $# -ne 2 ]; then
    echo "Nutzung: $0 <Namespace> <ModName>"
    exit 1
fi

ns="$1"
name="$2"
for part in "$ns" "$name"; do
    if ! [[ "$part" =~ ^[A-Za-z0-9_]{3,}$ ]]; then
        echo "Ungültig: '$part' (nur A-Z, a-z, 0-9, _ und mindestens 3 Zeichen)"
        exit 1
    fi
done

template="mods-unpacked/Philip1302-ExtremeStarter"
target="mods-unpacked/$ns-$name"
[ -e "$target" ] && { echo "Existiert bereits: $target"; exit 1; }

cp -r "$template" "$target"
find "$target" -mindepth 2 -type f ! -name '.gitkeep' -delete

jq --arg ns "$ns" --arg name "$name" \
    '.namespace = $ns | .name = $name | .version_number = "0.1.0" | .description = "" | .extra.godot.authors = [$ns]' \
    "$template/manifest.json" > "$target/manifest.json"
sed -i "s/Philip1302-ExtremeStarter/$ns-$name/g; s/philip1302_extreme/${name,,}/g" "$target/mod_main.gd"

echo "Angelegt: $target"
