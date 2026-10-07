extends RefCounted
## Composition root: wires every core system together. Engine-node free, so
## the whole game logic can be driven from tests and tools without a scene.

const ContentDB = preload("res://src/core/content_db.gd")
const StoryGraph = preload("res://src/core/story_graph.gd")
const MessageSystem = preload("res://src/core/message_system.gd")
const Effects = preload("res://src/core/effects.gd")
const PuzzleSystem = preload("res://src/core/puzzle_system.gd")
const EndingResolver = preload("res://src/core/ending_resolver.gd")
const DialogueRunner = preload("res://src/core/dialogue_runner.gd")
const SaveSystem = preload("res://src/core/save_system.gd")
const Localization = preload("res://src/core/localization.gd")
const GameState = preload("res://src/core/game_state.gd")
const Validator = preload("res://src/core/content_validator.gd")

const CORE_PACK := "res://content/packs/core"
const DOWNLOADED_PACKS_DIR := "user://packs"

var db
var graph
var messages
var effects
var puzzles
var endings
var saves
var loc
var state
var report := {"errors": [], "warnings": []}


func _init(save_dir: String = "user://saves") -> void:
	db = ContentDB.new()
	graph = StoryGraph.new()
	messages = MessageSystem.new(db)
	effects = Effects.new(db, messages)
	puzzles = PuzzleSystem.new(db, effects)
	endings = EndingResolver.new(db)
	saves = SaveSystem.new(save_dir)
	loc = Localization.new()
	state = GameState.new()


## Loads packs in order (dependencies first), then builds the graph and
## validates. Returns true when no errors were found.
func load_content(pack_dirs: Array = [CORE_PACK]) -> bool:
	for d in pack_dirs:
		db.load_pack_dir(String(d))
	for lang in db.locale_strings.keys():
		loc.add_strings(lang, db.locale_strings[lang])
	graph.build(db)
	var v: Dictionary = Validator.validate(db, loc, effects)
	report = {
		"errors": db.errors + v["errors"],
		"warnings": db.warnings + v["warnings"],
	}
	return report["errors"].is_empty()


func new_game() -> void:
	state = GameState.new()


func new_dialogue():
	return DialogueRunner.new(db, effects)


func autosave() -> bool:
	return saves.save(SaveSystem.AUTOSAVE_SLOT, state)


func load_autosave() -> bool:
	var r: Dictionary = saves.load_slot(SaveSystem.AUTOSAVE_SLOT)
	if r["ok"]:
		state = r["state"]
	return r["ok"]
