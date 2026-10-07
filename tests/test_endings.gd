extends "res://tests/test_case.gd"


func test_default_ending_when_nothing_else_matches() -> void:
	var rt = make_runtime()
	assert_eq(rt.endings.resolve(rt.state), "ending.fx_default", "fallback ending")


func test_doubt_ending() -> void:
	var rt = make_runtime()
	rt.effects.apply([{"op": "set_choice", "id": "choice.fx_trust", "option": "doubt"}], rt.state)
	assert_eq(rt.endings.resolve(rt.state), "ending.fx_doubt", "doubt ending")


func test_trust_ending_needs_both_conditions() -> void:
	var rt = make_runtime()
	rt.effects.apply([{"op": "set_choice", "id": "choice.fx_trust", "option": "trust"}], rt.state)
	assert_eq(rt.endings.resolve(rt.state), "ending.fx_default", "trust alone is not enough")
	rt.effects.apply([{"op": "set_flag", "id": "seq_done"}], rt.state)
	assert_eq(rt.endings.resolve(rt.state), "ending.fx_trust", "trust + puzzle")


func test_priority_decides_between_multiple_matches() -> void:
	var rt = make_runtime()
	rt.effects.apply([
		{"op": "set_choice", "id": "choice.fx_trust", "option": "trust"},
		{"op": "set_flag", "id": "seq_done"},
	], rt.state)
	var all: Array = rt.endings.matching(rt.state)
	assert_eq(all, ["ending.fx_trust", "ending.fx_default"], "ordered by priority")


func test_all_three_endings_are_reachable_via_play() -> void:
	var reached := {}
	# Path 1: play the dialogue and take "doubt".
	var rt = make_runtime()
	var d = rt.new_dialogue()
	d.start("dialogue.fx_intro", rt.state)
	d.choose(1)
	reached[rt.endings.resolve(rt.state)] = true
	# Path 2: trust + solve the sequence puzzle.
	rt = make_runtime()
	d = rt.new_dialogue()
	d.start("dialogue.fx_intro", rt.state)
	d.choose(0)
	rt.puzzles.attempt("puzzle.fx_seq", ["a", "b", "c"], rt.state)
	reached[rt.endings.resolve(rt.state)] = true
	# Path 3: do nothing.
	rt = make_runtime()
	reached[rt.endings.resolve(rt.state)] = true
	assert_eq(reached.size(), 3, "three distinct endings: " + str(reached.keys()))


func test_trigger_ending_effect_records_it() -> void:
	var rt = make_runtime()
	var ev: Array = rt.effects.apply([{"op": "trigger_ending", "id": "ending.fx_default"}], rt.state)
	assert_true(rt.state.endings_seen.has("ending.fx_default"), "recorded")
	assert_true(ev[0]["new"], "first time is new")
	ev = rt.effects.apply([{"op": "trigger_ending", "id": "ending.fx_default"}], rt.state)
	assert_false(ev[0]["new"], "second time is not new")
