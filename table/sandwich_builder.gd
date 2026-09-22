extends Node
class_name SandwichBuilder

const Ingredient = preload("res://table/ingredient.gd")

signal layer_added(type: Ingredient.Type, step_index: int)
signal sandwich_ready(speed_score: int)
signal wrong_order
signal sandwich_eaten(ingredient_count: int, speed_score: int)
signal speed_score_changed(value: int)

const SPEED_SCORE_MAX := 10
const SPEED_SCORE_MIN := 0
var SPEED_SCORE_TICK_SECONDS := 0.5

var _current_recipe: Array = []
var _step: int = 0
var _start_time_seconds: float = 0.0
var _ready_to_eat: bool = false
var _building: bool = false
var _locked_speed_score: int = SPEED_SCORE_MAX
var _last_emitted_speed_score: int = SPEED_SCORE_MAX

func _process(_delta: float) -> void:
	if not _building:
		return
	var current := _compute_speed_score()
	if current != _last_emitted_speed_score:
		_last_emitted_speed_score = current
		speed_score_changed.emit(current)

func on_ingredient_clicked(type: Ingredient.Type) -> void:
	if _ready_to_eat:
		return
	if _step == 0:
		_start_time_seconds = Time.get_ticks_msec() / 1000.0
		_current_recipe = _build_recipe()
		_building = true
		_last_emitted_speed_score = SPEED_SCORE_MAX
		speed_score_changed.emit(SPEED_SCORE_MAX)
	if type != _current_recipe[_step]:
		_building = false
		wrong_order.emit()
		return
	layer_added.emit(type, _step)
	_step += 1
	if _step >= _current_recipe.size():
		_ready_to_eat = true
		_locked_speed_score = _compute_speed_score()
		_building = false
		sandwich_ready.emit(_locked_speed_score)

func try_eat() -> void:
	if not _ready_to_eat:
		return
	sandwich_eaten.emit(_current_recipe.size(), _locked_speed_score)
	_step = 0
	_ready_to_eat = false

func reset() -> void:
	_step = 0
	_ready_to_eat = false
	_building = false

func _compute_speed_score() -> int:
	var elapsed := Time.get_ticks_msec() / 1000.0 - _start_time_seconds
	var ticks_lost := int(elapsed / SPEED_SCORE_TICK_SECONDS)
	return clampi(SPEED_SCORE_MAX - ticks_lost, SPEED_SCORE_MIN, SPEED_SCORE_MAX)

func _build_recipe() -> Array:
	var recipe: Array = [Ingredient.Type.BREAD, Ingredient.Type.BUTTER, Ingredient.Type.JAM]
	if RunState.unlocked_ice_cream:
		recipe.append(Ingredient.Type.ICE_CREAM)
	if RunState.unlocked_chocolate:
		recipe.append(Ingredient.Type.CHOCOLATE)
	recipe.append(Ingredient.Type.BREAD)
	return recipe
