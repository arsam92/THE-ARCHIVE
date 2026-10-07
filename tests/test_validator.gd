extends "res://tests/test_case.gd"

const Runtime = preload("res://src/core/runtime.gd")


func test_core_and_fixture_validate_clean() -> void:
	var rt = Runtime.new("user://test_saves")
	var ok: bool = rt.load_content([CORE, FIXTURE_BASIC])
	assert_true(ok, "valid content passes: " + str(rt.report["errors"]))
	assert_eq(rt.report["warnings"].size(), 0, "no warnings: " + str(rt.report["warnings"]))


func test_core_alone_validates_clean() -> void:
	var rt = Runtime.new("user://test_saves")
	assert_true(rt.load_content([CORE]), "core clean: " + str(rt.report["errors"]))


func test_broken_pack_problems_are_all_detected() -> void:
	var rt = Runtime.new("user://test_saves")
	var ok: bool = rt.load_content([CORE, FIXTURE_BROKEN])
	var errs: Array = rt.report["errors"]
	assert_false(ok, "broken content must fail validation")
	assert_has_substring(errs, "dangling reference (references -> clue.nope)", "dangling ref")
	assert_has_substring(errs, "requires-cycle", "cycle")
	assert_has_substring(errs, "sender.true_identity 'identity.ghost'", "bad true identity")
	assert_has_substring(errs, "next 'zz' does not exist", "bad dialogue next")
	assert_has_substring(errs, "unknown op 'nuke'", "bad effect")
	assert_has_substring(errs, "unknown or malformed condition 'bogus_op'", "bad condition op")
	assert_has_substring(errs, "missing translation for key 'bk.missing'", "missing translation")
	assert_has_substring(errs, "season 'season.99' does not exist", "bad season")


func test_broken_content_does_not_prevent_play_of_valid_parts() -> void:
	var rt = Runtime.new("user://test_saves")
	rt.load_content([CORE, FIXTURE_BROKEN])
	assert_true(rt.db.has("clue.bk_ok"), "valid entity still queryable")
	var d = rt.new_dialogue()
	# The broken dialogue has a dangling next; running it must end cleanly.
	assert_true(d.start("dialogue.bk_dlg", rt.state), "starts at valid start node")
	d.advance()
	assert_true(d.finished, "dangling next ends dialogue instead of crashing")


func test_season_graph_follows_the_brief() -> void:
	var rt = make_runtime()
	var g = rt.graph
	for s in ["season.1", "season.2", "season.3"]:
		for other in ["season.1", "season.2", "season.3", "season.4"]:
			if other != s:
				assert_true(g.targets(s, "connects_to").has(other), "%s connects to %s" % [s, other])
	for s in ["season.1", "season.2", "season.3"]:
		assert_true(g.targets("season.4", "reinterprets").has(s), "season.4 reinterprets " + s)
