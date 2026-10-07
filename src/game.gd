extends Node
## Autoload "Game": owns the Runtime and bridges Android lifecycle events to it.
## Keep this thin; all logic belongs in src/core so it stays testable.

const Runtime = preload("res://src/core/runtime.gd")

signal content_loaded(ok: bool)

var rt


func _ready() -> void:
	# Keep running the autosave hook even if the tree is paused by a menu.
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().set_auto_accept_quit(false)
	rt = Runtime.new()


func boot() -> bool:
	var pack_dirs: Array = [Runtime.CORE_PACK]
	pack_dirs.append_array(_downloaded_packs())
	var ok: bool = rt.load_content(pack_dirs)
	if not ok:
		for e in rt.report["errors"]:
			push_warning("content: " + str(e))
	if not rt.load_autosave():
		rt.new_game()
	content_loaded.emit(ok)
	return ok


## Downloadable narrative content lives under user://packs/<pack>/manifest.json.
func _downloaded_packs() -> Array:
	var out: Array = []
	var d := DirAccess.open(Runtime.DOWNLOADED_PACKS_DIR)
	if d == null:
		return out
	var names := Array(d.get_directories())
	names.sort()
	for n in names:
		out.append(Runtime.DOWNLOADED_PACKS_DIR.path_join(String(n)))
	return out


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_GO_BACK_REQUEST:
			_save_on_lifecycle()
		NOTIFICATION_WM_CLOSE_REQUEST:
			_save_on_lifecycle()
			get_tree().quit()


func _save_on_lifecycle() -> void:
	if rt != null:
		rt.autosave()
