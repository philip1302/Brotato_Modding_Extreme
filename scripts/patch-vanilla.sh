#!/usr/bin/env bash
# Lokale Anpassungen am dekompilierten Projekt, damit es im Standard-Godot (ohne Steam-Modul) läuft.
# Wirkt nur auf vanilla/ (gitignored), ist idempotent. Nach jedem neuen GDRE-Export erneut ausführen.
# Nutzung: scripts/patch-vanilla.sh
set -euo pipefail

cd "$(dirname "$0")/.."

project="vanilla/project.godot"
[ -f "$project" ] || { echo "Fehlt: $project (Brotato zuerst mit GDRE dekompilieren)"; exit 1; }
[ -f "$project.orig" ] || cp "$project" "$project.orig"

# 1. Feature-Tag "steam" entfernen: sonst wählt platform.gd SteamPlatform, und ohne GodotSteam-Modul
#    stürzt steam.gd beim Start ab. Ohne Tag wird LocalPlatform verwendet.
sed -i '/^_custom_features="steam"$/d' "$project"

# 2. Plugin resave_scenes deaktivieren: GDRE konnte es nicht wiederherstellen, der Ordner fehlt.
sed -i 's|, "res://addons/resave_scenes/plugin.cfg"||; s|"res://addons/resave_scenes/plugin.cfg", ||' "$project"

diff -u "$project.orig" "$project" || true
