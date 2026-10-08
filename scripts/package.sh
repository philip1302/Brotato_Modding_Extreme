#!/usr/bin/env bash
# Packt einen Mod als Workshop-/ModLoader-Zip: dist/<Namespace-Name>.zip
# Inhalt: mods-unpacked/<Namespace-Name>/...
# Nutzung: scripts/package.sh <Namespace-Name>   (ohne Argument: alle Mods)
set -euo pipefail

cd "$(dirname "$0")/.."
mkdir -p dist

package_mod() {
    local mod="$1"
    local src="mods-unpacked/$mod"
    local manifest="$src/manifest.json"

    [ -f "$src/mod_main.gd" ] || { echo "Fehlt: $src/mod_main.gd"; exit 1; }
    [ -f "$manifest" ] || { echo "Fehlt: $manifest"; exit 1; }

    local id
    id="$(jq -r '.namespace + "-" + .name' "$manifest")"
    if [ "$id" != "$mod" ]; then
        echo "Ordnername '$mod' passt nicht zu manifest.json ('$id')"
        exit 1
    fi

    local version
    version="$(jq -r '.version_number' "$manifest")"
    rm -f "dist/$mod.zip"
    zip -qr "dist/$mod.zip" "$src" -x '*.gitkeep'
    echo "dist/$mod.zip (v$version)"
}

if [ $# -ge 1 ]; then
    package_mod "$1"
else
    for d in mods-unpacked/*/; do
        package_mod "$(basename "$d")"
    done
fi
