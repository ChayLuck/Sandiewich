extends Node

const SAVE_PATH := "user://sandiewich_settings.json"
const MUSIC_STREAM_PATH := "res://assets/music/sandiewich_track1.mp3"

const DUCK_FACTOR := 0.1

const WINDOW_BASE_SIZE := Vector2i(960, 540)
const DISPLAY_SCALE_OPTIONS: Array[int] = [1, 2, 3]

enum Difficulty { NORMAL, BEGINNER }

const TUNING := {
	Difficulty.NORMAL: {
		"monster_look_away_range": Vector2(1.5, 3.5),
		"monster_watch_range": Vector2(1.0, 2.5),
		"combo_timeout_seconds": 7.0,
		"speed_score_tick_seconds": 0.5,
	},
	Difficulty.BEGINNER: {
		"monster_look_away_range": Vector2(3.0, 5.0),
		"monster_watch_range": Vector2(0.6, 1.2),
		"combo_timeout_seconds": 12.0,
		"speed_score_tick_seconds": 0.8,
	},
}

signal music_volume_changed(value: float)
signal sound_volume_changed(value: float)
signal display_scale_changed(value: int)
signal difficulty_changed(value: Difficulty)

var music_volume: float = 1.0
var sound_volume: float = 1.0
var display_scale: int = 1
var difficulty: Difficulty = Difficulty.NORMAL

var is_ducked: bool = false

var _music_bus_idx: int
var _sfx_bus_idx: int
var _music_player: AudioStreamPlayer

func _ready() -> void:
	_music_bus_idx = AudioServer.get_bus_index("Music")
	_sfx_bus_idx = AudioServer.get_bus_index("SFX")
	_load()
	_apply_volumes()
	_apply_display_scale()
	_start_music()

func _start_music() -> void:
	var stream: AudioStream = load(MUSIC_STREAM_PATH)
	if stream is AudioStreamMP3:
		stream.loop = true
	_music_player = AudioStreamPlayer.new()
	_music_player.stream = stream
	_music_player.bus = "Music"
	add_child(_music_player)
	_music_player.play()

func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	_apply_volumes()
	_save()
	music_volume_changed.emit(music_volume)

func set_sound_volume(value: float) -> void:
	sound_volume = clampf(value, 0.0, 1.0)
	_apply_volumes()
	_save()
	sound_volume_changed.emit(sound_volume)

func set_display_scale(scale: int) -> void:
	display_scale = scale
	_apply_display_scale()
	_save()
	display_scale_changed.emit(display_scale)

func set_difficulty(value: Difficulty) -> void:
	difficulty = value
	_save()
	difficulty_changed.emit(difficulty)

func get_tuning() -> Dictionary:
	return TUNING[difficulty]

func duck() -> void:
	is_ducked = true
	_apply_volumes()

func restore() -> void:
	is_ducked = false
	_apply_volumes()

func _apply_volumes() -> void:
	var factor := DUCK_FACTOR if is_ducked else 1.0
	AudioServer.set_bus_volume_db(_music_bus_idx, linear_to_db(music_volume * factor))
	AudioServer.set_bus_volume_db(_sfx_bus_idx, linear_to_db(sound_volume * factor))

func _apply_display_scale() -> void:
	get_window().size = WINDOW_BASE_SIZE * display_scale

func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	if parsed.has("music_volume"):
		music_volume = float(parsed["music_volume"])
	if parsed.has("sound_volume"):
		sound_volume = float(parsed["sound_volume"])
	if parsed.has("display_scale"):
		display_scale = int(parsed["display_scale"])
	if parsed.has("difficulty"):
		difficulty = int(parsed["difficulty"]) as Difficulty

func _save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify({
		"music_volume": music_volume,
		"sound_volume": sound_volume,
		"display_scale": display_scale,
		"difficulty": difficulty,
	}))
