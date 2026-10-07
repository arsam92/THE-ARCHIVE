extends RefCounted
## Picks the ending that matches the player's progress. Endings are data:
## each has a priority and a condition; the highest-priority match wins, and
## ties break on id so results are deterministic.

const Condition = preload("res://src/core/condition.gd")

var db


func _init(p_db = null) -> void:
	db = p_db


## All endings whose conditions hold, best first.
func matching(state) -> Array:
	var found: Array = []
	for id in db.ids_of_type("ending"):
		var e: Dictionary = db.get_entity(id)
		if Condition.evaluate(e.get("conditions", null), state):
			found.append(id)
	found.sort_custom(func(a, b):
		var pa := float(db.get_entity(a).get("priority", 0))
		var pb := float(db.get_entity(b).get("priority", 0))
		if pa == pb:
			return a < b
		return pa > pb)
	return found


func resolve(state) -> String:
	var m := matching(state)
	return "" if m.is_empty() else String(m[0])
