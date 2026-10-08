# Brotato Modding Extreme

Content-Mods für [Brotato](https://store.steampowered.com/app/1942280/Brotato/) – entwickelt in einem
VS-Code-Devcontainer nach der [Claude-Code-Referenzkonfiguration von Anthropic](https://docs.anthropic.com/en/docs/claude-code/devcontainer).

## Voraussetzungen (Windows-Host)
- WSL2 + Docker Desktop (WSL-Integration aktiv)
- VS Code mit den Erweiterungen **WSL** und **Dev Containers**
- Brotato (Steam) und **Godot 3.5.3** (Standard, nicht .NET) für Editor und Spieltests
- [GDRE Tools](https://github.com/bruvzg/gdsdecomp) zum Dekompilieren von Brotato (nur lokal als Referenz)
- Im Spiel/Workshop: **ModLoader** (in Brotato integriert), **Darkly77-ContentLoader**, **Darkly77-Brotils**

## Start
1. VS Code: `WSL: Open Folder in WSL…` → `~/projects/dev/Brotato_Modding_Extreme`
2. `Dev Containers: Reopen in Container` (beim ersten Mal wird das Image gebaut)
3. Im Container-Terminal: `claude` zum Anmelden bei Claude Code

Die Firewall (`.devcontainer/init-firewall.sh`) lässt nur GitHub, npm, PyPI, Anthropic, den VS-Code-Marketplace und den
Docker-Host durch. Darum kann Claude Code im Container mit `--dangerously-skip-permissions` laufen.
**Achtung:** Das schützt nicht vor dem Abfluss von Daten, die im Container liegen (z. B. Claude-Credentials). Nur
vertrauenswürdige Repos verwenden.

## Brotato als Referenz dekompilieren
Brotato mit GDRE Tools (Full Recovery) nach `vanilla/` im Repo exportieren. Der Ordner ist per `.gitignore` ausgeschlossen
und darf **niemals** committet werden.

Danach im Container:
```sh
scripts/fetch-deps.sh     # ContentLoader + Brotils -> vanilla/mods-unpacked/
scripts/link-mods.sh      # vanilla/mods-unpacked/<Mod> -> ../../mods-unpacked/<Mod>
scripts/check-vanilla.sh  # headless importieren, Skriptfehler auflisten
```
Anschließend `vanilla/project.godot` im Godot-Editor auf Windows öffnen und mit F5 starten.

## Arbeitsablauf
| Aufgabe | Befehl |
|---|---|
| Neuen Mod anlegen | `scripts/new-mod.sh <Namespace> <Name>` |
| Lint/Format prüfen | `scripts/lint.sh` (`--fix` zum Formatieren) |
| Zip bauen | `scripts/package.sh [Namespace-Name]` → `dist/` |
| ContentLoader + Brotils nach `vanilla/mods-unpacked/` holen | `scripts/fetch-deps.sh` |
| Eigene Mods ins Projekt verlinken | `scripts/link-mods.sh` |
| Dekompiliertes Projekt headless auf Skriptfehler prüfen | `scripts/check-vanilla.sh` |

**Godot-LSP:** Godot-Editor auf Windows mit `vanilla/project.godot` starten. Die Erweiterung `godot-tools` im Container
verbindet sich über `host.docker.internal:6008` (Standardport der LSP in Godot 3.x).

**Im Spiel testen:** Zip aus `dist/` (oder einen Godot-Export bei Mods mit Assets) nach
`<Brotato>/mods/` kopieren und Brotato starten. Die Logs liegen unter `%APPDATA%\Brotato\logs\modloader.log`.

## Struktur
```
.devcontainer/          Devcontainer (Dockerfile, devcontainer.json, init-firewall.sh)
mods-unpacked/
  Philip1302-ExtremeStarter/
    manifest.json       ModLoader-Manifest
    mod_main.gd         Einstieg
    content/            Items, Waffen, Charaktere …
    content_data/       ContentData-.tres für den ContentLoader
    extensions/         Script-Extensions (spiegeln vanilla-Pfade)
    translations/       Übersetzungs-CSVs
scripts/                lint.sh, package.sh, new-mod.sh
vanilla/                dekompiliertes Brotato (lokal, ignoriert)
```
