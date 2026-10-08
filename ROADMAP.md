# Roadmap

Stand: 2026-10-08. Brotato 1.1.15.4 ist nach `vanilla/` dekompiliert (GDRE 2.7.0, ohne DLC). Im Container kompilieren
alle Skripte, und ein Headless-Start lädt die Mod-Kette ohne Skriptfehler. Der Test im Windows-Editor steht noch aus.

**Versionen:** Brotato 1.1.15.4 · Engine 3.7-dev (custom build) → Godot **3.7-dev1** · ModLoader 6.3.0 ·
ContentLoader 6.2.3 · Brotils 1.1.2

## Meilensteine

| # | Meilenstein | Fertig, wenn … |
|---|---|---|
| **M1** | Brotato läuft im Godot-Editor | Das dekompilierte Projekt öffnet sich in Godot 3.7-dev1 und F5 startet einen spielbaren Run |
| **M2** | Mod-Roundtrip | Unser Starter-Mod lädt im Editor **und** im echten Spiel, `ModLoaderLog` taucht im Log auf |
| **M3** | Erstes Content-Stück | Ein eigenes Item über den ContentLoader ist im Shop, mit Icon und Übersetzung |
| **M4** | Content-Pipeline | Waffe und Charakter, Asset-Export über den Editor, Release-Zip/Workshop-Upload |
| **M5** | „Extreme“-Content | Das eigentliche Mod-Konzept (noch festzulegen) |

---

## M1 – Brotato im Editor bearbeiten (Detailplan)

### Schritt 1: Versionen klären (Windows)
- [x] Brotato-Version: 1.1.15.4
- [x] Engine der `Brotato.pck`: 3.7-dev (custom build). Auf Windows ist Godot 3.7-dev1 installiert, im Container
      `GODOT_VERSION=3.7-dev1` (aus `godotengine/godot-builds`, mit SHA512-Prüfung). **Container neu bauen.**
- [x] `manifest.json`: `compatible_game_version` 1.1.15.4, `compatible_mod_loader_version` 6.3.0

### Schritt 2: Dekompilieren nach `vanilla/`
- [x] GDRE Tools 2.7.0 → *Full Recovery* von `Brotato.pck` nach `vanilla/`. 445 Skripte, 0 Fehler.
- [x] Kontrolle: `vanilla/project.godot` existiert, `git status` bleibt sauber
- Bekannte Lücken:
  - GDRE hat die Bytecode-Revision nicht erkannt (Version 13) und 3.5.0 angenommen. Trotzdem kompilieren alle Skripte.
  - 82/1200 Übersetzungsschlüssel in `resources/translations/translations.csv` fehlen.
  - Das Plugin `resave_scenes` fehlt (wird von `patch-vanilla.sh` deaktiviert).
  - Die DLC (`BrotatoAbyssalTerrors.pck`) wurde nicht dekompiliert. Ohne `res://dlcs/` überspringt das Spiel sie sauber,
    die `dlcs/`-Einträge in `_global_script_classes` erzeugen im Editor aber evtl. Warnungen.

### Schritt 3: Projekt im Editor öffnen
- [x] `scripts/patch-vanilla.sh` (nur lokal in `vanilla/`):
  - `_custom_features="steam"` entfernt. Sonst wählt `platform.gd` `SteamPlatform`, und ohne GodotSteam-Modul stürzt
    `steam.gd` ab (`restartAppIfNecessary` auf Nil). Jetzt läuft `LocalPlatform`.
  - Plugin `resave_scenes` aus `[editor_plugins]` entfernt
- [x] Im Container: `scripts/check-vanilla.sh` → 483/483 Skripte kompilieren mit Godot 3.7-dev1
- [x] Headless-Smoke-Test (25 s, Hauptszene mit Mods): 0 Skriptfehler, Mod-Kette lädt, `ExtremeStarter: Ready`
- [ ] Godot 3.7-dev1 (Windows) → Import → `vanilla/project.godot`. Der erste Import dauert. Fehlerausgabe sammeln.
- [ ] Performance prüfen: Godot auf Windows mit dem Projekt im WSL-Dateisystem (`\\wsl$`) kann langsam sein und
      Dateiänderungen verpassen. Falls unbrauchbar: siehe *Entscheidung A* unten.
- [ ] **F5 → ein kompletter Run spielbar = M1 erreicht**

