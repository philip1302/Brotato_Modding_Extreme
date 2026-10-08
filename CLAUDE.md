# Brotato Modding Extreme

Content-Mods für **Brotato 1.1.15.4** (Godot **3.7-dev**, GDScript **3**, nicht Godot 4!) auf Basis von
GodotModding **ModLoader 6.3.0** (im Spiel integriert) und **Darkly77-ContentLoader** (+ Brotils).

## Umgebung
- Devcontainer (Anthropic-Referenz) mit Firewall-Allowlist (`.devcontainer/init-firewall.sh`).
  Neue Domains nur dort eintragen und Container neu bauen.
- Im Container: `godot` (3.7-dev1 headless, passend zur Engine von `Brotato.pck`), `gdlint`/`gdformat` (gdtoolkit 3.x), `jq`, `zip`, `gh`.
- Godot-Editor und Spieltests laufen auf dem **Windows-Host**. Die Godot-LSP ist im Container über `host.docker.internal:6008` erreichbar (Godot-3-Standard).

## Struktur
- `mods-unpacked/<Namespace>-<Name>/` – ein Ordner pro Mod; der Name muss `namespace-name` aus der `manifest.json` entsprechen.
  - `mod_main.gd` – Einstieg: `_init()` installiert Extensions/Übersetzungen, `_ready()` lädt ContentData.
  - `extensions/` – Script-Extensions, Pfad spiegelt vanilla (`extensions/main.gd` erweitert `res://main.gd`).
  - `content/` (items, weapons, characters …), `content_data/` (ContentData-`.tres`), `translations/` (CSV).
  - Asset-Dateinamen mit Mod-Präfix versehen (`extremestarter_…`).
- `vanilla/` – dekompiliertes Brotato (GDRE Tools 2.7.0, ohne DLC), **gitignored**. Dient nur als Referenz zum Lesen. **Niemals committen
  oder Spieldateien in Mods kopieren**, das Repo ist öffentlich.

## Befehle
- `scripts/lint.sh` (`--fix` formatiert) – vor jedem Commit ausführen, CI prüft dasselbe.
- `scripts/package.sh [Mod]` – erzeugt `dist/<Mod>.zip` (nur für Skript-/Daten-Mods; Mods mit importierten Assets
  über den Godot-Editor exportieren).
- `scripts/new-mod.sh <Namespace> <Name>` – legt einen neuen Mod aus dem Starter an.
- `scripts/fetch-deps.sh` / `scripts/link-mods.sh` – Drittanbieter-Mods bzw. eigene Mods (Symlink) nach
  `vanilla/mods-unpacked/`. Drittanbieter-Mods gehören nie nach `mods-unpacked/`.
- `scripts/patch-vanilla.sh` – lokale Fixes an `vanilla/project.godot` (Steam-Feature-Tag, fehlendes Plugin). Nach jedem
  GDRE-Export erneut ausführen.
- `scripts/check-vanilla.sh` – dekompiliertes Projekt headless importieren und jedes Skript kompilieren.

## Konventionen
- GDScript 3: `extends`-Script-Extensions rufen `.original_method()` auf, statt Vanilla-Code zu kopieren.
- Keine `class_name` in Mods (ModLoader unterstützt keine globalen Klassen), stattdessen `get_node`/`load()`.
- Logs über `ModLoaderLog.info/warning/error(msg, MOD_ID)`.
- Tabs für Einrückung, LF-Zeilenenden.
