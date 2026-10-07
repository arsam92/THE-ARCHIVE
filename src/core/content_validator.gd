extends RefCounted
## Cross-checks a loaded ContentDB: dangling references, unknown operators,
## unreachable dialogue nodes, requires-cycles, missing translations. Run in CI
## and at startup. Never throws; returns {errors: [...], warnings: [...]}.

const Condition = preload("res://src/core/condition.gd")
const StoryGraph = preload("res://src/core/story_graph.gd")
const MessageSystem = preload("res://src/core/message_system.gd")

const PUZZLE_KINDS := ["code", "sequence", "pairing"]


static func validate(db, loc, effects) -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []

	for id in db.entities.keys():
		var e: Dictionary = db.entities[id]
		_check_refs(id, e, db, errors)
		if e.has("season") and db.type_of(String(e["season"])) != "season":
			errors.append("%s: season '%s' does not exist" % [id, str(e["season"])])
		if e.has("unlock"):
			_check_condition(id + ".unlock", e["unlock"], db, errors)
		match e["type"]:
			"message":
				_check_message(id, e, db, errors)
			"dialogue":
				_check_dialogue(id, e, db, effects, errors)
			"puzzle":
				_check_puzzle(id, e, db, effects, errors)
			"ending":
				_check_condition(id + ".conditions", e["conditions"], db, errors)
				if typeof(e["priority"]) != TYPE_INT and typeof(e["priority"]) != TYPE_FLOAT:
					errors.append("%s: priority must be a number" % id)
			"choice":
				_check_choice(id, e, errors)
		_check_locale_keys(id, e, loc, errors)

	_check_requires_cycles(db, errors)
	_check_season_graph(db, warnings)
	return {"errors": errors, "warnings": warnings}


static func _check_refs(id: String, e: Dictionary, db, errors: Array) -> void:
	for r in e.get("refs", []):
		var rel := String(r["rel"])
		var to := String(r["to"])
		if not StoryGraph.ALLOWED_RELS.has(rel):
			errors.append("%s: unknown relation '%s'" % [id, rel])
		if not db.has(to):
			errors.append("%s: dangling reference (%s -> %s)" % [id, rel, to])


static func _check_condition(label: String, cond, db, errors: Array) -> void:
	var ids: Array = []
	var unknown: Array = []
	Condition.collect(cond, ids, unknown)
	for op in unknown:
		errors.append("%s: unknown or malformed condition '%s'" % [label, str(op)])
	for ref in ids:
		if not db.has(String(ref)):
			errors.append("%s: condition references unknown id '%s'" % [label, str(ref)])


static func _check_message(id: String, e: Dictionary, db, errors: Array) -> void:
	var sender = e["sender"]
	if not (sender is Dictionary):
		errors.append("%s: sender must be an object" % id)
		return
	var displayed = sender.get("displayed")
	if not (displayed is Dictionary) or not (displayed.get("source") is String) or not (displayed.get("id") is String):
		errors.append("%s: sender.displayed needs string source and id" % id)
	var truth := String(sender.get("true_identity", ""))
	if db.type_of(truth) != "identity":
		errors.append("%s: sender.true_identity '%s' is not a known identity" % [id, truth])
	var auth = sender.get("authenticity", {})
	if auth is Dictionary:
		for key in ["displayed", "true"]:
			if auth.has(key) and not MessageSystem.AUTH_STATES.has(String(auth[key])):
				errors.append("%s: authenticity.%s '%s' is not a valid state" % [id, key, str(auth[key])])
		for c in auth.get("verify_with", []):
			if db.type_of(String(c)) != "clue":
				errors.append("%s: authenticity.verify_with '%s' is not a clue" % [id, str(c)])
	for a in e.get("attribution", []):
		if not (a is Dictionary):
			errors.append("%s: attribution entry is not an object" % id)
			continue
		if db.type_of(String(a.get("clue", ""))) != "clue":
			errors.append("%s: attribution clue '%s' is not a clue" % [id, str(a.get("clue"))])
		if db.type_of(String(a.get("identity", ""))) != "identity":
			errors.append("%s: attribution identity '%s' is not an identity" % [id, str(a.get("identity"))])
		var w = a.get("weight")
		if (typeof(w) != TYPE_INT and typeof(w) != TYPE_FLOAT) or float(w) <= 0.0:
			errors.append("%s: attribution weight must be a positive number" % id)


static func _check_choice(id: String, e: Dictionary, errors: Array) -> void:
	if not (e["options"] is Array) or e["options"].is_empty():
		errors.append("%s: options must be a non-empty array" % id)
		return
	var seen := {}
	for o in e["options"]:
		if not (o is Dictionary) or not (o.get("id") is String):
			errors.append("%s: every option needs a string id" % id)
			continue
		if seen.has(o["id"]):
			errors.append("%s: duplicate option id '%s'" % [id, o["id"]])
		seen[o["id"]] = true


