extends "res://table/shelf_item.gd"
class_name GambleCoinItem

func _ready() -> void:
	super._ready()
	price_label.text = "%d" % RunState.GAMBLE_COIN_PRICE
