extends Node
class_name MonsterController

signal look_changed(direction: Direction)
signal watch_ended_safely

enum Direction { UP, DOWN, LEFT, RIGHT, PLAYER }

@export var min_look_away_seconds: float = 1.5
@export var max_look_away_seconds: float = 3.5
@export var min_watch_seconds: float = 1.0
@export var max_watch_seconds: float = 2.5

var current_direction: Direction = Direction.UP
var is_watching: bool = false

var _timer: Timer

func _ready() -> void:
	_timer = Timer.new()
	_timer.one_shot = true
	add_child(_timer)
	_timer.timeout.connect(_on_timer_timeout)
	_start_look_away()

func stop() -> void:
	_timer.stop()

func _start_look_away() -> void:
	is_watching = false
	var directions := [Direction.UP, Direction.DOWN, Direction.LEFT, Direction.RIGHT]
	current_direction = directions[randi() % directions.size()]
	look_changed.emit(current_direction)
	_timer.start(randf_range(min_look_away_seconds, max_look_away_seconds))

func _start_watching() -> void:
	is_watching = true
	current_direction = Direction.PLAYER
	look_changed.emit(current_direction)
	_timer.start(randf_range(min_watch_seconds, max_watch_seconds))

func _on_timer_timeout() -> void:
	if is_watching:
		watch_ended_safely.emit()
		_start_look_away()
	else:
		_start_watching()
