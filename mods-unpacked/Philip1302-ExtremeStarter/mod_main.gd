extends Node

const MOD_ID := "Philip1302-ExtremeStarter"
const CONTENT_LOADER_PATH := "/root/ModLoader/Darkly77-ContentLoader/ContentLoader"

var mod_dir := ""
var ext_dir := ""
var trans_dir := ""
var content_data_dir := ""


func _init() -> void:
	mod_dir = ModLoaderMod.get_unpacked_dir() + MOD_ID + "/"
	ext_dir = mod_dir + "extensions/"
	trans_dir = mod_dir + "translations/"
	content_data_dir = mod_dir + "content_data/"

	_install_script_extensions()
	_add_translations()


func _ready() -> void:
	_load_content_data()
	ModLoaderLog.info("Ready", MOD_ID)


# Vanilla-Skripte erweitern: Datei in extensions/ spiegelt den vanilla-Pfad,
# z. B. extensions/main.gd -> res://main.gd
func _install_script_extensions() -> void:
	# ModLoaderMod.install_script_extension(ext_dir + "main.gd")
	pass


# Übersetzungen (CSV -> .translation, im Godot-Editor importiert)
func _add_translations() -> void:
	# ModLoaderMod.add_translation(trans_dir + "philip1302_extreme.en.translation")
	pass


# Lädt alle ContentData-Ressourcen (*.tres) aus content_data/ in den ContentLoader
func _load_content_data() -> void:
	var content_loader = get_node_or_null(CONTENT_LOADER_PATH)
	if content_loader == null:
		ModLoaderLog.error("ContentLoader not found - is Darkly77-ContentLoader installed?", MOD_ID)
		return

	var dir := Directory.new()
	if dir.open(content_data_dir) != OK:
		ModLoaderLog.warning("No content_data directory found", MOD_ID)
		return

	dir.list_dir_begin(true, true)
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			content_loader.load_data(content_data_dir + file_name, MOD_ID)
		file_name = dir.get_next()
	dir.list_dir_end()
