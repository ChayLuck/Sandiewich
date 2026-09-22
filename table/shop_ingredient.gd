extends "res://table/ingredient.gd"
class_name ShopIngredient

const LOCKED_MODULATE := Color(0.28, 0.28, 0.28, 0.5)
const UNLOCKED_MODULATE := Color(1, 1, 1, 1)

@export var price: int = 15

@onready var _icon: Sprite2D = $Sprite2D
@onready var _price_label: Label = $PriceLabel

func _ready() -> void:
	super._ready()
	_price_label.text = "%d" % price
	_refresh_lock_visual()
	RunState.run_started.connect(_refresh_lock_visual)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if RunState.is_ingredient_unlocked(type):
		clicked.emit(type)
		return
	if RunState.try_purchase_ingredient(type, price):
		_refresh_lock_visual()

func _refresh_lock_visual() -> void:
	var unlocked := RunState.is_ingredient_unlocked(type)
	_icon.modulate = UNLOCKED_MODULATE if unlocked else LOCKED_MODULATE
	_price_label.visible = not unlocked
