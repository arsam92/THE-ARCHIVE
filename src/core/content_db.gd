extends RefCounted
## Loads content packs (manifest + JSON entity files) into one id-indexed
## database. Loading is defensive: malformed packs, files or entities are
## skipped and reported in `errors`; nothing here is allowed to crash the game.
## Packs can live in res:// (shipped) or user:// (downloaded narrative content).

const CONTENT_SCHEMA_VERSION := 1
const MAX_FILE_BYTES := 4 * 1024 * 1024

const ENTITY_TYPES := [
	"season", "location", "identity", "clue", "message", "file",
	"choice", "dialogue", "puzzle", "ending",
]

const REQUIRED_FIELDS := {
	"season": ["order", "name_key"],
	"location": ["season", "name_key"],
	"identity": ["name_key"],
	"clue": ["season", "title_key"],
	"message": ["season", "body_key", "sender"],
	"file": ["season", "title_key"],
	"choice": ["season", "options"],
	"dialogue": ["season", "start", "nodes"],
	"puzzle": ["season", "kind", "solution"],
	"ending": ["conditions", "priority", "title_key"],
}

var entities := {}          # id -> Dictionary
var by_type := {}           # type -> Array of ids (load order)
var packs := {}             # pack id -> manifest
var locale_strings := {}    # lang -> {key: text}
var errors: Array[String] = []
var warnings: Array[String] = []

var _id_regex := RegEx.new()
var _pack_regex := RegEx.new()


func _init() -> void:
	_id_regex.compile("^[a-z]+\\.[a-z0-9_]+$")
	_pack_regex.compile("^[a-z0-9_]+$")
	for t in ENTITY_TYPES:
		by_type[t] = []


func has(id: String) -> bool:
	return entities.has(id)


func get_entity(id: String) -> Dictionary:
	return entities.get(id, {})


func ids_of_type(type: String) -> Array:
	return by_type.get(type, [])


func type_of(id: String) -> String:
	return String(entities.get(id, {}).get("type", ""))


## Loads one pack directory (must contain manifest.json). Returns true when the
## manifest was valid and the pack registered, even if some entities were
## rejected; check `errors` for details.
func load_pack_dir(dir: String) -> bool:
	var manifest_text = _read_text(dir.path_join("manifest.json"))
	if manifest_text == null:
		return false
	var manifest = _parse_json(manifest_text, dir + "/manifest.json")
	if manifest == null:
		return false
	var problem := _check_manifest(manifest)
	if problem != "":
		errors.append("%s: invalid manifest: %s" % [dir, problem])
		return false

	var pack_id: String = manifest["pack_id"]
	packs[pack_id] = manifest

	for rel in manifest["files"]:
		var label := "%s/%s" % [pack_id, rel]
		var text = _read_text(dir.path_join(rel))
		if text == null:
			continue
		var data = _parse_json(text, label)
		if data == null:
			continue
		var list = data
		if data is Dictionary and data.get("entities") is Array:
			list = data["entities"]
		if not (list is Array):
			errors.append("%s: expected an array of entities" % label)
			continue
		for i in range(list.size()):
			add_entity(list[i], pack_id, "%s[%d]" % [label, i])

	var locales = manifest.get("locales", {})
	for lang in locales.keys():
		_load_locale(String(lang), dir.path_join(String(locales[lang])), pack_id)
	return true


## Validates and registers a single entity. Returns false (and records an
## error) when it is rejected.
func add_entity(e, pack_id: String, label: String) -> bool:
	if not (e is Dictionary):
		errors.append("%s: entity is not an object" % label)
		return false
	var id = e.get("id")
	if not (id is String) or not _id_regex.search(id):
		errors.append("%s: missing or malformed id (%s)" % [label, str(id)])
		return false
	var type = e.get("type")
	if not (type is String) or not ENTITY_TYPES.has(type):
		errors.append("%s: %s has unknown type '%s'" % [label, id, str(type)])
		return false
	if not id.begins_with(type + "."):
		errors.append("%s: id '%s' must start with '%s.'" % [label, id, type])
		return false
	for field in REQUIRED_FIELDS[type]:
		if not e.has(field):
			errors.append("%s: %s is missing required field '%s'" % [label, id, field])
			return false
	if entities.has(id):
		errors.append("%s: duplicate id '%s' (already defined by pack '%s')" % [label, id, entities[id].get("_pack", "?")])
		return false
	if e.has("refs"):
		if not (e["refs"] is Array):
			errors.append("%s: %s refs must be an array" % [label, id])
			return false
		for r in e["refs"]:
			if not (r is Dictionary) or not (r.get("rel") is String) or not (r.get("to") is String):
				errors.append("%s: %s has a malformed ref (needs string 'rel' and 'to')" % [label, id])
				return false
	var stored: Dictionary = e.duplicate(true)
	stored["_pack"] = pack_id
	entities[id] = stored
	by_type[type].append(id)
	return true


