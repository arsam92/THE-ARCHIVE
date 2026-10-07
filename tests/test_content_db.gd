extends "res://tests/test_case.gd"

const ContentDB = preload("res://src/core/content_db.gd")


func test_core_pack_loads_cleanly() -> void:
	var db = ContentDB.new()
	assert_true(db.load_pack_dir(CORE), "core loads")
	assert_eq(db.errors.size(), 0, "no errors: " + str(db.errors))
	assert_eq(db.ids_of_type("season").size(), 4, "four seasons")
	assert_eq(db.ids_of_type("identity").size(), 7, "seven identities")


func test_fixture_pack_loads_after_dependency() -> void:
	var db = ContentDB.new()
	db.load_pack_dir(CORE)
	assert_true(db.load_pack_dir(FIXTURE_BASIC), "fixture loads")
	assert_eq(db.errors.size(), 0, "no errors: " + str(db.errors))
	assert_true(db.has("clue.fx_a"), "fixture clue present")
	assert_true(db.locale_strings["en"].has("fx.clue.a"), "fixture locale merged")


func test_missing_dependency_is_rejected() -> void:
	var db = ContentDB.new()
	assert_false(db.load_pack_dir(FIXTURE_BASIC), "needs core first")
	assert_has_substring(db.errors, "dependency", "dependency error reported")
	assert_eq(db.entities.size(), 0, "nothing loaded")


func test_broken_pack_is_survived_and_reported() -> void:
	var db = ContentDB.new()
	db.load_pack_dir(CORE)
	assert_true(db.load_pack_dir(FIXTURE_BROKEN), "manifest valid so pack registers")
	assert_has_substring(db.errors, "invalid JSON", "bad json file")
	assert_has_substring(db.errors, "missing or malformed id", "missing id")
	assert_has_substring(db.errors, "unknown type", "unknown type")
	assert_has_substring(db.errors, "duplicate id", "duplicate id")
	assert_has_substring(db.errors, "not an object", "non-object entity")
	assert_true(db.has("clue.bk_ok"), "good entities still load")
	# 11 core entities (4 seasons + 7 identities) + 8 well-formed broken-pack entities
	assert_eq(db.entities.size(), 19, "expected survivors")


func test_path_traversal_in_manifest_is_rejected() -> void:
	var db = ContentDB.new()
	assert_false(db.load_pack_dir(FIXTURE_TRAVERSAL), "traversal manifest refused")
	assert_has_substring(db.errors, "unsafe path", "reported")
	assert_eq(db.entities.size(), 0, "nothing loaded")


func test_missing_pack_dir_is_reported_not_fatal() -> void:
	var db = ContentDB.new()
	assert_false(db.load_pack_dir("res://does/not/exist"), "missing pack")
	assert_has_substring(db.errors, "not found", "reported")


func test_duplicate_pack_is_rejected() -> void:
	var db = ContentDB.new()
	db.load_pack_dir(CORE)
	assert_false(db.load_pack_dir(CORE), "second load of same pack")
	assert_has_substring(db.errors, "already loaded", "reported")
	assert_eq(db.ids_of_type("season").size(), 4, "no duplicate entities")


func test_entity_shape_rules() -> void:
	var db = ContentDB.new()
	assert_false(db.add_entity({"id": "clue.x", "type": "clue"}, "t", "t"), "missing required fields")
	assert_false(db.add_entity({"id": "Clue.X", "type": "clue", "season": "s", "title_key": "k"}, "t", "t"), "bad id chars")
	assert_false(db.add_entity({"id": "file.x", "type": "clue", "season": "s", "title_key": "k"}, "t", "t"), "id prefix must match type")
	assert_false(db.add_entity({"id": "clue.x", "type": "clue", "season": "s", "title_key": "k", "refs": "no"}, "t", "t"), "refs must be array")
	assert_false(db.add_entity({"id": "clue.x", "type": "clue", "season": "s", "title_key": "k", "refs": [{"rel": "requires"}]}, "t", "t"), "ref needs target")
	assert_true(db.add_entity({"id": "clue.x", "type": "clue", "season": "s", "title_key": "k"}, "t", "t"), "valid entity")
