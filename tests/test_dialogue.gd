extends "res://tests/test_case.gd"


func test_branching_trust_path() -> void:
	var rt = make_runtime()
	var d = rt.new_dialogue()
	assert_true(d.start("dialogue.fx_intro", rt.state), "starts")
	assert_eq(d.node_id, "n1", "at first node")
	assert_eq(d.current()["speaker"], "identity.nora", "speaker data")
	assert_true(d.choose(0), "choose trust")
	assert_eq(d.node_id, "n2", "moved to n2")
	assert_eq(rt.state.get_choice("choice.fx_trust"), "trust", "choice recorded")
	assert_true(rt.state.get_flag("trusted_nora", false), "node effect applied on enter")
	assert_true(d.advance(), "end node advances to finished")
	assert_true(d.finished, "finished")


func test_branching_doubt_path_follows_linear_nodes() -> void:
	var rt = make_runtime()
	var d = rt.new_dialogue()
	d.start("dialogue.fx_intro", rt.state)
	d.choose(1)
	assert_eq(d.node_id, "n3", "doubt branch")
	assert_false(rt.state.get_flag("trusted_nora", false), "trust effect not applied")
	d.advance()
	assert_eq(d.node_id, "n5", "linear next followed")
	d.advance()
	assert_true(d.finished, "ended")


func test_choices_are_gated_by_conditions() -> void:
	var rt = make_runtime()
	var d = rt.new_dialogue()
	d.start("dialogue.fx_intro", rt.state)
	assert_eq(d.available_choices().size(), 2, "secret option hidden without clue")
	assert_false(d.choose(2), "cannot pick a gated choice directly")
	assert_eq(d.node_id, "n1", "state unchanged after refused choice")

	rt.effects.apply([{"op": "add_clue", "id": "clue.fx_a"}], rt.state)
	var avail: Array = d.available_choices()
	assert_eq(avail.size(), 3, "secret option appears")
	assert_eq(avail[2]["index"], 2, "keeps original index")
	assert_true(d.choose(2), "now selectable")
	assert_true(rt.state.has_clue("clue.fx_b"), "its effect gave a clue")


func test_choose_on_node_without_choices_and_bad_indexes() -> void:
	var rt = make_runtime()
	var d = rt.new_dialogue()
	d.start("dialogue.fx_intro", rt.state)
	assert_false(d.choose(-1), "negative index")
	assert_false(d.choose(99), "out of range")
	assert_false(d.advance(), "cannot advance past a choice node")


func test_unknown_dialogue_and_double_finish_are_safe() -> void:
	var rt = make_runtime()
	var d = rt.new_dialogue()
	assert_false(d.start("dialogue.nope", rt.state), "unknown id")
	assert_false(d.start("clue.fx_a", rt.state), "wrong entity type")
	assert_true(d.finished, "stays finished")
	assert_false(d.advance(), "advance when finished")
	assert_false(d.choose(0), "choose when finished")
	assert_eq(d.current(), {}, "no current node")


func test_events_are_reported_for_the_ui() -> void:
	var rt = make_runtime()
	var d = rt.new_dialogue()
	d.start("dialogue.fx_intro", rt.state)
	d.choose(0)
	var ops: Array = []
	for e in d.events:
		ops.append(e["op"])
	assert_eq(ops, ["set_choice", "set_flag"], "events in order")
