#!/usr/bin/env bash
# Hängt unsere Mods per relativem Symlink ins dekompilierte Projekt ein:
#   vanilla/mods-unpacked/<Mod> -> ../../mods-unpacked/<Mod>
# Der ModLoader lädt im Editor alles aus res://mods-unpacked/.
# Nutzung: scripts/link-mods.sh
set -euo pipefail

cd "$(dirname "$0")/.."

target="vanilla/mods-unpacked"
[ -f vanilla/project.godot ] || echo "Hinweis: vanilla/project.godot fehlt noch (Brotato zuerst mit GDRE dekompilieren)"
mkdir -p "$target"

for d in mods-unpacked/*/; do
    mod="$(basename "$d")"
    link="$target/$mod"
    if [ -e "$link" ] && [ ! -L "$link" ]; then
        echo "Übersprungen: $link existiert und ist kein Symlink"
        continue
    fi
    ln -sfn "../../mods-unpacked/$mod" "$link"
    echo "$link -> ../../mods-unpacked/$mod"
done
