extends RefCounted
## Applies declarative effects (from dialogue, puzzles, choices) to GameState.
## Effects are data: {"op": "add_clue", "id": "clue.x"}. Unknown ops are
## rejected by the validator and ignored at runtime.

const OPS := {
	# op -> [required string fields, expected entity type of "id" or ""]
	"add_clue": ["clue"],
	"deliver_message": ["message"],
	"reveal_sender": ["message"],
	"set_flag": [""],
	"set_choice": ["choice"],
	"unlock_season": ["season"],
	"complete_season": ["season"],
	"set_season": ["season"],
	"visit": ["location"],
	"trigger_ending": ["ending"],
}

var db
var messages   # MessageSystem or null


func _init(p_db = null, p_messages = null) -> void:
	db = p_db
	messages = p_messages


## Returns "" when the effect is well formed, otherwise a description.
func validate_effect(effect) -> String:
	if not (effect is Dictionary):
		return "effect is not an object"
	var op = effect.get("op")
	if not (op is String) or not OPS.has(op):
		return "unknown op '%s'" % str(op)
	if not (effect.get("id") is String) or effect["id"] == "":
		return "op '%s' needs a string id" % op
	var want: String = OPS[op][0]
	if want != "":
		if db == null or not db.has(effect["id"]):
			return "op '%s' references unknown id '%s'" % [op, effect["id"]]
		if db.type_of(effect["id"]) != want:
			return "op '%s' expects a %s id, got '%s'" % [op, want, effect["id"]]
	if op == "set_choice" and not (effect.get("option") is String):
		return "op 'set_choice' needs a string option"
	return ""


func apply(effect_list, state) -> Array:
	var events: Array = []
	if not (effect_list is Array):
		return events
	for effect in effect_list:
		var ev := _apply_one(effect, state)
		if not ev.is_empty():
			events.append(ev)
	return events


func _apply_one(effect, state) -> Dictionary:
	if validate_effect(effect) != "":
		return {}
	var op: String = effect["op"]
	var id: String = effect["id"]
	var is_new := true
	match op:
		"add_clue":
			is_new = state.add_clue(id)
			if is_new and messages != null:
				messages.refresh_all(state)
		"deliver_message":
			is_new = state.receive_message(id)
			if is_new and messages != null:
				messages.refresh(id, state)
		"reveal_sender":
			is_new = not state.revealed.has(id)
			state.revealed[id] = true
			if messages != null:
				messages.refresh(id, state)
		"set_flag":
			state.set_flag(id, effect.get("value", true))
		"set_choice":
			state.set_choice(id, effect["option"])
		"unlock_season":
			is_new = not state.unlocked_seasons.has(id)
			state.unlocked_seasons[id] = true
		"complete_season":
			is_new = not state.completed_seasons.has(id)
			state.completed_seasons[id] = true
		"set_season":
			state.current_season = id
			state.unlocked_seasons[id] = true
		"visit":
			is_new = not state.visited.has(id)
			state.visited[id] = true
		"trigger_ending":
			is_new = not state.endings_seen.has(id)
			state.endings_seen[id] = true
	return {"op": op, "id": id, "new": is_new}
