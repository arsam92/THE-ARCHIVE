extends "res://tests/test_case.gd"

const Condition = preload("res://src/core/condition.gd")
const GameState = preload("res://src/core/game_state.gd")


func test_empty_conditions_are_true() -> void:
	var s = GameState.new()
	assert_true(Condition.evaluate(null, s), "null")
	assert_true(Condition.evaluate([], s), "empty array")
	assert_true(Condition.evaluate({}, s), "empty dict")


func test_clue_flag_choice() -> void:
	var s = GameState.new()
	s.add_clue("clue.x")
	s.set_flag("f")
	s.set_flag("n", 3)
	s.set_choice("choice.c", "a")
	assert_true(Condition.evaluate({"has_clue": "clue.x"}, s), "has_clue")
	assert_false(Condition.evaluate({"has_clue": "clue.y"}, s), "missing clue")
	assert_true(Condition.evaluate({"flag": "f"}, s), "flag truthy")
	assert_false(Condition.evaluate({"flag": "unset"}, s), "flag unset")
	assert_true(Condition.evaluate({"flag": {"id": "n", "equals": 3}}, s), "flag equals")
	assert_false(Condition.evaluate({"flag": {"id": "n", "equals": 4}}, s), "flag not equal")
	assert_true(Condition.evaluate({"choice": {"id": "choice.c", "option": "a"}}, s), "choice")
	assert_false(Condition.evaluate({"choice": {"id": "choice.c", "option": "b"}}, s), "other option")


func test_combinators() -> void:
	var s = GameState.new()
	s.add_clue("clue.x")
	assert_true(Condition.evaluate({"all": [{"has_clue": "clue.x"}, {"not": {"has_clue": "clue.y"}}]}, s), "all+not")
	assert_true(Condition.evaluate({"any": [{"has_clue": "clue.y"}, {"has_clue": "clue.x"}]}, s), "any")
	assert_false(Condition.evaluate({"any": []}, s), "empty any is false")
	assert_false(Condition.evaluate([{"has_clue": "clue.x"}, {"has_clue": "clue.y"}], s), "array is AND")


func test_unknown_and_malformed_fail_closed() -> void:
	var s = GameState.new()
	assert_false(Condition.evaluate({"bogus": 1}, s), "unknown op")
	assert_false(Condition.evaluate({"has_clue": 5}, s), "wrong arg type")
	assert_false(Condition.evaluate("nonsense", s), "string condition")
	assert_false(Condition.evaluate({"all": "not an array"}, s), "all with non-array")


func test_collect_finds_ids_and_unknown_ops() -> void:
	var ids: Array = []
	var unknown: Array = []
	Condition.collect({"all": [{"has_clue": "clue.a"}, {"choice": {"id": "choice.b", "option": "x"}}, {"zap": 1}]}, ids, unknown)
	assert_true(ids.has("clue.a"), "clue id collected")
	assert_true(ids.has("choice.b"), "choice id collected")
	assert_eq(unknown, ["zap"], "unknown op collected")
