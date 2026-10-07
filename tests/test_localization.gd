extends "res://tests/test_case.gd"

const Localization = preload("res://src/core/localization.gd")


func _loc():
	var l = Localization.new()
	l.add_strings("en", {"hello": "Hello {name}", "only_en": "English only", "plain": "Plain"})
	l.add_strings("tr", {"hello": "Merhaba {name}", "plain": "Sade", "extra": "Fazla"})
	return l


func test_lookup_and_placeholders() -> void:
	var l = _loc()
	assert_eq(l.t("hello", {"name": "Ada"}), "Hello Ada", "english with args")
	assert_true(l.set_language("tr"), "switch language")
	assert_eq(l.t("hello", {"name": "Ada"}), "Merhaba Ada", "turkish with args")


func test_falls_back_to_english_then_marks_missing() -> void:
	var l = _loc()
	l.set_language("tr")
	assert_eq(l.t("only_en"), "English only", "fallback to en")
	assert_eq(l.t("nonexistent"), "[nonexistent]", "visible placeholder, no crash")
	assert_true(l.missing.has("nonexistent"), "recorded for QA")
	assert_false(l.missing.has("only_en"), "fallback hit is not missing")


func test_unknown_language_is_refused() -> void:
	var l = _loc()
	assert_false(l.set_language("xx"), "unsupported language")
	assert_eq(l.language, "en", "unchanged")


func test_locale_code_normalization() -> void:
	assert_eq(Localization.normalize_locale("tr_TR"), "tr", "underscore")
	assert_eq(Localization.normalize_locale("pt-BR"), "pt", "hyphen")
	assert_eq(Localization.normalize_locale("EN"), "en", "case")
	assert_eq(Localization.normalize_locale(""), "en", "empty defaults to en")
	var l = _loc()
	assert_true(l.has_language("TR_tr"), "lookup normalizes")


func test_coverage_report() -> void:
	var l = _loc()
	var c: Dictionary = l.coverage("tr")
	assert_eq(c["missing"], ["only_en"], "untranslated keys")
	assert_eq(c["extra"], ["extra"], "keys with no english source")


func test_non_string_entries_are_ignored() -> void:
	var l = Localization.new()
	l.add_strings("en", {"ok": "fine", "bad": 5, 7: "seven"})
	assert_true(l.has_key("ok"), "valid kept")
	assert_false(l.has_key("bad"), "non-string value dropped")


func test_core_pack_strings_cover_all_keys_used_by_content() -> void:
	# Validator already enforces this; assert directly for the shipped pack.
	var rt = make_runtime()
	assert_eq(rt.loc.coverage("en")["missing"].size(), 0, "english is the base")
	for id in rt.db.ids_of_type("identity"):
		assert_true(rt.loc.has_key(rt.db.get_entity(id)["name_key"]), "name for " + id)
