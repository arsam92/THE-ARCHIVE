extends RefCounted
## Walks a data-driven dialogue graph. No dialogue text or branching logic is
## hardcoded: nodes, conditions and effects all come from content.
##
## Node: {speaker?, text_key, portrait?, effects?, next?, end?, choices?}
## Choice: {text_key, next?, conditions?, effects?}

const Condition = preload("res://src/core/condition.gd")

var db
var effects
var state
var dialogue_id := ""
var node_id := ""
var finished := true
var events: Array = []   # effect events produced since start(), for the UI


func _init(p_db = null, p_effects = null) -> void:
	db = p_db
	effects = p_effects


func start(p_dialogue_id: String, p_state) -> bool:
	var d: Dictionary = db.get_entity(p_dialogue_id)
	if d.is_empty() or d.get("type", "") != "dialogue":
		return false
	dialogue_id = p_dialogue_id
	state = p_state
	events.clear()
	finished = false
	return _enter(String(d["start"]))


func _nodes() -> Dictionary:
	return db.get_entity(dialogue_id).get("nodes", {})


func _enter(nid: String) -> bool:
	var nodes := _nodes()
	if not nodes.has(nid) or not (nodes[nid] is Dictionary):
		# Bad content must end the conversation cleanly, never crash.
		finished = true
		node_id = ""
		return false
	node_id = nid
	events.append_array(effects.apply(nodes[nid].get("effects", []), state))
	return true


func current() -> Dictionary:
	if finished or node_id == "":
		return {}
	return _nodes()[node_id]


## Choices whose conditions currently pass. Each item keeps its original
## index so the UI can call choose(index) regardless of filtering.
func available_choices() -> Array:
	var out: Array = []
	var node := current()
	var list: Array = node.get("choices", [])
	for i in range(list.size()):
		var c = list[i]
		if c is Dictionary and Condition.evaluate(c.get("conditions", null), state):
			out.append({"index": i, "text_key": c.get("text_key", "")})
	return out


func choose(index: int) -> bool:
	if finished:
		return false
	var list: Array = current().get("choices", [])
	if index < 0 or index >= list.size():
		return false
	var c = list[index]
	if not (c is Dictionary) or not Condition.evaluate(c.get("conditions", null), state):
		return false
	events.append_array(effects.apply(c.get("effects", []), state))
	var nxt := String(c.get("next", ""))
	if nxt == "":
		finished = true
		return true
	_enter(nxt)
	return true


## Move past a linear node (one without choices).
func advance() -> bool:
	if finished:
		return false
	var node := current()
	if not node.get("choices", []).is_empty():
		return false
	var nxt := String(node.get("next", ""))
	if node.get("end", false) or nxt == "":
		finished = true
		return true
	return _enter(nxt)
