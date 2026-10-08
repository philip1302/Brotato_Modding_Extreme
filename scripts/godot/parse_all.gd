# Lädt und kompiliert jedes GDScript unter res:// und meldet Parse-Fehler.
# Aufruf: godot --path vanilla --no-window -s <abs. Pfad>/parse_all.gd
extends SceneTree

const SKIP_DIRS := [".import", ".git"]

var checked := 0
var failed := []


func _init() -> void:
	_scan("res://")
	print("PARSE_ALL checked=%d failed=%d" % [checked, failed.size()])
	for path in failed:
		print("PARSE_FAIL " + path)
	quit(1 if failed.size() > 0 else 0)


func _scan(dir_path: String) -> void:
	var dir := Directory.new()
	if dir.open(dir_path) != OK:
		return
	dir.list_dir_begin(true, true)
	var name := dir.get_next()
	while name != "":
		var path := dir_path.plus_file(name)
		if dir.current_is_dir():
			if not name in SKIP_DIRS:
				_scan(path)
		elif name.ends_with(".gd"):
			_check(path)
		name = dir.get_next()
	dir.list_dir_end()


func _check(path: String) -> void:
	checked += 1
	# Kein reload(): bereits geladene Klassen würden doppelt kompiliert und als fremde Typen gelten.
	# Ein Skript mit Parse-Fehler ist nach dem Laden nicht instanziierbar.
	var script = load(path)
	if script == null or not script.can_instance():
		failed.append(path)
