extends SceneTree
## Validates content packs from the command line (used by CI and contributors).
##   godot --headless --path . -s tools/validate_content.gd
##   godot --headless --path . -s tools/validate_content.gd -- res://content/packs/core res://other/pack
## Exit code 0 = no errors, 1 = errors found.

const Runtime = preload("res://src/core/runtime.gd")


func _init() -> void:
	var packs: Array = [Runtime.CORE_PACK]
	var extra := OS.get_cmdline_user_args()
	if not extra.is_empty():
		packs = Array(extra)

	var rt = Runtime.new("user://validate_saves")
	var ok: bool = rt.load_content(packs)
	for w in rt.report["warnings"]:
		print("WARN  ", w)
	for e in rt.report["errors"]:
		print("ERROR ", e)
	print("%d entities, %d errors, %d warnings" % [
		rt.db.entities.size(), rt.report["errors"].size(), rt.report["warnings"].size()])
	quit(0 if ok else 1)
