extends Node

const SAVE_PATH := "user://sandiewich_save.json"

var highest_score: int = 0

func _ready() -> void:
	_load()

func report_score(score: int) -> bool:
	if score > highest_score:
		highest_score = score
		_save()
		return true
	return false

func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY and parsed.has("highest_score"):
		highest_score = int(parsed["highest_score"])

func _save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify({"highest_score": highest_score}))
