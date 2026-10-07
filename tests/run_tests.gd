extends SceneTree
## Test runner.  godot --headless --path . -s tests/run_tests.gd
## Exit code 0 = all passed. Optional filter: -- test_save_system

func _init() -> void:
	var only := ""
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		only = args[0]

	var dir := DirAccess.open("res://tests")
	var files: Array = []
	for f in dir.get_files():
		if f.begins_with("test_") and f.ends_with(".gd") and f != "test_case.gd":
			if only == "" or f.contains(only):
				files.append(f)
	files.sort()

	var total_tests := 0
	var total_checks := 0
	var failed_tests := 0
	for f in files:
		var script = load("res://tests/" + String(f))
		if script == null:
			print("FAIL  %s: could not load script" % f)
			failed_tests += 1
			continue
		var names: Array = []
		for m in script.get_script_method_list():
			if String(m["name"]).begins_with("test_"):
				names.append(String(m["name"]))
		names.sort()
		for n in names:
			var inst = script.new()
			inst.call(n)
			total_tests += 1
			total_checks += inst.checks
			if inst.failures.is_empty():
				print("PASS  %s::%s" % [f, n])
			else:
				failed_tests += 1
				print("FAIL  %s::%s" % [f, n])
				for msg in inst.failures:
					print("        ", msg)

	print("")
	print("%d tests, %d checks, %d failed" % [total_tests, total_checks, failed_tests])
	quit(1 if failed_tests > 0 else 0)
