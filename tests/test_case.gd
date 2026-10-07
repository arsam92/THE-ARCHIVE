extends RefCounted
## Minimal test base class. Test files extend this; every method named test_*
## runs on a fresh instance. Failures are collected, not thrown.

const FIXTURE_BASIC := "res://tests/fixtures/pack_basic"
const FIXTURE_BROKEN := "res://tests/fixtures/pack_broken"
const FIXTURE_TRAVERSAL := "res://tests/fixtures/pack_traversal"
const CORE := "res://content/packs/core"

var failures: Array[String] = []
var checks := 0


func assert_true(cond: bool, msg: String = "") -> void:
	checks += 1
	if not cond:
		failures.append("assert_true failed: " + msg)


func assert_false(cond: bool, msg: String = "") -> void:
	checks += 1
	if cond:
		failures.append("assert_false failed: " + msg)


func assert_eq(actual, expected, msg: String = "") -> void:
	checks += 1
	if typeof(actual) != typeof(expected) or actual != expected:
		failures.append("assert_eq failed: %s (got %s, expected %s)" % [msg, str(actual), str(expected)])


func assert_has_substring(list: Array, needle: String, msg: String = "") -> void:
	checks += 1
	for item in list:
		if String(item).contains(needle):
			return
	failures.append("expected an entry containing '%s': %s (entries: %s)" % [needle, msg, str(list)])


## Fresh runtime with core + basic fixture content loaded.
func make_runtime(save_dir: String = "user://test_saves"):
	var Runtime = load("res://src/core/runtime.gd")
	var rt = Runtime.new(save_dir)
	rt.load_content([CORE, FIXTURE_BASIC])
	return rt
