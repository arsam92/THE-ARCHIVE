extends "res://tests/test_case.gd"


func test_code_puzzle_normalizes_input_and_applies_effects_once() -> void:
	var rt = make_runtime()
	var r: Dictionary = rt.puzzles.attempt("puzzle.fx_code", "1717", rt.state)
	assert_true(r["valid_input"], "string is valid input")
	assert_false(r["solved"], "wrong code")
	assert_false(rt.state.has_clue("clue.fx_b"), "no effect on failure")

	r = rt.puzzles.attempt("puzzle.fx_code", "  17 a ", rt.state)
	assert_true(r["solved"], "spacing and case ignored")
	assert_true(rt.state.has_clue("clue.fx_b"), "effect applied")
	assert_true(rt.state.solved.has("puzzle.fx_code"), "recorded as solved")

	rt.state.clues.erase("clue.fx_b")
	rt.state.clue_order.erase("clue.fx_b")
	r = rt.puzzles.attempt("puzzle.fx_code", "17-A", rt.state)
	assert_true(r["already"], "second solve is a no-op")
	assert_false(rt.state.has_clue("clue.fx_b"), "effects not re-applied")


func test_sequence_puzzle_is_order_sensitive() -> void:
	var rt = make_runtime()
	assert_false(rt.puzzles.attempt("puzzle.fx_seq", ["c", "b", "a"], rt.state)["solved"], "wrong order")
	assert_false(rt.puzzles.attempt("puzzle.fx_seq", ["a", "b"], rt.state)["solved"], "too short")
	assert_true(rt.puzzles.attempt("puzzle.fx_seq", ["a", "b", "c"], rt.state)["solved"], "right order")
	assert_true(rt.state.get_flag("seq_done", false), "flag set by effect")


func test_pairing_puzzle_ignores_order() -> void:
	var rt = make_runtime()
	var attempt := [["clue.fx_d", "clue.fx_decoy"], ["clue.fx_b", "clue.fx_a"]]
	assert_true(rt.puzzles.attempt("puzzle.fx_pair", attempt, rt.state)["solved"], "order-insensitive")
	assert_true(rt.state.get_flag("pairs_done", false), "flag set")


func test_pairing_puzzle_rejects_wrong_pairs() -> void:
	var rt = make_runtime()
	var r: Dictionary = rt.puzzles.attempt("puzzle.fx_pair", [["clue.fx_a", "clue.fx_d"], ["clue.fx_b", "clue.fx_decoy"]], rt.state)
	assert_true(r["valid_input"], "well-formed")
	assert_false(r["solved"], "wrong matching")


func test_invalid_input_is_rejected_safely() -> void:
	var rt = make_runtime()
	assert_false(rt.puzzles.attempt("puzzle.fx_seq", "abc", rt.state)["valid_input"], "string for sequence")
	assert_false(rt.puzzles.attempt("puzzle.fx_pair", [["only-one"]], rt.state)["valid_input"], "malformed pairs")
	assert_false(rt.puzzles.attempt("puzzle.fx_code", [1, 2], rt.state)["valid_input"], "array for code")
	assert_false(rt.puzzles.attempt("puzzle.nope", "x", rt.state)["solved"], "unknown puzzle")
	assert_false(rt.puzzles.attempt("clue.fx_a", "x", rt.state)["solved"], "not a puzzle")
