extends RefCounted
## String lookup with fallback. Keys are stable ids; all player-facing text is
## data. Missing keys never crash: they render as "[key]" and are recorded.

var language := "en"
var fallback := "en"
var missing := {}          # key -> true, for QA reports
var _strings := {}         # lang -> {key: text}


static func normalize_locale(code: String) -> String:
	var c := code.strip_edges().to_lower().replace("-", "_")
	if c == "":
		return "en"
	return c.split("_")[0]


func add_strings(lang: String, strings: Dictionary) -> void:
	var l := normalize_locale(lang)
	if not _strings.has(l):
		_strings[l] = {}
	for k in strings.keys():
		if k is String and strings[k] is String:
			_strings[l][k] = strings[k]


func load_file(lang: String, path: String) -> bool:
	if not FileAccess.file_exists(path):
		return false
	var text := FileAccess.get_file_as_string(path)
	var json := JSON.new()
	if json.parse(text) != OK or not (json.data is Dictionary):
		return false
	add_strings(lang, json.data)
	return true


func has_language(lang: String) -> bool:
	return _strings.has(normalize_locale(lang))


func set_language(lang: String) -> bool:
	var l := normalize_locale(lang)
	if not _strings.has(l):
		return false
	language = l
	return true


func has_key(key: String) -> bool:
	return _strings.get(language, {}).has(key) or _strings.get(fallback, {}).has(key)


## Translate a key. Placeholders look like {name} and are filled from args.
func t(key: String, args: Dictionary = {}) -> String:
	var text = null
	if _strings.get(language, {}).has(key):
		text = _strings[language][key]
	elif _strings.get(fallback, {}).has(key):
		text = _strings[fallback][key]
	if text == null:
		missing[key] = true
		return "[%s]" % key
	for a in args.keys():
		text = String(text).replace("{%s}" % str(a), str(args[a]))
	return text


## Compare a language against the fallback. Used to report translation gaps.
func coverage(lang: String) -> Dictionary:
	var base: Dictionary = _strings.get(fallback, {})
	var other: Dictionary = _strings.get(normalize_locale(lang), {})
	var gaps: Array = []
	var extra: Array = []
	for k in base.keys():
		if not other.has(k):
			gaps.append(k)
	for k in other.keys():
		if not base.has(k):
			extra.append(k)
	gaps.sort()
	extra.sort()
	return {"missing": gaps, "extra": extra}
