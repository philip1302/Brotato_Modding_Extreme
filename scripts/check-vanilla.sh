#!/usr/bin/env bash
# Importiert das dekompilierte Projekt headless mit dem Container-Godot und listet Skript-/Ladefehler.
# Ersetzt nicht den Test im Windows-Editor, findet aber Parse-Fehler (z. B. fehlende Engine-Singletons) schnell.
# Nutzung: scripts/check-vanilla.sh   (GODOT_BIN=/pfad/zu/godot überschreibt das Godot-Binary)
set -euo pipefail

cd "$(dirname "$0")/.."

[ -f vanilla/project.godot ] || { echo "Fehlt: vanilla/project.godot (Brotato zuerst mit GDRE dekompilieren)"; exit 1; }

godot="${GODOT_BIN:-godot}"
log="$(mktemp)"
trap 'rm -f "$log"' EXIT

# 1. --editor --quit: Ressourcen importieren (.import/), dann beenden
timeout 900 "$godot" --path vanilla --editor --quit --no-window >"$log" 2>&1 || true
# 2. Jedes Skript einzeln laden und kompilieren (ModLoader aus, sonst sind Extensions schon installiert)
timeout 900 "$godot" --path vanilla --no-window -s "$PWD/scripts/godot/parse_all.gd" --disable-mods >>"$log" 2>&1 || true

grep -E "SCRIPT ERROR|Parse Error" "$log" | sed 's/^ *//' | sort | uniq -c | sort -rn | head -50 || true
grep -E "^PARSE_FAIL" "$log" || true
summary="$(grep -E "^PARSE_ALL" "$log" || echo "PARSE_ALL nicht gelaufen")"
echo "Godot $("$godot" --version) - $summary"
[[ "$summary" == *"failed=0" ]]