static func _check_dialogue(id: String, e: Dictionary, db, effects, errors: Array) -> void:
	var nodes = e["nodes"]
	if not (nodes is Dictionary) or nodes.is_empty():
		errors.append("%s: nodes must be a non-empty object" % id)
		return
	if not nodes.has(String(e["start"])):
		errors.append("%s: start node '%s' does not exist" % [id, str(e["start"])])
	for nid in nodes.keys():
		var n = nodes[nid]
		var label := "%s.%s" % [id, nid]
		if not (n is Dictionary):
			errors.append("%s: node is not an object" % label)
			continue
		var speaker := String(n.get("speaker", ""))
		if speaker != "" and db.type_of(speaker) != "identity":
			errors.append("%s: speaker '%s' is not an identity" % [label, speaker])
		var nxt := String(n.get("next", ""))
		if nxt != "" and not nodes.has(nxt):
			errors.append("%s: next '%s' does not exist" % [label, nxt])
		_check_effects(label, n.get("effects", []), effects, errors)
		for i in range(n.get("choices", []).size()):
			var c = n["choices"][i]
			var clabel := "%s.choices[%d]" % [label, i]
			if not (c is Dictionary):
				errors.append("%s: choice is not an object" % clabel)
				continue
			var cn := String(c.get("next", ""))
			if cn != "" and not nodes.has(cn):
				errors.append("%s: next '%s' does not exist" % [clabel, cn])
			if c.has("conditions"):
				_check_condition(clabel + ".conditions", c["conditions"], db, errors)
			_check_effects(clabel, c.get("effects", []), effects, errors)


static func _check_puzzle(id: String, e: Dictionary, db, effects, errors: Array) -> void:
	var kind := String(e["kind"])
	if not PUZZLE_KINDS.has(kind):
		errors.append("%s: unknown puzzle kind '%s'" % [id, kind])
		return
	var sol = e["solution"]
	match kind:
		"code":
			if not (sol is String) or sol == "":
				errors.append("%s: code solution must be a non-empty string" % id)
		"sequence":
			if not (sol is Array) or sol.is_empty():
				errors.append("%s: sequence solution must be a non-empty array" % id)
		"pairing":
			var ok: bool = sol is Array and not sol.is_empty()
			if ok:
				for p in sol:
					if not (p is Array) or p.size() != 2:
						ok = false
			if not ok:
				errors.append("%s: pairing solution must be an array of [a, b] pairs" % id)
	_check_effects(id, e.get("effects", []), effects, errors)


static func _check_effects(label: String, list, effects, errors: Array) -> void:
	if not (list is Array):
		errors.append("%s: effects must be an array" % label)
		return
	for ef in list:
		var problem: String = effects.validate_effect(ef)
		if problem != "":
			errors.append("%s: %s" % [label, problem])


## Every "*_key" string anywhere inside an entity must exist as a translation.
static func _check_locale_keys(id: String, value, loc, errors: Array) -> void:
	var keys: Array = []
	_collect_keys(value, keys)
	for k in keys:
		if not loc.has_key(k):
			errors.append("%s: missing translation for key '%s'" % [id, k])


static func _collect_keys(value, out: Array) -> void:
	if value is Dictionary:
		for k in value.keys():
			if String(k).ends_with("_key") and value[k] is String:
				out.append(value[k])
			else:
				_collect_keys(value[k], out)
	elif value is Array:
		for v in value:
			_collect_keys(v, out)


## A clue that transitively requires itself can never be found.
static func _check_requires_cycles(db, errors: Array) -> void:
	var state := {}   # id -> 1 visiting, 2 done
	for id in db.entities.keys():
		if not state.has(id):
			_dfs_requires(id, db, state, [], errors)


static func _dfs_requires(id: String, db, state: Dictionary, path: Array, errors: Array) -> void:
	state[id] = 1
	path.append(id)
	for r in db.entities[id].get("refs", []):
		if r["rel"] != "requires" or not db.has(String(r["to"])):
			continue
		var to := String(r["to"])
		if state.get(to, 0) == 1:
			errors.append("requires-cycle: %s -> %s" % [" -> ".join(path), to])
		elif not state.has(to):
			_dfs_requires(to, db, state, path, errors)
	path.pop_back()
	state[id] = 2


static func _check_season_graph(db, warnings: Array) -> void:
	var seasons: Array = db.ids_of_type("season")
	if seasons.size() < 2:
		return
	for s in seasons:
		var linked := false
		for r in db.entities[s].get("refs", []):
			if r["rel"] == "connects_to" or r["rel"] == "reinterprets":
				linked = true
		if not linked:
			warnings.append("%s: season has no outgoing connects_to/reinterprets links" % s)
