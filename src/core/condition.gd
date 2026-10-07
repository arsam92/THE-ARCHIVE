extends RefCounted
## Declarative condition evaluator.
##
## Story logic lives in JSON, not in gameplay code. A condition is:
##   null or []            -> always true
##   Array                 -> every element must be true (AND)
##   Dictionary            -> every operator key must be true (AND)
##
## Operators:
##   {"all": [cond, ...]}  {"any": [cond, ...]}  {"not": cond}
##   {"has_clue": "clue.x"}
##   {"flag": "name"}  or  {"flag": {"id": "name", "equals": value}}
##   {"choice": {"id": "choice.x", "option": "a"}}
##   {"identified": "message.x"}               (sender currently resolved)
##   {"identity_is": {"message": "message.x", "identity": "identity.y"}}
##   {"season_unlocked": "season.n"}  {"season_done": "season.n"}
##   {"visited": "location.x"}  {"ending_seen": "ending.x"}  {"solved": "puzzle.x"}
##
## Unknown operators or malformed arguments evaluate to false (fail closed).

const KNOWN_OPS := [
	"all", "any", "not", "has_clue", "flag", "choice", "identified",
	"identity_is", "season_unlocked", "season_done", "visited",
	"ending_seen", "solved",
]


static func evaluate(cond, state) -> bool:
	if cond == null:
		return true
	if cond is Array:
		for c in cond:
			if not evaluate(c, state):
				return false
		return true
	if not (cond is Dictionary):
		return false
	for op in cond.keys():
		if not _eval_op(String(op), cond[op], state):
			return false
	return true


static func _eval_op(op: String, arg, state) -> bool:
	match op:
		"all":
			if not (arg is Array):
				return false
			for c in arg:
				if not evaluate(c, state):
					return false
			return true
		"any":
			if not (arg is Array):
				return false
			for c in arg:
				if evaluate(c, state):
					return true
			return false
		"not":
			return not evaluate(arg, state)
		"has_clue":
			return arg is String and state.has_clue(arg)
		"flag":
			if arg is String:
				return bool(state.get_flag(arg, false))
			if arg is Dictionary and arg.get("id") is String:
				return state.get_flag(arg["id"], null) == arg.get("equals", true)
			return false
		"choice":
			if arg is Dictionary and arg.get("id") is String:
				return state.get_choice(arg["id"]) == arg.get("option", null)
			return false
		"identified":
			return arg is String and state.identified.get(arg, "") != ""
		"identity_is":
			if arg is Dictionary and arg.get("message") is String and arg.get("identity") is String:
				return state.identified.get(arg["message"], "") == arg["identity"]
			return false
		"season_unlocked":
			return arg is String and state.unlocked_seasons.has(arg)
		"season_done":
			return arg is String and state.completed_seasons.has(arg)
		"visited":
			return arg is String and state.visited.has(arg)
		"ending_seen":
			return arg is String and state.endings_seen.has(arg)
		"solved":
			return arg is String and state.solved.has(arg)
	return false


## Walks a condition and collects every entity id it references plus any
## unknown operators. Used by the content validator.
static func collect(cond, out_ids: Array, out_unknown: Array) -> void:
	if cond == null:
		return
	if cond is Array:
		for c in cond:
			collect(c, out_ids, out_unknown)
		return
	if not (cond is Dictionary):
		out_unknown.append("<malformed:%s>" % str(cond))
		return
	for key in cond.keys():
		var op := String(key)
		var arg = cond[key]
		if not KNOWN_OPS.has(op):
			out_unknown.append(op)
			continue
		match op:
			"all", "any":
				if arg is Array:
					collect(arg, out_ids, out_unknown)
				else:
					out_unknown.append("<malformed:%s>" % op)
			"not":
				collect(arg, out_ids, out_unknown)
			"flag":
				pass
			"choice":
				if arg is Dictionary and arg.get("id") is String:
					out_ids.append(arg["id"])
				else:
					out_unknown.append("<malformed:choice>")
			"identity_is":
				if arg is Dictionary and arg.get("message") is String and arg.get("identity") is String:
					out_ids.append(arg["message"])
					out_ids.append(arg["identity"])
				else:
					out_unknown.append("<malformed:identity_is>")
			_:
				if arg is String:
					out_ids.append(arg)
				else:
					out_unknown.append("<malformed:%s>" % op)
