extends Control
class_name SettingsPanel

signal closed

@onready var music_slider: HSlider = $Box/MusicSlider
@onready var sound_slider: HSlider = $Box/SoundSlider
@onready var scale_option: OptionButton = $Box/ScaleOption
@onready var difficulty_option: OptionButton = $Box/DifficultyOption
@onready var back_button: Button = $Box/BackButton

const DIFFICULTY_LABELS := ["Normal", "Beginner"]

func _ready() -> void:
	music_slider.min_value = 0
	music_slider.max_value = 100
	music_slider.value = GameSettings.music_volume * 100.0

	sound_slider.min_value = 0
	sound_slider.max_value = 100
	sound_slider.value = GameSettings.sound_volume * 100.0

	scale_option.clear()
	for scale in GameSettings.DISPLAY_SCALE_OPTIONS:
		scale_option.add_item("%dx" % scale)
	var current_scale_index: int = GameSettings.DISPLAY_SCALE_OPTIONS.find(GameSettings.display_scale)
	scale_option.select(maxi(current_scale_index, 0))

	difficulty_option.clear()
	for label in DIFFICULTY_LABELS:
		difficulty_option.add_item(label)
	difficulty_option.select(GameSettings.difficulty)

	music_slider.value_changed.connect(_on_music_slider_changed)
	sound_slider.value_changed.connect(_on_sound_slider_changed)
	scale_option.item_selected.connect(_on_scale_selected)
	difficulty_option.item_selected.connect(_on_difficulty_selected)
	back_button.pressed.connect(func(): closed.emit())

func _on_music_slider_changed(value: float) -> void:
	GameSettings.set_music_volume(value / 100.0)

func _on_sound_slider_changed(value: float) -> void:
	GameSettings.set_sound_volume(value / 100.0)

func _on_scale_selected(index: int) -> void:
	GameSettings.set_display_scale(GameSettings.DISPLAY_SCALE_OPTIONS[index])

func _on_difficulty_selected(index: int) -> void:
	GameSettings.set_difficulty(index as GameSettings.Difficulty)