func _check_manifest(m) -> String:
	if not (m is Dictionary):
		return "not an object"
	var pid = m.get("pack_id")
	if not (pid is String) or not _pack_regex.search(pid):
		return "pack_id must match [a-z0-9_]+"
	if packs.has(pid):
		return "pack '%s' already loaded" % pid
	if not (m.get("version") is String):
		return "version must be a string"
	var schema = m.get("schema")
	if (typeof(schema) != TYPE_INT and typeof(schema) != TYPE_FLOAT) or int(schema) < 1:
		return "schema must be a positive number"
	if int(schema) > CONTENT_SCHEMA_VERSION:
		return "schema %d is newer than this build supports (%d)" % [int(schema), CONTENT_SCHEMA_VERSION]
	if not (m.get("files") is Array):
		return "files must be an array"
	for f in m["files"]:
		var err := _check_relative_path(f)
		if err != "":
			return "files: " + err
	var deps = m.get("dependencies", [])
	if not (deps is Array):
		return "dependencies must be an array"
	for d in deps:
		if not (d is String) or not packs.has(d):
			return "dependency '%s' is not loaded (load order matters)" % str(d)
	var loc = m.get("locales", {})
	if not (loc is Dictionary):
		return "locales must be an object"
	for lang in loc.keys():
		var err := _check_relative_path(loc[lang])
		if err != "":
			return "locales: " + err
	return ""


## Packs may be downloaded content, so paths must stay inside the pack.
static func _check_relative_path(p) -> String:
	if not (p is String) or p == "":
		return "path must be a non-empty string"
	if p.begins_with("/") or p.begins_with("\\") or p.contains("..") or p.contains(":"):
		return "unsafe path '%s'" % p
	return ""


func _load_locale(lang: String, path: String, pack_id: String) -> void:
	var text = _read_text(path)
	if text == null:
		return
	var data = _parse_json(text, path)
	if not (data is Dictionary):
		if data != null:
			errors.append("%s: locale file must be an object" % path)
		return
	var l := lang.to_lower()
	if not locale_strings.has(l):
		locale_strings[l] = {}
	for k in data.keys():
		if not (k is String) or not (data[k] is String):
			errors.append("%s: locale entry '%s' must map string to string" % [path, str(k)])
			continue
		if locale_strings[l].has(k) and locale_strings[l][k] != data[k]:
			warnings.append("%s: locale key '%s' overridden by pack '%s'" % [path, k, pack_id])
		locale_strings[l][k] = data[k]


## Returns the file text, or null (with an error recorded).
func _read_text(path: String):
	if not FileAccess.file_exists(path):
		errors.append("%s: file not found" % path)
		return null
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		errors.append("%s: cannot open (%d)" % [path, FileAccess.get_open_error()])
		return null
	if f.get_length() > MAX_FILE_BYTES:
		errors.append("%s: file too large (%d bytes, limit %d)" % [path, f.get_length(), MAX_FILE_BYTES])
		return null
	return f.get_as_text()


## Returns parsed JSON, or null (with an error recorded).
func _parse_json(text: String, label: String):
	var json := JSON.new()
	if json.parse(text) != OK:
		errors.append("%s: invalid JSON (line %d: %s)" % [label, json.get_error_line(), json.get_error_message()])
		return null
	if json.data == null:
		errors.append("%s: JSON is null" % label)
		return null
	return json.data
