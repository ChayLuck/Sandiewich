extends "res://table/clickable_area.gd"
class_name Ingredient

enum Type { BREAD, BUTTER, JAM, ICE_CREAM, CHOCOLATE }

signal clicked(type: Type)

@export var type: Type = Type.BREAD

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(type)
