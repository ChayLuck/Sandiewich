extends Node

const Ingredient = preload("res://table/ingredient.gd")

signal score_changed(new_score: int)
signal money_changed(new_money: int)
signal combo_changed(new_combo: int)
signal run_ended(final_score: int, is_new_high: bool)
signal run_started
signal gamble_result(won: bool)

var score: int = 0
var money: int = 0
var combo: int = 0
var sandwiches_since_reward: int = 0
var run_active: bool = false

var unlocked_ice_cream: bool = false
var unlocked_chocolate: bool = false

var COMBO_TIMEOUT_SECONDS: float = 7.0

const COMBO_POTION_BOOST_TARGET := 20
const COMBO_POTION_PRICE := 25
const COMBO_POTION_DURATION_SECONDS := 20.0

var combo_potion_active: bool = false

var _combo_timer: Timer
var _combo_potion_timer: Timer

func _ready() -> void:
	_combo_timer = Timer.new()
	_combo_timer.one_shot = true
	_combo_timer.wait_time = COMBO_TIMEOUT_SECONDS
	add_child(_combo_timer)
	_combo_timer.timeout.connect(_on_combo_timeout)

	_combo_potion_timer = Timer.new()
	_combo_potion_timer.one_shot = true
	_combo_potion_timer.wait_time = COMBO_POTION_DURATION_SECONDS
	add_child(_combo_potion_timer)
	_combo_potion_timer.timeout.connect(_on_combo_potion_timeout)

func start_run() -> void:
	score = 0
	money = 0
	combo = 0
	sandwiches_since_reward = 0
	unlocked_ice_cream = false
	unlocked_chocolate = false
	combo_potion_active = false
	run_active = true
	_combo_timer.stop()
	_combo_timer.wait_time = COMBO_TIMEOUT_SECONDS
	_combo_potion_timer.stop()
	score_changed.emit(score)
	money_changed.emit(money)
	combo_changed.emit(combo)
	run_started.emit()

func _on_combo_timeout() -> void:
	if combo != 0:
		combo = 0
		combo_changed.emit(combo)

func _on_combo_potion_timeout() -> void:
	combo_potion_active = false
	_combo_timer.start()

func try_use_combo_potion() -> bool:
	if money < COMBO_POTION_PRICE:
		return false
	money -= COMBO_POTION_PRICE
	money_changed.emit(money)
	if combo < COMBO_POTION_BOOST_TARGET:
		combo = COMBO_POTION_BOOST_TARGET
		combo_changed.emit(combo)
	combo_potion_active = true
	_combo_timer.stop()
	_combo_potion_timer.start()
	return true

func get_combo_time_left() -> float:
	if _combo_timer.is_stopped():
		return 0.0
	return _combo_timer.time_left

func get_combo_potion_time_left() -> float:
	if _combo_potion_timer.is_stopped():
		return 0.0
	return _combo_potion_timer.time_left

const GAMBLE_COIN_PRICE := 5
const GAMBLE_COIN_PAYOUT := 10
const GAMBLE_COIN_WIN_CHANCE := 0.5

func try_gamble_coin() -> bool:
	if money < GAMBLE_COIN_PRICE:
		return false
	money -= GAMBLE_COIN_PRICE
	var won := randf() < GAMBLE_COIN_WIN_CHANCE
	if won:
		money += GAMBLE_COIN_PAYOUT
	money_changed.emit(money)
	gamble_result.emit(won)
	return true

func is_ingredient_unlocked(type: Ingredient.Type) -> bool:
	match type:
		Ingredient.Type.ICE_CREAM:
			return unlocked_ice_cream
		Ingredient.Type.CHOCOLATE:
			return unlocked_chocolate
		_:
			return true

func try_purchase_ingredient(type: Ingredient.Type, price: int) -> bool:
	if is_ingredient_unlocked(type) or money < price:
		return false
	money -= price
	match type:
		Ingredient.Type.ICE_CREAM:
			unlocked_ice_cream = true
		Ingredient.Type.CHOCOLATE:
			unlocked_chocolate = true
	money_changed.emit(money)
	return true

func register_sandwich_eaten(ingredient_count: int, speed_score: int) -> void:
	if not run_active:
		return
	combo += 1
	sandwiches_since_reward += 1
	score += ingredient_count * speed_score * combo
	score_changed.emit(score)
	combo_changed.emit(combo)
	if not combo_potion_active:
		_combo_timer.start()

func reward_for_staying_still() -> void:
	if not run_active or sandwiches_since_reward <= 0:
		return
	money += sandwiches_since_reward
	sandwiches_since_reward = 0
	money_changed.emit(money)

func end_run() -> void:
	if not run_active:
		return
	run_active = false
	var is_new_high := SaveSystem.report_score(score)
	run_ended.emit(score, is_new_high)
