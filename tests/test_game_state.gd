extends "res://tests/test_case.gd"

const GameState = preload("res://src/core/game_state.gd")


func _populated():
	var s = GameState.new()
	s.add_clue("clue.a")
	s.add_clue("clue.b")
	s.receive_message("message.m")
	s.set_flag("f", 2)
	s.set_choice("choice.c", "x")
	s.set_identified("message.m", "identity.nora")
	s.unlocked_seasons["season.2"] = true
	s.visited["location.l"] = true
	s.solved["puzzle.p"] = true
	s.play_seconds = 12.5
	return s


func test_roundtrip_through_json() -> void:
	var s = _populated()
	var text := JSON.stringify(s.to_dict())
	var parsed = JSON.parse_string(text)
	var t = GameState.new()
	assert_true(t.from_dict(parsed), "from_dict accepts own output")
	assert_eq(t.clue_order, ["clue.a", "clue.b"], "clue order kept")
	assert_true(t.has_clue("clue.b"), "clue set rebuilt")
	assert_eq(t.identified["message.m"], "identity.nora", "identity kept")
	assert_true(t.unlocked_seasons.has("season.2"), "season kept")
	assert_eq(t.play_seconds, 12.5, "play time kept")


func test_add_clue_is_idempotent() -> void:
	var s = GameState.new()
	assert_true(s.add_clue("clue.a"), "first add is new")
	assert_false(s.add_clue("clue.a"), "second add is not new")
	assert_eq(s.clue_order.size(), 1, "no duplicate order entry")


func test_identity_history_records_changes() -> void:
	var s = GameState.new()
	assert_true(s.set_identified("message.m", "identity.nora"), "first set changes")
	assert_false(s.set_identified("message.m", "identity.nora"), "same value does not change")
	assert_true(s.set_identified("message.m", ""), "revision to unresolved changes")
	assert_eq(s.identity_history["message.m"], ["identity.nora", ""], "history")


func test_from_dict_rejects_bad_input_and_leaves_state_untouched() -> void:
	var good = _populated().to_dict()
	var bad_cases := {
		"not a dict": "hello",
		"null": null,
		"missing version": {"current_season": "season.1"},
		"future version": _with(good, "version", 99),
		"zero version": _with(good, "version", 0),
		"clues wrong type": _with(good, "clues", "oops"),
		"clues non-string element": _with(good, "clues", ["clue.a", 5]),
		"flags wrong type": _with(good, "flags", []),
		"choices non-string value": _with(good, "choices", {"choice.c": 5}),
		"empty season": _with(good, "current_season", ""),
		"history bad": _with(good, "identity_history", {"message.m": [1]}),
		"play_seconds string": _with(good, "play_seconds", "long"),
	}
	for label in bad_cases.keys():
		var s = GameState.new()
		s.add_clue("clue.keep")
		assert_false(s.from_dict(bad_cases[label]), "rejects: " + label)
		assert_true(s.has_clue("clue.keep"), "untouched after: " + label)


func _with(d: Dictionary, key: String, value) -> Dictionary:
	var c := d.duplicate(true)
	c[key] = value
	return c
