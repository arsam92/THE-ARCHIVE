extends RefCounted
## Mutable player progress. Pure data, no engine nodes, fully serializable.
## Story content never lives here; only what the player has done and found.

const STATE_VERSION := 1

var current_season := "season.1"
var clues := {}                 # clue id -> true
var clue_order: Array = []      # discovery order
var received: Array = []        # message ids, in delivery order
var flags := {}                 # name -> value
var choices := {}               # choice id -> option id
var identified := {}            # message id -> identity id currently inferred ("" = unresolved)
var identity_history := {}      # message id -> Array of identity ids over time
var revealed := {}              # message id -> true when a story beat forced the true sender
var unlocked_seasons := {"season.1": true}
var completed_seasons := {}
var visited := {}
var solved := {}
var endings_seen := {}
var play_seconds := 0.0


func add_clue(id: String) -> bool:
	if clues.has(id):
		return false
	clues[id] = true
	clue_order.append(id)
	return true


func has_clue(id: String) -> bool:
	return clues.has(id)


func receive_message(id: String) -> bool:
	if received.has(id):
		return false
	received.append(id)
	return true


func set_flag(id: String, value = true) -> void:
	flags[id] = value


func get_flag(id: String, default = null):
	return flags.get(id, default)


func set_choice(id: String, option: String) -> void:
	choices[id] = option


func get_choice(id: String):
	return choices.get(id, null)


## Records the inferred sender of a message. Returns true if it changed.
func set_identified(message_id: String, identity_id: String) -> bool:
	if identified.get(message_id, "") == identity_id and identity_history.has(message_id):
		return false
	var old: String = identified.get(message_id, "")
	identified[message_id] = identity_id
	if old != identity_id or not identity_history.has(message_id):
		var h: Array = identity_history.get(message_id, [])
		h.append(identity_id)
		identity_history[message_id] = h
	return old != identity_id


func to_dict() -> Dictionary:
	return {
		"version": STATE_VERSION,
		"current_season": current_season,
		"clues": clue_order.duplicate(),
		"received": received.duplicate(),
		"flags": flags.duplicate(true),
		"choices": choices.duplicate(),
		"identified": identified.duplicate(),
		"identity_history": identity_history.duplicate(true),
		"revealed": _sorted_keys(revealed),
		"unlocked_seasons": _sorted_keys(unlocked_seasons),
		"completed_seasons": _sorted_keys(completed_seasons),
		"visited": _sorted_keys(visited),
		"solved": _sorted_keys(solved),
		"endings_seen": _sorted_keys(endings_seen),
		"play_seconds": play_seconds,
	}


## Loads a dictionary produced by to_dict(). Strictly validated: on any
## problem the object is left untouched and false is returned.
func from_dict(d) -> bool:
	if not (d is Dictionary):
		return false
	var ver = d.get("version")
	if typeof(ver) != TYPE_INT and typeof(ver) != TYPE_FLOAT:
		return false
	if int(ver) < 1 or int(ver) > STATE_VERSION:
		return false

	var season = d.get("current_season")
	var clue_list = _strings(d.get("clues"))
	var recv_list = _strings(d.get("received"))
	var flag_dict = d.get("flags")
	var choice_dict = d.get("choices")
	var ident_dict = d.get("identified")
	var hist_dict = d.get("identity_history")
	var revealed_list = _strings(d.get("revealed"))
	var unlocked_list = _strings(d.get("unlocked_seasons"))
	var completed_list = _strings(d.get("completed_seasons"))
	var visited_list = _strings(d.get("visited"))
	var solved_list = _strings(d.get("solved"))
	var endings_list = _strings(d.get("endings_seen"))
	var secs = d.get("play_seconds", 0.0)

	if not (season is String) or season == "":
		return false
	for v in [clue_list, recv_list, revealed_list, unlocked_list, completed_list, visited_list, solved_list, endings_list]:
		if v == null:
			return false
	if not (flag_dict is Dictionary) or not _string_map(choice_dict) or not _string_map(ident_dict):
		return false
	if not (hist_dict is Dictionary):
		return false
	for k in hist_dict.keys():
		if not (k is String) or _strings(hist_dict[k]) == null:
			return false
	if typeof(secs) != TYPE_INT and typeof(secs) != TYPE_FLOAT:
		return false

	current_season = season
	clue_order = clue_list.duplicate()
	clues = _to_set(clue_list)
	received = recv_list.duplicate()
	flags = flag_dict.duplicate(true)
	choices = choice_dict.duplicate()
	identified = ident_dict.duplicate()
	identity_history = hist_dict.duplicate(true)
	revealed = _to_set(revealed_list)
	unlocked_seasons = _to_set(unlocked_list)
	completed_seasons = _to_set(completed_list)
	visited = _to_set(visited_list)
	solved = _to_set(solved_list)
	endings_seen = _to_set(endings_list)
	play_seconds = float(secs)
	return true


static func _sorted_keys(set: Dictionary) -> Array:
	var keys := set.keys()
	keys.sort()
	return keys


static func _to_set(list: Array) -> Dictionary:
	var out := {}
	for v in list:
		out[v] = true
	return out


## Returns the array if every element is a String, else null.
static func _strings(v):
	if not (v is Array):
		return null
	for e in v:
		if not (e is String):
			return null
	return v


static func _string_map(v) -> bool:
	if not (v is Dictionary):
		return false
	for k in v.keys():
		if not (k is String) or not (v[k] is String):
			return false
	return true
