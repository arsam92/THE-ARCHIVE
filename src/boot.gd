extends Control
## Boot screen: loads content and shows a status readout. Placeholder for the
## archive terminal UI, which comes in a later milestone.


func _ready() -> void:
	var label := Label.new()
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(label)

	var ok: bool = Game.boot()
	var rt = Game.rt
	label.text = "THE ARCHIVE\n\ncontent: %s\n%d entities, %d errors, %d warnings" % [
		"OK" if ok else "ERRORS",
		rt.db.entities.size(),
		rt.report["errors"].size(),
		rt.report["warnings"].size(),
	]
