#!/usr/bin/env bash
# Importiert das dekompilierte Projekt headless mit dem Container-Godot und listet Skript-/Ladefehler.
# Ersetzt nicht den Test im Windows-Editor, findet aber Parse-Fehler (z. B. fehlende Engine-Singletons) schnell.
# Nutzung: scripts/check-vanilla.sh
set -euo pipefail

cd "$(dirname "$0")/.."

[ -f vanilla/project.godot ] || { echo "Fehlt: vanilla/project.godot (Brotato zuerst mit GDRE dekompilieren)"; exit 1; }

log="$(mktemp)"
trap 'rm -f "$log"' EXIT

# --editor --quit: Ressourcen importieren und alle Skripte einmal parsen, dann beenden
timeout 900 godot --path vanilla --editor --quit --no-window >"$log" 2>&1 || true

grep -E "SCRIPT ERROR|Parse Error|ERROR:" "$log" | sort | uniq -c | sort -rn | head -50 || true
errors="$(grep -cE "SCRIPT ERROR|Parse Error" "$log" || true)"
echo "Godot $(godot --version) - Skriptfehler: $errors"
[ "$errors" -eq 0 ]
