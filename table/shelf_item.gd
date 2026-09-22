extends "res://table/clickable_area.gd"
class_name ShelfItem

signal clicked

@onready var price_label: Label = $PriceLabel

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit()
