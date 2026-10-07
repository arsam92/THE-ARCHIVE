extends "res://tests/test_case.gd"

const MSG := "message.fx_17a"


func _setup():
	var rt = make_runtime()
	rt.loc.set_language("en")
	rt.effects.apply([{"op": "deliver_message", "id": MSG}], rt.state)
	return rt


func test_anonymous_header_hides_everything_at_first() -> void:
	var rt = _setup()
	var h: Dictionary = rt.messages.display_header(MSG, rt.state, rt.loc)
	assert_eq(h["source"], "UNKNOWN", "source")
	assert_eq(h["id"], "17-A", "id")
	assert_eq(h["authenticity"], "UNKNOWN", "authenticity")
	assert_false(h["identified"], "not identified")
	assert_eq(rt.messages.header_text(MSG, rt.state, rt.loc), "SOURCE: UNKNOWN\nID: 17-A\nAUTHENTICITY: UNKNOWN", "header text")


func test_sender_is_not_revealed_automatically() -> void:
	var rt = _setup()
	# A single piece of evidence is below the threshold.
	rt.effects.apply([{"op": "add_clue", "id": "clue.fx_a"}], rt.state)
	assert_eq(rt.state.identified[MSG], "", "still unresolved")
	assert_eq(rt.messages.display_header(MSG, rt.state, rt.loc)["source"], "UNKNOWN", "still anonymous")


func test_identity_is_inferred_from_evidence() -> void:
	var rt = _setup()
	rt.effects.apply([{"op": "add_clue", "id": "clue.fx_a"}, {"op": "add_clue", "id": "clue.fx_b"}], rt.state)
	assert_eq(rt.state.identified[MSG], "identity.nora", "evidence points to Nora")
	var h: Dictionary = rt.messages.display_header(MSG, rt.state, rt.loc)
	assert_eq(h["source"], "Nora", "name shown once identified")
	assert_eq(h["id"], "17-A", "message id still shown")


func test_authenticity_changes_only_after_verification_clues() -> void:
	var rt = _setup()
	assert_eq(rt.messages.authenticity(MSG, rt.state), "UNKNOWN", "before")
	rt.effects.apply([{"op": "add_clue", "id": "clue.fx_a"}], rt.state)
	assert_eq(rt.messages.authenticity(MSG, rt.state), "UNKNOWN", "partial evidence not enough")
	rt.effects.apply([{"op": "add_clue", "id": "clue.fx_b"}], rt.state)
	assert_eq(rt.messages.authenticity(MSG, rt.state), "SUSPECT", "verified by clue fx_b")


func test_later_evidence_can_overturn_an_earlier_inference() -> void:
	var rt = _setup()
	rt.effects.apply([{"op": "add_clue", "id": "clue.fx_a"}, {"op": "add_clue", "id": "clue.fx_b"}], rt.state)
	assert_eq(rt.state.identified[MSG], "identity.nora", "initial inference")
	# Competing evidence narrows the lead below the required margin.
	rt.effects.apply([{"op": "add_clue", "id": "clue.fx_decoy"}, {"op": "add_clue", "id": "clue.fx_d"}], rt.state)
	assert_eq(rt.state.identified[MSG], "", "inference withdrawn")
	assert_eq(rt.state.identity_history[MSG], ["", "identity.nora", ""], "history shows the reinterpretation")


func test_story_beat_can_reveal_the_true_sender() -> void:
	var rt = _setup()
	rt.effects.apply([{"op": "reveal_sender", "id": MSG}], rt.state)
	assert_eq(rt.state.identified[MSG], "identity.observer", "true identity revealed")
	assert_eq(rt.messages.authenticity(MSG, rt.state), "SUSPECT", "true authenticity revealed")
	# Revealed state is sticky even when evidence disagrees.
	rt.effects.apply([{"op": "add_clue", "id": "clue.fx_a"}, {"op": "add_clue", "id": "clue.fx_b"}], rt.state)
	assert_eq(rt.state.identified[MSG], "identity.observer", "stays revealed")


func test_unreceived_messages_are_not_processed() -> void:
	var rt = make_runtime()
	assert_false(rt.messages.refresh(MSG, rt.state), "not received yet")
	assert_false(rt.state.identified.has(MSG), "no entry created")


func test_scores_accumulate_per_identity() -> void:
	var rt = _setup()
	rt.state.add_clue("clue.fx_a")
	rt.state.add_clue("clue.fx_decoy")
	var s: Dictionary = rt.messages.scores(MSG, rt.state)
	assert_eq(snappedf(s["identity.nora"], 0.01), 0.6, "nora")
	assert_eq(snappedf(s["identity.elias"], 0.01), 0.6, "elias")
