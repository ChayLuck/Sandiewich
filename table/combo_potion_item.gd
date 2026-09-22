extends "res://table/shelf_item.gd"
class_name ComboPotionItem

func _ready() -> void:
	super._ready()
	price_label.text = "%d" % RunState.COMBO_POTION_PRICE
