extends RefCounted
## Anonymous message system.
##
## A message is shown as SOURCE / ID / AUTHENTICITY. The true sender is never
## revealed automatically. Instead each discovered clue adds evidence weight
## toward an identity; the sender is "identified" only when one identity leads
## clearly. Later evidence can overturn an earlier inference (reinterpretation),
## and the history of inferences is kept.
##
## Message data (see docs/CONTENT_SCHEMA.md):
##   sender.displayed   {source, id}            what the player sees at first
##   sender.true_identity                      authoritative answer (hidden)
##   sender.authenticity {displayed, true, verify_with:[clue ids]}
##   attribution        [{clue, identity, weight}]  evidence toward identities

const AUTH_STATES := ["UNKNOWN", "VERIFIED", "SUSPECT", "FORGED"]
const EPSILON := 0.0001

var db
var identify_threshold := 1.0   # minimum score the leading identity needs
var identify_margin := 0.5      # minimum lead over the runner-up


func _init(p_db = null, threshold: float = 1.0, margin: float = 0.5) -> void:
	db = p_db
	identify_threshold = threshold
	identify_margin = margin


## identity id -> accumulated evidence from discovered clues.
func scores(message_id: String, state) -> Dictionary:
	var out := {}
	var msg: Dictionary = db.get_entity(message_id)
	for a in msg.get("attribution", []):
		if not (a is Dictionary):
			continue
		if state.has_clue(String(a.get("clue", ""))):
			var who := String(a.get("identity", ""))
			out[who] = float(out.get(who, 0.0)) + float(a.get("weight", 0.0))
	return out


## The identity the evidence currently supports, or "" when inconclusive.
func resolve_identity(message_id: String, state) -> String:
	var msg: Dictionary = db.get_entity(message_id)
	if msg.is_empty():
		return ""
	if state.revealed.has(message_id):
		return String(msg.get("sender", {}).get("true_identity", ""))
	var s := scores(message_id, state)
	var best := ""
	var best_score := 0.0
	var second_score := 0.0
	for who in s.keys():
		var v: float = s[who]
		if v > best_score:
			second_score = best_score
			best_score = v
			best = who
		elif v > second_score:
			second_score = v
	if best == "":
		return ""
	if best_score + EPSILON < identify_threshold:
		return ""
	if best_score - second_score + EPSILON < identify_margin:
		return ""
	return best


## Recomputes one received message. Returns true if the inference changed.
func refresh(message_id: String, state) -> bool:
	if not state.received.has(message_id):
		return false
	return state.set_identified(message_id, resolve_identity(message_id, state))


func refresh_all(state) -> Array:
	var changed: Array = []
	for id in state.received:
		if refresh(id, state):
			changed.append(id)
	return changed


func authenticity(message_id: String, state) -> String:
	var auth: Dictionary = db.get_entity(message_id).get("sender", {}).get("authenticity", {})
	var shown := String(auth.get("displayed", "UNKNOWN"))
	var truth := String(auth.get("true", shown))
	if state.revealed.has(message_id):
		return truth
	var need: Array = auth.get("verify_with", [])
	if need.is_empty():
		return shown
	for c in need:
		if not state.has_clue(String(c)):
			return shown
	return truth


## Structured header for the UI. Never leaks the true identity early.
func display_header(message_id: String, state, loc) -> Dictionary:
	var msg: Dictionary = db.get_entity(message_id)
	var displayed: Dictionary = msg.get("sender", {}).get("displayed", {})
	var identity: String = state.identified.get(message_id, "")
	var source := String(displayed.get("source", "UNKNOWN"))
	if identity != "":
		var ent: Dictionary = db.get_entity(identity)
		source = loc.t(String(ent.get("name_key", identity)))
	return {
		"source": source,
		"id": String(displayed.get("id", "")),
		"authenticity": authenticity(message_id, state),
		"identified": identity != "",
		"identity_id": identity,
	}


func header_text(message_id: String, state, loc) -> String:
	var h := display_header(message_id, state, loc)
	return "%s: %s\n%s: %s\n%s: %s" % [
		loc.t("ui.source"), h["source"],
		loc.t("ui.id"), h["id"],
		loc.t("ui.authenticity"), loc.t("auth." + String(h["authenticity"])),
	]
