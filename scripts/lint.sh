#!/usr/bin/env bash
# Lint + Formatprüfung aller GDScript-Dateien unter mods-unpacked/ und scripts/godot/ (gdtoolkit 3.x / Godot 3)
# Nutzung: scripts/lint.sh [--fix]
set -euo pipefail

cd "$(dirname "$0")/.."

mapfile -t files < <(find mods-unpacked scripts/godot -name '*.gd' -type f | sort)
if [ ${#files[@]} -eq 0 ]; then
    echo "Keine .gd-Dateien gefunden."
    exit 0
fi

if [ "${1:-}" = "--fix" ]; then
    gdformat "${files[@]}"
else
    gdformat --check "${files[@]}"
fi
gdlint "${files[@]}"

# Manifeste müssen gültiges JSON sein
for manifest in mods-unpacked/*/manifest.json; do
    jq empty "$manifest" || { echo "Ungültiges JSON: $manifest"; exit 1; }
done

echo "Lint OK (${#files[@]} Dateien)"