### Schritt 4: Unsere Mods ins Projekt einhängen
Im Editor lädt der ModLoader Mods aus `res://mods-unpacked/`, also `vanilla/mods-unpacked/`. Vorschlag:
- Drittanbieter-Mods (Darkly77-ContentLoader, Darkly77-Brotils) kommen **direkt** nach `vanilla/mods-unpacked/`.
  So bleiben sie außerhalb von Git und werden nicht von `lint.sh`/`package.sh` erfasst.
- Unsere Mods werden **pro Mod** per relativem Symlink eingehängt:
  `vanilla/mods-unpacked/Philip1302-ExtremeStarter -> ../../mods-unpacked/Philip1302-ExtremeStarter`
- [x] Skript `scripts/link-mods.sh` schreiben (legt die Links für alle Mods an)
- [ ] Testen, ob Godot auf Windows WSL-Symlinks über `\\wsl$` folgt. Falls nicht, braucht es einen
      Fallback (Windows-Symlink mit `mklink /D` oder ein Sync-Skript).
- [x] Skript `scripts/fetch-deps.sh`: ContentLoader v6.2.3 + Brotils v1.1.2 von GitHub nach `vanilla/mods-unpacked/`
- [x] Beide Skripte ausgeführt. Ladereihenfolge: Brotils → ContentLoader → ExtremeStarter

### Schritt 5: LSP-Anbindung Container ↔ Editor
- [x] **Port:** `godotTools.lsp.serverPort` in `devcontainer.json` auf 6008 gesetzt (Godot-3-Standard, Godot 4 nutzt 6005).
      Container neu bauen bzw. Fenster neu laden, damit die Einstellung greift.
- [ ] Prüfen, ob die LSP nur auf `127.0.0.1` lauscht. In dem Fall ist sie aus dem Container nicht erreichbar, dann
      Remote Host anpassen bzw. eine Windows-Firewall-Regel für den Port anlegen.
- [ ] Test im Container: `nc -zv host.docker.internal <port>` und Autocomplete in einer `.gd`-Datei

---

## M2 – Mod-Roundtrip
- [ ] `mod_main.gd`: der Log „Ready“ erscheint beim Editor-Start (F5) in der Ausgabe
- [ ] Erste Script-Extension (z. B. `extensions/main.gd`, die beim Run-Start einen Log ausgibt) als Beweis, dass
      `install_script_extension` greift
- [ ] `scripts/package.sh` → Zip nach `<Brotato>/mods/` → echtes Spiel starten → `modloader.log` prüfen
- [ ] Testablauf im README dokumentieren (Editor-Test vs. Spiel-Test)

## M3 – Erstes Item
- [ ] Vanilla-Item in `vanilla/items/` als Vorlage studieren (ItemData-Felder, Effekte)
- [ ] Eigenes Item: `content/items/…` (ItemData `.tres` + Icon), `content_data/…tres` für den ContentLoader
- [ ] Übersetzung: CSV in `translations/`, im Editor importieren, `_add_translations()` aktivieren
- [ ] Klären, wie Mods mit importierten Assets (Icons) gebaut werden: Export aus dem Editor als `.zip`/`.pck`
      gemäß ModLoader-Doku. `package.sh` reicht dafür nicht.

## M4 – Content-Pipeline & Release
- [ ] Waffe (inkl. Tier-Stufen) und Charakter
- [ ] Reproduzierbarer Asset-Export (evtl. headless `godot --export` im Container, falls das mit dem
      dekompilierten Projekt geht)
- [ ] CI: Release-Zip bei Git-Tags
- [ ] Workshop-Upload-Ablauf (läuft auf Windows)

## M5 – „Extreme“
Konzept fehlt noch: Welche Items, Waffen, Charaktere oder Mechaniken? Wie stark soll das Balancing vom
Vanilla-Spiel abweichen? Sobald M2 steht, ein Design-Dokument anlegen.

---

## Offene Entscheidungen
- **A – Wo liegt das Godot-Projekt?** Option 1: `vanilla/` im WSL-Repo. Claude kann es dann direkt lesen, für Godot ist
  es aber evtl. langsam. Option 2: Projekt auf `C:\` und nur eine Kopie oder ein Mount für die Referenz im Container.
  Entscheidung nach dem Praxistest in Schritt 3.
- **B – Drittanbieter-Mods versionieren?** Vorschlag: nein, nur in `vanilla/mods-unpacked/`. Versionen notieren wir in
  `manifest.json`/README.
