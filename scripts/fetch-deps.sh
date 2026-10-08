#!/usr/bin/env bash
# Lädt die Drittanbieter-Mods (ContentLoader, Brotils) in festen Versionen nach vanilla/mods-unpacked/.
# Sie liegen bewusst außerhalb von Git und außerhalb von mods-unpacked/ (sonst greifen lint.sh/package.sh).
# Nutzung: scripts/fetch-deps.sh
set -euo pipefail

cd "$(dirname "$0")/.."

# <Repo> <Tag> <Mod-Ordner>
DEPS=(
    "BrotatoMods/Brotato-Brotils v1.1.2 Darkly77-Brotils"
    "BrotatoMods/Brotato-ContentLoader v6.2.3 Darkly77-ContentLoader"
)

target="vanilla/mods-unpacked"
[ -f vanilla/project.godot ] || echo "Hinweis: vanilla/project.godot fehlt noch (Brotato zuerst mit GDRE dekompilieren)"
mkdir -p "$target"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

for dep in "${DEPS[@]}"; do
    read -r repo tag mod <<<"$dep"
    git -c advice.detachedHead=false clone -q --depth 1 --branch "$tag" "https://github.com/$repo.git" "$tmp/$mod"
    rm -rf "${target:?}/$mod"
    cp -r "$tmp/$mod/root/mods-unpacked/$mod" "$target/$mod"
    echo "$target/$mod ($tag)"
done
