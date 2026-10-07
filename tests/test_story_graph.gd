extends "res://tests/test_case.gd"

const GameState = preload("res://src/core/game_state.gd")


func test_outgoing_and_incoming_edges() -> void:
	var g = make_runtime().graph
	assert_true(g.targets("clue.fx_a", "foreshadows").has("clue.fx_future"), "forward reference")
	assert_true(g.targets("clue.fx_b", "requires").has("clue.fx_a"), "requires edge")
	var incoming: Array = g.incoming("clue.fx_a", "requires")
	assert_eq(incoming.size(), 1, "one clue requires fx_a")
	assert_eq(incoming[0]["from"], "clue.fx_b", "it is fx_b")


func test_clues_reference_across_seasons() -> void:
	var g = make_runtime().graph
	# fx_decoy lives in season 2 and points back at a season 1 clue;
	# fx_future lives in season 4 and is pointed at from season 1.
	var links: Array = g.cross_season_links("season.1")
	var pairs: Array = []
	for l in links:
		pairs.append("%s>%s" % [l["from"], l["to"]])
	assert_true(pairs.has("clue.fx_decoy>clue.fx_a"), "season2 -> season1 link")
	assert_true(pairs.has("clue.fx_a>clue.fx_future"), "season1 -> season4 link")


func test_reachability_follows_chains() -> void:
	var g = make_runtime().graph
	var reach: Array = g.reachable_from("clue.fx_b", ["requires", "foreshadows"])
	assert_true(reach.has("clue.fx_a"), "b requires a")
	assert_true(reach.has("clue.fx_future"), "a foreshadows future")
	assert_false(reach.has("clue.fx_b"), "start excluded")


func test_clue_availability_respects_requirements_seasons_and_unlocks() -> void:
	var rt = make_runtime()
	var g = rt.graph
	var s = GameState.new()
	assert_true(g.is_clue_available("clue.fx_a", s), "a is available in season 1")
	assert_false(g.is_clue_available("clue.fx_b", s), "b requires a")
	assert_false(g.is_clue_available("clue.fx_decoy", s), "season 2 locked")
	s.add_clue("clue.fx_a")
	assert_true(g.is_clue_available("clue.fx_b", s), "b available after a")
	assert_false(g.is_clue_available("clue.fx_a", s), "already found is not available")
	s.unlocked_seasons["season.4"] = true
	assert_false(g.is_clue_available("clue.fx_future", s), "future clue needs fx_b via unlock condition")
	s.add_clue("clue.fx_b")
	assert_true(g.is_clue_available("clue.fx_future", s), "future clue opens once fx_b found")
	assert_false(g.is_clue_available("message.fx_17a", s), "non-clues are never clues")
