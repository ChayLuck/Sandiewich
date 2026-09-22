extends Control

const GAME_SCENE_PATH := "res://game/game_room.tscn"

@onready var start_button: Button = $StartButton
@onready var settings_button: Button = $SettingsButton
@onready var quit_button: Button = $QuitButton
@onready var settings_panel: Control = $SettingsPanel
@onready var tutorial_screen: Control = $TutorialScreen

func _ready() -> void:
	settings_panel.visible = false
	tutorial_screen.visible = false
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	settings_panel.closed.connect(_on_settings_closed)
	tutorial_screen.finished.connect(_on_tutorial_finished)

func _on_start_pressed() -> void:
	tutorial_screen.visible = true

func _on_tutorial_finished() -> void:
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_settings_pressed() -> void:
	settings_panel.visible = true

func _on_settings_closed() -> void:
	settings_panel.visible = false

func _on_quit_pressed() -> void:
	get_tree().quit()
