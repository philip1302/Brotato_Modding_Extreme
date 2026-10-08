# Roadmap

Stand: 2026-10-08. Wir haben einen Devcontainer, Lint/CI, Hilfsskripte und einen leeren Starter-Mod.
`vanilla/` ist noch leer, im Godot-Editor lief bisher nichts.

## Meilensteine

| # | Meilenstein | Fertig, wenn … |
|---|---|---|
| **M1** | Brotato läuft im Godot-Editor | Das dekompilierte Projekt öffnet sich in Godot 3.5.x und F5 startet einen spielbaren Run |
| **M2** | Mod-Roundtrip | Unser Starter-Mod lädt im Editor **und** im echten Spiel, `ModLoaderLog` taucht im Log auf |
| **M3** | Erstes Content-Stück | Ein eigenes Item über den ContentLoader ist im Shop, mit Icon und Übersetzung |
| **M4** | Content-Pipeline | Waffe und Charakter, Asset-Export über den Editor, Release-Zip/Workshop-Upload |
| **M5** | „Extreme“-Content | Das eigentliche Mod-Konzept (noch festzulegen) |

---

## M1 – Brotato im Editor bearbeiten (Detailplan)

### Schritt 1: Versionen klären (Windows)
- [ ] Brotato-Version notieren (Hauptmenü unten oder `%APPDATA%\Brotato\logs\`)
- [ ] Mit GDRE Tools **die Engine-Version der `Brotato.pck`** prüfen (Info/Inspect). Genau diese Godot-3.5.x-Version
      auf Windows installieren (Standard, nicht Mono). Danach `GODOT_VERSION` im Devcontainer angleichen.
- [ ] `compatible_game_version` und `compatible_mod_loader_version` in `manifest.json` mit den echten Werten
      abgleichen (die ModLoader-Version steht im dekompilierten Projekt unter `addons/mod_loader/`)

### Schritt 2: Dekompilieren nach `vanilla/`
- [ ] GDRE Tools → *Recover project* (Full Recovery) mit `<Steam>\steamapps\common\Brotato\Brotato.pck`
- [ ] Ziel: `vanilla/` in diesem Repo (über `\\wsl.localhost\<Distro>\home\…\Brotato_Modding_Extreme\vanilla`)
- [ ] Kontrolle: `vanilla/project.godot` existiert, `git status` bleibt sauber (Ordner ist ignoriert)

### Schritt 3: Projekt im Editor öffnen
- [ ] Godot 3.5.x → Import → `vanilla/project.godot`. Der erste Import dauert.
- [ ] Fehlerausgabe sammeln. Bekannte Stolpersteine bei dekompilierten Spielen:
  - Engine-Module oder Singletons, die es nur im Spiel-Build gibt (z. B. Steam-Integration). Fehlen sie im Standard-Godot,
    brechen Skripte beim Parsen ab. Abhilfe ist ein Stub/Guard **nur lokal in `vanilla/`**, nie im Repo.
  - Ressourcen, die GDRE nicht sauber zurückgewinnt (Shader, `.tres` mit Binärdaten): einzeln reparieren oder ignorieren
- [ ] Performance prüfen: Godot auf Windows mit dem Projekt im WSL-Dateisystem (`\\wsl$`) kann langsam sein und
      Dateiänderungen verpassen. Falls unbrauchbar: siehe *Entscheidung A* unten.
- [ ] **F5 → ein kompletter Run spielbar = M1 erreicht**

### Schritt 4: Unsere Mods ins Projekt einhängen
Im Editor lädt der ModLoader Mods aus `res://mods-unpacked/`, also `vanilla/mods-unpacked/`. Vorschlag:
- Drittanbieter-Mods (Darkly77-ContentLoader, Darkly77-Brotils) kommen **direkt** nach `vanilla/mods-unpacked/`.
  So bleiben sie außerhalb von Git und werden nicht von `lint.sh`/`package.sh` erfasst.
- Unsere Mods werden **pro Mod** per relativem Symlink eingehängt:
  `vanilla/mods-unpacked/Philip1302-ExtremeStarter -> ../../mods-unpacked/Philip1302-ExtremeStarter`
- [ ] Skript `scripts/link-mods.sh` schreiben (legt die Links für alle Mods an)
- [ ] Testen, ob Godot auf Windows WSL-Symlinks über `\\wsl$` folgt. Falls nicht, braucht es einen
      Fallback (Windows-Symlink mit `mklink /D` oder ein Sync-Skript).
- [ ] ContentLoader + Brotils von GitHub holen (GitHub ist in der Firewall erlaubt) und nach `vanilla/mods-unpacked/` entpacken

### Schritt 5: LSP-Anbindung Container ↔ Editor
- [ ] **Port prüfen:** Godot **3.x** nutzt für die LSP standardmäßig Port **6008**, 6005 ist der Default von Godot 4.
      Entweder in Godot *Editor Settings → Network → Language Server → Remote Port* auf 6005 stellen oder
      `godotTools.lsp.serverPort` in `devcontainer.json` auf 6008 ändern.
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
