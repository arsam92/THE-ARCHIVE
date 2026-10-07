extends RefCounted
## Checks puzzle attempts against data-defined solutions.
## Kinds: "code" (string), "sequence" (ordered ids), "pairing" (evidence pairs,
## order irrelevant within and between pairs). Solving applies the puzzle's
## effects exactly once.

var db
var effects


func _init(p_db = null, p_effects = null) -> void:
	db = p_db
	effects = p_effects


## Returns {solved, already, valid_input}.
func attempt(puzzle_id: String, input, state) -> Dictionary:
	var p: Dictionary = db.get_entity(puzzle_id)
	var result := {"solved": false, "already": false, "valid_input": false}
	if p.is_empty() or p.get("type", "") != "puzzle":
		return result
	if state.solved.has(puzzle_id):
		result["solved"] = true
		result["already"] = true
		result["valid_input"] = true
		return result

	var ok := false
	match String(p.get("kind", "")):
		"code":
			if input is String or typeof(input) == TYPE_INT:
				result["valid_input"] = true
				ok = _norm_code(str(input)) == _norm_code(str(p["solution"]))
		"sequence":
			if input is Array and p["solution"] is Array:
				result["valid_input"] = true
				ok = _strings(input) == _strings(p["solution"])
		"pairing":
			if input is Array and p["solution"] is Array and _pairs_ok(input):
				result["valid_input"] = true
				ok = _pair_set(input) == _pair_set(p["solution"])

	if ok:
		state.solved[puzzle_id] = true
		effects.apply(p.get("effects", []), state)
		result["solved"] = true
	return result


static func _norm_code(s: String) -> String:
	return s.strip_edges().to_lower().replace(" ", "").replace("-", "")


static func _strings(a: Array) -> Array:
	var out: Array = []
	for v in a:
		out.append(str(v))
	return out


static func _pairs_ok(a: Array) -> bool:
	for p in a:
		if not (p is Array) or p.size() != 2:
			return false
	return true


static func _pair_set(pairs: Array) -> Array:
	var keys: Array = []
	for p in pairs:
		var a := str(p[0])
		var b := str(p[1])
		keys.append("%s|%s" % ([a, b] if a < b else [b, a]))
	keys.sort()
	return keys
