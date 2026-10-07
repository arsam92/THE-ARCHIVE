extends RefCounted
## Read-only graph view over the content database. Every entity can reference
## any other (clues, identities, messages, files, locations, seasons, choices),
## including forward references to content that appears in later seasons.
## Edges come from each entity's "refs": [{"rel": "...", "to": "id"}].

const Condition = preload("res://src/core/condition.gd")

const ALLOWED_RELS := [
	"requires", "reveals", "references", "foreshadows", "echoes",
	"contradicts", "identifies", "located_in", "appears_in",
	"authored_by", "reinterprets", "connects_to",
]

var db
var _out := {}   # id -> Array of {rel, to}
var _in := {}    # id -> Array of {rel, from}


func build(p_db) -> void:
	db = p_db
	_out.clear()
	_in.clear()
	for id in db.entities.keys():
		for r in db.entities[id].get("refs", []):
			var rel := String(r["rel"])
			var to := String(r["to"])
			if not _out.has(id):
				_out[id] = []
			_out[id].append({"rel": rel, "to": to})
			if not _in.has(to):
				_in[to] = []
			_in[to].append({"rel": rel, "from": id})


## Outgoing edges of an entity, optionally filtered by relation.
func outgoing(id: String, rel: String = "") -> Array:
	var out: Array = []
	for e in _out.get(id, []):
		if rel == "" or e["rel"] == rel:
			out.append(e)
	return out


func incoming(id: String, rel: String = "") -> Array:
	var out: Array = []
	for e in _in.get(id, []):
		if rel == "" or e["rel"] == rel:
			out.append(e)
	return out


func targets(id: String, rel: String = "") -> Array:
	var out: Array = []
	for e in outgoing(id, rel):
		out.append(e["to"])
	return out


func season_of(id: String) -> String:
	var e: Dictionary = db.get_entity(id)
	if e.get("type", "") == "season":
		return id
	return String(e.get("season", ""))


## Edges that cross from one season into another, touching the given season.
func cross_season_links(season_id: String) -> Array:
	var out: Array = []
	for from in _out.keys():
		var from_season := season_of(from)
		for e in _out[from]:
			var to_season := season_of(e["to"])
			if from_season == "" or to_season == "" or from_season == to_season:
				continue
			if from_season == season_id or to_season == season_id:
				out.append({"from": from, "to": e["to"], "rel": e["rel"]})
	return out


## Everything reachable by following outgoing edges (optionally only some rels).
func reachable_from(id: String, rels: Array = []) -> Array:
	var seen := {}
	var queue: Array = [id]
	while not queue.is_empty():
		var cur: String = queue.pop_front()
		for e in _out.get(cur, []):
			if not rels.is_empty() and not rels.has(e["rel"]):
				continue
			if not seen.has(e["to"]):
				seen[e["to"]] = true
				queue.append(e["to"])
	seen.erase(id)
	var out := seen.keys()
	out.sort()
	return out


## True if the player could find this clue right now: its season is unlocked,
## every "requires" target is already known, and its unlock condition holds.
func is_clue_available(clue_id: String, state) -> bool:
	var c: Dictionary = db.get_entity(clue_id)
	if c.is_empty() or c.get("type", "") != "clue":
		return false
	if state.has_clue(clue_id):
		return false
	if not state.unlocked_seasons.has(String(c.get("season", ""))):
		return false
	for req in targets(clue_id, "requires"):
		if db.type_of(req) == "clue" and not state.has_clue(req):
			return false
	return Condition.evaluate(c.get("unlock", null), state)


func available_clues(state) -> Array:
	var out: Array = []
	for id in db.ids_of_type("clue"):
		if is_clue_available(id, state):
			out.append(id)
	return out
