extends "res://tests/test_case.gd"

const SaveSystem = preload("res://src/core/save_system.gd")
const GameState = preload("res://src/core/game_state.gd")

const DIR := "user://test_saves_unit"


func _fresh() -> Object:
	var s = SaveSystem.new(DIR)
	for slot in [0, 1, 2]:
		s.delete_slot(slot)
	return s


func _state():
	var st = GameState.new()
	st.add_clue("clue.a")
	st.set_flag("f", true)
	st.set_choice("choice.c", "x")
	return st


func _write_raw(path: String, text: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(text)
	f.close()


func test_save_and_load_roundtrip() -> void:
	var s = _fresh()
	assert_false(s.has_slot(1), "empty slot")
	assert_true(s.save(1, _state()), "save succeeds")
	assert_true(s.has_slot(1), "slot exists")
	var r: Dictionary = s.load_slot(1)
	assert_true(r["ok"], "load ok: " + str(r["error"]))
	assert_false(r["from_backup"], "from main file")
	assert_true(r["state"].has_clue("clue.a"), "clue restored")
	assert_eq(r["state"].get_choice("choice.c"), "x", "choice restored")
	s.delete_slot(1)


func test_overwrite_keeps_previous_save_as_backup() -> void:
	var s = _fresh()
	s.save(1, _state())
	var st2 = _state()
	st2.add_clue("clue.second")
	assert_true(s.save(1, st2), "second save")
	assert_true(FileAccess.file_exists(DIR + "/slot_1.json.bak"), "backup created")
	assert_true(s.load_slot(1)["state"].has_clue("clue.second"), "latest loaded")
	s.delete_slot(1)


func test_tampered_save_falls_back_to_backup() -> void:
	var s = _fresh()
	s.save(1, _state())
	var st2 = _state()
	st2.add_clue("clue.second")
	s.save(1, st2)
	# Flip content without fixing the checksum.
	var text := FileAccess.get_file_as_string(DIR + "/slot_1.json")
	_write_raw(DIR + "/slot_1.json", text.replace("clue.second", "clue.hacked"))
	var r: Dictionary = s.load_slot(1)
	assert_true(r["ok"], "recovered")
	assert_true(r["from_backup"], "from backup")
	assert_false(r["state"].has_clue("clue.hacked"), "tampered data rejected")
	assert_true(r["state"].has_clue("clue.a"), "backup contents restored")
	s.delete_slot(1)


func test_truncated_save_without_backup_fails_cleanly() -> void:
	var s = _fresh()
	s.save(1, _state())
	var text := FileAccess.get_file_as_string(DIR + "/slot_1.json")
	_write_raw(DIR + "/slot_1.json", text.substr(0, text.length() / 2))
	var r: Dictionary = s.load_slot(1)
	assert_false(r["ok"], "truncated save fails")
	assert_true(r["state"] == null, "no state returned")
	assert_true(String(r["error"]) != "", "error explains why")
	s.delete_slot(1)


func test_garbage_and_hostile_files_fail_cleanly() -> void:
	var s = _fresh()
	DirAccess.make_dir_recursive_absolute(DIR)
	var cases := {
		"not json": "hello world",
		"json array": "[1,2,3]",
		"empty": "",
		"no envelope fields": "{\"format\":1}",
		"future format": "{\"format\":99,\"checksum\":\"x\",\"payload\":\"{}\"}",
		"wrong checksum": "{\"format\":1,\"checksum\":\"deadbeef\",\"payload\":\"{}\"}",
	}
	for label in cases.keys():
		_write_raw(DIR + "/slot_2.json", cases[label])
		var r: Dictionary = s.load_slot(2)
		assert_false(r["ok"], "rejects " + label)
	s.delete_slot(2)


func test_valid_envelope_with_invalid_state_is_rejected() -> void:
	var s = _fresh()
	DirAccess.make_dir_recursive_absolute(DIR)
	var payload := JSON.stringify({"version": 1, "current_season": 5})
	_write_raw(DIR + "/slot_2.json", JSON.stringify({"format": 1, "checksum": payload.sha256_text(), "payload": payload}))
	assert_false(s.load_slot(2)["ok"], "checksum fine but contents invalid")
	s.delete_slot(2)


func test_oversized_save_is_refused() -> void:
	var s = _fresh()
	DirAccess.make_dir_recursive_absolute(DIR)
	_write_raw(DIR + "/slot_2.json", "x".repeat(SaveSystem.MAX_SAVE_BYTES + 10))
	var r: Dictionary = s.load_slot(2)
	assert_false(r["ok"], "too large")
	assert_has_substring([r["error"]], "too large", "reason given")
	s.delete_slot(2)


func test_invalid_slots_are_rejected() -> void:
	var s = _fresh()
	assert_false(s.save(-1, _state()), "negative slot")
	assert_false(s.save(SaveSystem.MAX_SLOT + 1, _state()), "slot too high")
	assert_false(s.load_slot(-5)["ok"], "load negative slot")


func test_corrupt_main_does_not_clobber_good_backup_on_next_save() -> void:
	var s = _fresh()
	s.save(1, _state())
	var st2 = _state()
	st2.add_clue("clue.second")
	s.save(1, st2)                       # backup now holds first state
	_write_raw(DIR + "/slot_1.json", "corrupt")
	var st3 = _state()
	st3.add_clue("clue.third")
	assert_true(s.save(1, st3), "save over a corrupt main file")
	var backup := FileAccess.get_file_as_string(DIR + "/slot_1.json.bak")
	assert_false(backup.contains("corrupt"), "backup was not replaced by corrupt data")
	assert_true(s.load_slot(1)["state"].has_clue("clue.third"), "new save loads")
	s.delete_slot(1)


func test_android_lifecycle_pause_autosaves_and_resume_restores() -> void:
	var rt = make_runtime(DIR)
	rt.saves.delete_slot(SaveSystem.AUTOSAVE_SLOT)
	rt.effects.apply([{"op": "add_clue", "id": "clue.fx_a"}, {"op": "deliver_message", "id": "message.fx_17a"}], rt.state)
	rt.state.current_season = "season.2"
	assert_true(rt.autosave(), "pause hook saves")   # Game._notification(PAUSED) calls this
	var fresh = make_runtime(DIR)                    # simulates process death and relaunch
	assert_true(fresh.load_autosave(), "resume restores")
	assert_true(fresh.state.has_clue("clue.fx_a"), "progress kept")
	assert_eq(fresh.state.current_season, "season.2", "season kept")
	assert_true(fresh.state.received.has("message.fx_17a"), "inbox kept")
	fresh.saves.delete_slot(SaveSystem.AUTOSAVE_SLOT)
