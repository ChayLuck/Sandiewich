extends Area2D
class_name ClickableArea2D

const HOVER_SCALE_MULTIPLIER := 1.1
const HOVER_TWEEN_SECONDS := 0.1

@export var click_size: Vector2 = Vector2(80, 80)

var _rest_scale: Vector2
var _hover_tween: Tween

func _ready() -> void:
	input_pickable = true
	if get_child_count() == 0 or not (get_child(0) is CollisionShape2D):
		var shape := RectangleShape2D.new()
		shape.size = click_size
		var collision := CollisionShape2D.new()
		collision.shape = shape
		add_child(collision)
	input_event.connect(_on_input_event)
	_rest_scale = scale
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	pass

func _on_mouse_entered() -> void:
	_tween_hover_scale(_rest_scale * HOVER_SCALE_MULTIPLIER)

func _on_mouse_exited() -> void:
	_tween_hover_scale(_rest_scale)

func _tween_hover_scale(target: Vector2) -> void:
	if _hover_tween:
		_hover_tween.kill()
	_hover_tween = create_tween()
	_hover_tween.tween_property(self, "scale", target, HOVER_TWEEN_SECONDS)
