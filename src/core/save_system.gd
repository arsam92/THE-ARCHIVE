extends RefCounted
## Save/load with integrity checks.
##  - Envelope {format, checksum, payload}; checksum is SHA-256 of the payload.
##  - Writes go to a temp file first, then replace the slot; the previous save
##    is kept as .bak and used automatically if the main file is damaged.
##  - Corrupt, truncated, oversized or too-new saves return an error instead of
##    crashing and never overwrite the good backup.

const GameState = preload("res://src/core/game_state.gd")

const SAVE_FORMAT := 1
const MAX_SAVE_BYTES := 2 * 1024 * 1024
const MAX_SLOT := 99
const AUTOSAVE_SLOT := 0

var dir := "user://saves"


func _init(p_dir: String = "user://saves") -> void:
	dir = p_dir


func _path(slot: int) -> String:
	return dir.path_join("slot_%d.json" % slot)


func has_slot(slot: int) -> bool:
	return FileAccess.file_exists(_path(slot)) or FileAccess.file_exists(_path(slot) + ".bak")


func save(slot: int, state) -> bool:
	if slot < 0 or slot > MAX_SLOT:
		return false
	if DirAccess.make_dir_recursive_absolute(dir) != OK and not DirAccess.dir_exists_absolute(dir):
		return false
	var payload := JSON.stringify(state.to_dict())
	var envelope := JSON.stringify({
		"format": SAVE_FORMAT,
		"checksum": payload.sha256_text(),
		"payload": payload,
	})
	var main := _path(slot)
	var tmp := main + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(envelope)
	f.close()

	# Only promote the current save to backup if it is itself valid.
	if FileAccess.file_exists(main) and _try_load(main).get("ok", false):
		DirAccess.copy_absolute(main, main + ".bak")
	var err := DirAccess.rename_absolute(tmp, main)
	if err != OK and FileAccess.file_exists(main):
		DirAccess.remove_absolute(main)
		err = DirAccess.rename_absolute(tmp, main)
	if err != OK:
		DirAccess.remove_absolute(tmp)
		return false
	return true


## Returns {ok, state, error, from_backup}.
func load_slot(slot: int) -> Dictionary:
	if slot < 0 or slot > MAX_SLOT:
		return {"ok": false, "state": null, "error": "invalid slot", "from_backup": false}
	var main := _try_load(_path(slot))
	if main["ok"]:
		main["from_backup"] = false
		return main
	var backup := _try_load(_path(slot) + ".bak")
	if backup["ok"]:
		backup["from_backup"] = true
		backup["error"] = "main save unusable (%s); restored backup" % main["error"]
		return backup
	return {"ok": false, "state": null, "error": main["error"], "from_backup": false}


func delete_slot(slot: int) -> void:
	for suffix in ["", ".bak", ".tmp"]:
		var p: String = _path(slot) + suffix
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)


func _try_load(path: String) -> Dictionary:
	var fail := func(msg: String) -> Dictionary:
		return {"ok": false, "state": null, "error": msg}
	if not FileAccess.file_exists(path):
		return fail.call("no save file")
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return fail.call("cannot open save")
	if f.get_length() > MAX_SAVE_BYTES:
		return fail.call("save file too large")
	var text := f.get_as_text()
	f.close()

	var json := JSON.new()
	if json.parse(text) != OK or not (json.data is Dictionary):
		return fail.call("save is not valid JSON")
	var env: Dictionary = json.data
	var fmt = env.get("format")
	if typeof(fmt) != TYPE_INT and typeof(fmt) != TYPE_FLOAT:
		return fail.call("missing save format")
	if int(fmt) < 1 or int(fmt) > SAVE_FORMAT:
		return fail.call("unsupported save format %s" % str(fmt))
	var payload = env.get("payload")
	var checksum = env.get("checksum")
	if not (payload is String) or not (checksum is String):
		return fail.call("save envelope incomplete")
	if payload.sha256_text() != checksum:
		return fail.call("checksum mismatch (save corrupted)")

	var pj := JSON.new()
	if pj.parse(payload) != OK or not (pj.data is Dictionary):
		return fail.call("payload is not valid JSON")
	var data := _migrate(pj.data, int(fmt))
	var state = GameState.new()
	if not state.from_dict(data):
		return fail.call("save contents failed validation")
	return {"ok": true, "state": state, "error": ""}


## Upgrade hook for older formats. Format 1 is current, so nothing to do yet.
func _migrate(data: Dictionary, _from_format: int) -> Dictionary:
	return data
