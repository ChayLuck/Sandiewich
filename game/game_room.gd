extends Node2D

const MonsterController = preload("res://monster/monster_controller.gd")
const SandwichBuilder = preload("res://table/sandwich_builder.gd")
const Ingredient = preload("res://table/ingredient.gd")
const ComboPotionItem = preload("res://table/combo_potion_item.gd")
const GambleCoinItem = preload("res://table/gamble_coin_item.gd")

const TEX_MONSTER_UP = preload("res://assets/monster/monster_look_up.png")
const TEX_MONSTER_DOWN = preload("res://assets/monster/monster_look_down.png")
const TEX_MONSTER_LEFT = preload("res://assets/monster/monster_look_left.png")
const TEX_MONSTER_RIGHT = preload("res://assets/monster/monster_look_right.png")
const TEX_MONSTER_DANGER = preload("res://assets/monster/monster_danger.png")

const TEX_SHOTGUN_FIRE_SHEET = preload("res://assets/monster/shotgun_fire_anim.png")
const SHOTGUN_FRAME_SIZE := 120
const SHOTGUN_FRAME_SECONDS := 0.035

const LAYOUT_PATHS := [
	"res://game/layouts/layout_2.tscn",
	"res://game/layouts/layout_3.tscn",
	"res://game/layouts/layout_4.tscn",
]
const LAYOUT_SCORE_STEP := 500
const LAYOUT_MOVE_SECONDS := 0.4

const MAIN_MENU_SCENE_PATH := "res://ui/main_menu.tscn"

const SPEED_HOT_THRESHOLD := 7
const SPEED_NORMAL_COLOR := Color(1, 1, 1, 1)
const SPEED_HOT_COLOR := Color(1.0, 0.35, 0.0, 1)

const COMBO_NORMAL_COLOR := Color(1, 1, 1, 1)
const COMBO_TIER_GREEN := Color(0.2, 0.85, 0.2, 1)
const COMBO_TIER_YELLOW := Color(1.0, 0.85, 0.1, 1)
const COMBO_TIER_RED := Color(1.0, 0.15, 0.15, 1)
const COMBO_RAINBOW_THRESHOLD := 20
const COMBO_RAINBOW_HUE_SPEED := 0.6

const COMBO_BAR_WIDTH := 160.0
const COMBO_BAR_GREEN := Color(0.2, 0.85, 0.2, 1)
const COMBO_BAR_ORANGE := Color(1.0, 0.55, 0.0, 1)
const COMBO_BAR_RED := Color(1.0, 0.15, 0.15, 1)

const SPEED_FLASH_HOLD_SECONDS := 0.6
const SPEED_FLASH_FADE_SECONDS := 0.4

@onready var monster: MonsterController = $MonsterController
@onready var monster_sprite: Sprite2D = $MonsterSprite
@onready var shotgun_sprite: Sprite2D = $ShotgunSprite
@onready var sandwich: SandwichBuilder = $SandwichBuilder
@onready var layers_root: Node2D = $LayersRoot
@onready var ingredient_butter: Ingredient = $IngredientButter
@onready var ingredient_bread: Ingredient = $IngredientBread
@onready var ingredient_jam: Ingredient = $IngredientJam
@onready var ingredient_ice_cream: Ingredient = $IngredientIceCream
@onready var ingredient_chocolate: Ingredient = $IngredientChocolate
@onready var plate_area: Area2D = $PlateArea
@onready var combo_potion_item: ComboPotionItem = $ComboPotionItem
@onready var gamble_coin_item: GambleCoinItem = $GambleCoinItem

@onready var layer_bread_bottom: Sprite2D = $LayersRoot/LayerBreadBottom
@onready var layer_butter: Sprite2D = $LayersRoot/LayerButter
@onready var layer_jam: Sprite2D = $LayersRoot/LayerJam
@onready var layer_ice_cream: Sprite2D = $LayersRoot/LayerIceCream
@onready var layer_chocolate: Sprite2D = $LayersRoot/LayerChocolate
@onready var layer_bread_top: Sprite2D = $LayersRoot/LayerBreadTop

@onready var score_label: Label = $UI/ScoreBoard/ScoreValueLabel
@onready var money_label: Label = $UI/MoneyBoard/MoneyValueLabel
@onready var speed_label: Label = $UI/SpeedBoard/SpeedValueLabel
@onready var combo_board: Control = $UI/ComboBoard
@onready var combo_label: Label = $UI/ComboBoard/ComboValueLabel
@onready var combo_timer_bar_bg: Control = $UI/ComboTimerBarBg
@onready var combo_timer_bar_fill: ColorRect = $UI/ComboTimerBarBg/ComboTimerBarFill
@onready var speed_flash_label: Label = $UI/SpeedFlashLabel
@onready var game_over_panel: Control = $UI/GameOverPanel
@onready var final_score_label: Label = $UI/GameOverPanel/FinalScoreLabel
@onready var high_score_label: Label = $UI/GameOverPanel/HighScoreLabel
@onready var restart_button: Button = $UI/GameOverPanel/RestartButton
@onready var kill_flash: ColorRect = $UI/KillFlash
@onready var suicide_darken: ColorRect = $UI/SuicideDarken
@onready var blood_splatter: CPUParticles2D = $UI/BloodSplatter
@onready var suicide_button: TextureButton = $UI/SuicideButton

@onready var pause_menu: Control = $UI/PauseMenu
@onready var pause_buttons: Control = $UI/PauseMenu/PauseButtons
@onready var pause_resume_button: Button = $UI/PauseMenu/PauseButtons/ResumeButton
@onready var pause_settings_button: Button = $UI/PauseMenu/PauseButtons/SettingsButton
@onready var pause_quit_button: Button = $UI/PauseMenu/PauseButtons/QuitButton
@onready var pause_settings_panel: Control = $UI/PauseMenu/SettingsPanel

@onready var potion_sound: AudioStreamPlayer = $PotionSound
@onready var coin_flip_sound: AudioStreamPlayer = $CoinFlipSound
@onready var bread_sound: AudioStreamPlayer = $BreadSound
@onready var money_sound: AudioStreamPlayer = $MoneySound
@onready var ice_cream_sound: AudioStreamPlayer = $IceCreamSound
@onready var chocolate_sound: AudioStreamPlayer = $ChocolateSound
@onready var shotgun_sound: AudioStreamPlayer = $ShotgunSound
@onready var jam_sound: AudioStreamPlayer = $JamSound
@onready var butter_sound: AudioStreamPlayer = $ButterSound
@onready var eating_sound: AudioStreamPlayer = $EatingSound
@onready var die_sound: AudioStreamPlayer = $DieSound

var _is_dying: bool = false
var _awaiting_suicide_button: bool = false
var _last_money: int = 0
var _shotgun_frames: Array[AtlasTexture] = []

var _layouts: Array = []
var _current_layout_index: int = 0
var _played_layout_indices: Array = [0]
var _next_layout_milestone: int = LAYOUT_SCORE_STEP

var _combo_rainbow_hue: float = 0.0
var _speed_flash_tween: Tween
var _suicide_button_hover_tween: Tween

func _ready() -> void:
	get_viewport().physics_object_picking = true
	_build_shotgun_frames()
	_build_layouts()
	blood_splatter.texture = _build_blood_particle_texture()

	ingredient_butter.clicked.connect(_on_ingredient_clicked)
	ingredient_bread.clicked.connect(_on_ingredient_clicked)
	ingredient_jam.clicked.connect(_on_ingredient_clicked)
	ingredient_ice_cream.clicked.connect(_on_ingredient_clicked)
	ingredient_chocolate.clicked.connect(_on_ingredient_clicked)
	plate_area.input_event.connect(_on_plate_input_event)
	combo_potion_item.clicked.connect(_on_combo_potion_clicked)
	gamble_coin_item.clicked.connect(_on_gamble_coin_clicked)
	restart_button.pressed.connect(_on_restart_pressed)
	suicide_button.pressed.connect(_on_suicide_button_pressed)
	suicide_button.mouse_entered.connect(_on_suicide_button_mouse_entered)
	suicide_button.mouse_exited.connect(_on_suicide_button_mouse_exited)
	pause_resume_button.pressed.connect(_on_pause_resume_pressed)
	pause_settings_button.pressed.connect(_on_pause_settings_pressed)
	pause_quit_button.pressed.connect(_on_pause_quit_pressed)
	pause_settings_panel.closed.connect(_on_pause_settings_closed)

	RunState.score_changed.connect(_on_score_changed)
	RunState.money_changed.connect(_on_money_changed)
	RunState.combo_changed.connect(_on_combo_changed)
	RunState.run_ended.connect(_on_run_ended)
	monster.look_changed.connect(_on_look_changed)
	monster.watch_ended_safely.connect(_on_watch_ended_safely)
	sandwich.layer_added.connect(_on_layer_added)
	sandwich.wrong_order.connect(_on_wrong_order)
	sandwich.sandwich_eaten.connect(_on_sandwich_eaten)
	sandwich.speed_score_changed.connect(_on_speed_score_changed)

	_apply_difficulty_tuning()
	RunState.start_run()
	_on_score_changed(RunState.score)
	_on_money_changed(RunState.money)
	_on_combo_changed(RunState.combo)
	_on_speed_score_changed(SandwichBuilder.SPEED_SCORE_MAX)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if get_tree().paused:
		_resume_game()
	elif RunState.run_active and not _is_dying:
		_pause_game()

func _pause_game() -> void:
	get_tree().paused = true
	pause_menu.visible = true
	pause_buttons.visible = true
	pause_settings_panel.visible = false
	GameSettings.duck()

func _resume_game() -> void:
	get_tree().paused = false
	pause_menu.visible = false
	GameSettings.restore()

func _on_pause_resume_pressed() -> void:
	_resume_game()

func _on_pause_settings_pressed() -> void:
	pause_buttons.visible = false
	pause_settings_panel.visible = true

func _on_pause_settings_closed() -> void:
	pause_settings_panel.visible = false
	pause_buttons.visible = true

func _on_pause_quit_pressed() -> void:
	get_tree().paused = false
	GameSettings.restore()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)

func _process(delta: float) -> void:
	if RunState.combo >= COMBO_RAINBOW_THRESHOLD:
		_combo_rainbow_hue = fmod(_combo_rainbow_hue + delta * COMBO_RAINBOW_HUE_SPEED, 1.0)
		combo_label.add_theme_color_override("font_color", Color.from_hsv(_combo_rainbow_hue, 1.0, 1.0))

	if RunState.combo_potion_active:
		var potion_time_left := RunState.get_combo_potion_time_left()
		var potion_fraction := clampf(potion_time_left / RunState.COMBO_POTION_DURATION_SECONDS, 0.0, 1.0)
		combo_timer_bar_fill.size.x = COMBO_BAR_WIDTH * potion_fraction
		combo_timer_bar_fill.color = Color.from_hsv(_combo_rainbow_hue, 1.0, 1.0)
	else:
		var time_left := RunState.get_combo_time_left()
		var fraction := clampf(time_left / RunState.COMBO_TIMEOUT_SECONDS, 0.0, 1.0)
		combo_timer_bar_fill.size.x = COMBO_BAR_WIDTH * fraction
		if time_left >= 4.0:
			combo_timer_bar_fill.color = COMBO_BAR_GREEN
		elif time_left >= 2.0:
			combo_timer_bar_fill.color = COMBO_BAR_ORANGE
		else:
			combo_timer_bar_fill.color = COMBO_BAR_RED

func _on_ingredient_clicked(type: Ingredient.Type) -> void:
	if not RunState.run_active or _is_dying:
		return
	if monster.is_watching:
		_play_caught_sequence()
		return
	sandwich.on_ingredient_clicked(type)

func _on_plate_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if not RunState.run_active or _is_dying:
		return
	if monster.is_watching:
		_play_caught_sequence()
		return
	sandwich.try_eat()

func _on_combo_potion_clicked() -> void:
	if not RunState.run_active or _is_dying:
		return
	if monster.is_watching:
		_play_caught_sequence()
		return
	if RunState.try_use_combo_potion():
		potion_sound.play()

func _on_gamble_coin_clicked() -> void:
	if not RunState.run_active or _is_dying:
		return
	if monster.is_watching:
		_play_caught_sequence()
		return
	if RunState.try_gamble_coin():
		coin_flip_sound.play()

func _on_layer_added(type: Ingredient.Type, step_index: int) -> void:
	var layer: Sprite2D
	match type:
		Ingredient.Type.BREAD:
			layer = layer_bread_bottom if step_index == 0 else layer_bread_top
			bread_sound.play()
		Ingredient.Type.BUTTER:
			layer = layer_butter
			butter_sound.play()
		Ingredient.Type.JAM:
			layer = layer_jam
			jam_sound.play()
		Ingredient.Type.ICE_CREAM:
			layer = layer_ice_cream
			ice_cream_sound.play()
		Ingredient.Type.CHOCOLATE:
			layer = layer_chocolate
			chocolate_sound.play()
	layer.visible = true

func _on_wrong_order() -> void:
	_is_dying = true
	_awaiting_suicide_button = true
	monster.stop()
	_show_suicide_darken()

func _show_suicide_darken() -> void:
	suicide_darken.visible = true
	suicide_darken.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(suicide_darken, "modulate:a", 1.0, 0.25)

func _on_suicide_button_pressed() -> void:
	if not RunState.run_active:
		return
	if _is_dying and not _awaiting_suicide_button:
		return
	_awaiting_suicide_button = false
	_is_dying = true
	monster.stop()
	_show_suicide_darken()
	blood_splatter.restart()
	blood_splatter.emitting = true
	die_sound.play()
	await get_tree().create_timer(0.5).timeout
	_is_dying = false
	RunState.end_run()

func _on_suicide_button_mouse_entered() -> void:
	_tween_suicide_button_scale(Vector2(1.1, 1.1))

func _on_suicide_button_mouse_exited() -> void:
	_tween_suicide_button_scale(Vector2.ONE)

func _tween_suicide_button_scale(target: Vector2) -> void:
	if _suicide_button_hover_tween:
		_suicide_button_hover_tween.kill()
	_suicide_button_hover_tween = create_tween()
	_suicide_button_hover_tween.tween_property(suicide_button, "scale", target, 0.1)

func _apply_difficulty_tuning() -> void:
	var tuning: Dictionary = GameSettings.get_tuning()
	var look_away_range: Vector2 = tuning["monster_look_away_range"]
	var watch_range: Vector2 = tuning["monster_watch_range"]
	monster.min_look_away_seconds = look_away_range.x
	monster.max_look_away_seconds = look_away_range.y
	monster.min_watch_seconds = watch_range.x
	monster.max_watch_seconds = watch_range.y
	RunState.COMBO_TIMEOUT_SECONDS = tuning["combo_timeout_seconds"]
	sandwich.SPEED_SCORE_TICK_SECONDS = tuning["speed_score_tick_seconds"]

func _build_blood_particle_texture() -> ImageTexture:
	const SIZE := 10
	var image := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	var center := Vector2(SIZE / 2.0, SIZE / 2.0)
	for x in SIZE:
		for y in SIZE:
			if Vector2(x + 0.5, y + 0.5).distance_to(center) <= SIZE / 2.0:
				image.set_pixel(x, y, Color(0.6, 0.0, 0.02, 1))
	return ImageTexture.create_from_image(image)

func _show_speed_flash(speed_score: int) -> void:
	var message: String
	if speed_score >= 10:
		message = "SUPER FLASH!"
	elif speed_score == 9:
		message = "FLASH!"
	elif speed_score == 8:
		message = "Faster!"
	elif speed_score == 7:
		message = "Fast!"
	elif speed_score == 6:
		message = "Good!"
	else:
		message = "SLOW!"

	if _speed_flash_tween:
		_speed_flash_tween.kill()

	speed_flash_label.text = message
	speed_flash_label.visible = true
	speed_flash_label.modulate.a = 1.0
	speed_flash_label.scale = Vector2(1.4, 1.4)

	_speed_flash_tween = create_tween()
	_speed_flash_tween.tween_property(speed_flash_label, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_speed_flash_tween.tween_interval(SPEED_FLASH_HOLD_SECONDS)
	_speed_flash_tween.tween_property(speed_flash_label, "modulate:a", 0.0, SPEED_FLASH_FADE_SECONDS)
	_speed_flash_tween.tween_callback(func(): speed_flash_label.visible = false)

func _on_sandwich_eaten(ingredient_count: int, speed_score: int) -> void:
	RunState.register_sandwich_eaten(ingredient_count, speed_score)
	eating_sound.play()
	_show_speed_flash(speed_score)
	for child in layers_root.get_children():
		child.visible = false

func _on_look_changed(direction: MonsterController.Direction) -> void:
	match direction:
		MonsterController.Direction.UP:
			monster_sprite.texture = TEX_MONSTER_UP
		MonsterController.Direction.DOWN:
			monster_sprite.texture = TEX_MONSTER_DOWN
		MonsterController.Direction.LEFT:
			monster_sprite.texture = TEX_MONSTER_LEFT
		MonsterController.Direction.RIGHT:
			monster_sprite.texture = TEX_MONSTER_RIGHT
		MonsterController.Direction.PLAYER:
			monster_sprite.texture = TEX_MONSTER_DANGER

	if _is_dying:
		return
	if direction == MonsterController.Direction.PLAYER:
		shotgun_sprite.texture = _shotgun_frames[0]
		shotgun_sprite.visible = true
	else:
		shotgun_sprite.visible = false

func _on_watch_ended_safely() -> void:
	RunState.reward_for_staying_still()

func _on_score_changed(new_score: int) -> void:
	score_label.text = "%d" % new_score
	while new_score >= _next_layout_milestone:
		_shuffle_layout()
		_next_layout_milestone += LAYOUT_SCORE_STEP

func _on_money_changed(new_money: int) -> void:
	money_label.text = "%d" % new_money
	if new_money > _last_money:
		money_sound.play()
	_last_money = new_money

func _on_combo_changed(new_combo: int) -> void:
	combo_label.text = "%dx" % new_combo
	if new_combo <= 0:
		combo_label.add_theme_color_override("font_color", COMBO_NORMAL_COLOR)
		combo_board.visible = false
		combo_timer_bar_bg.visible = false
		return
	combo_board.visible = true
	combo_timer_bar_bg.visible = true
	_apply_combo_tier_color(new_combo)
	_shake_label(combo_label)

func _apply_combo_tier_color(combo: int) -> void:
	if combo >= COMBO_RAINBOW_THRESHOLD:
		return
	elif combo >= 15:
		combo_label.add_theme_color_override("font_color", COMBO_TIER_RED)
	elif combo >= 10:
		combo_label.add_theme_color_override("font_color", COMBO_TIER_YELLOW)
	elif combo >= 5:
		combo_label.add_theme_color_override("font_color", COMBO_TIER_GREEN)
	else:
		combo_label.add_theme_color_override("font_color", COMBO_NORMAL_COLOR)

func _shake_label(label: Label) -> void:
	var rest_position := label.position
	var tween := create_tween()
	for _i in 5:
		var offset := Vector2(randf_range(-4.0, 4.0), randf_range(-4.0, 4.0))
		tween.tween_property(label, "position", rest_position + offset, 0.04)
	tween.tween_property(label, "position", rest_position, 0.04)

func _on_speed_score_changed(value: int) -> void:
	speed_label.text = "%d" % value
	if value >= SPEED_HOT_THRESHOLD:
		speed_label.add_theme_color_override("font_color", SPEED_HOT_COLOR)
		var tween := create_tween()
		speed_label.scale = Vector2(1.5, 1.5)
		tween.tween_property(speed_label, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		speed_label.add_theme_color_override("font_color", SPEED_NORMAL_COLOR)

func _build_layouts() -> void:
	_layouts.append(_capture_current_layout())
	for path in LAYOUT_PATHS:
		_layouts.append(_load_layout(path))

func _capture_current_layout() -> Dictionary:
	return {
		"Butter": ingredient_butter.position,
		"Bread": ingredient_bread.position,
		"Jam": ingredient_jam.position,
		"IceCream": ingredient_ice_cream.position,
		"Chocolate": ingredient_chocolate.position,
	}

func _load_layout(path: String) -> Dictionary:
	var layout_scene: PackedScene = load(path)
	var reference := layout_scene.instantiate()
	var layout := {
		"Butter": reference.get_node("ButterSpot").position,
		"Bread": reference.get_node("BreadSpot").position,
		"Jam": reference.get_node("JamSpot").position,
		"IceCream": reference.get_node("IceCreamSpot").position,
		"Chocolate": reference.get_node("ChocolateSpot").position,
	}
	reference.free()
	return layout

func _shuffle_layout() -> void:
	if _layouts.size() <= 1:
		return
	var candidates: Array = []
	for i in _layouts.size():
		if i != _current_layout_index:
			candidates.append(i)
	var unplayed: Array = candidates.filter(func(i): return not _played_layout_indices.has(i))
	var pool: Array = unplayed if not unplayed.is_empty() else candidates
	_current_layout_index = pool[randi() % pool.size()]
	if not _played_layout_indices.has(_current_layout_index):
		_played_layout_indices.append(_current_layout_index)
	_apply_layout(_layouts[_current_layout_index])

func _apply_layout(layout: Dictionary) -> void:
	_move_ingredient(ingredient_butter, layout["Butter"])
	_move_ingredient(ingredient_bread, layout["Bread"])
	_move_ingredient(ingredient_jam, layout["Jam"])
	_move_ingredient(ingredient_ice_cream, layout["IceCream"])
	_move_ingredient(ingredient_chocolate, layout["Chocolate"])

func _move_ingredient(ingredient: Ingredient, target: Vector2) -> void:
	var tween := create_tween()
	tween.tween_property(ingredient, "position", target, LAYOUT_MOVE_SECONDS).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _play_caught_sequence() -> void:
	_is_dying = true
	monster.stop()
	shotgun_sprite.visible = true
	shotgun_sound.play()
	_shake_world()
	_flash_kill_screen()
	await _play_shotgun_animation()
	await get_tree().create_timer(0.15).timeout
	_is_dying = false
	RunState.end_run()

func _build_shotgun_frames() -> void:
	for row in 3:
		for col in 3:
			var frame := AtlasTexture.new()
			frame.atlas = TEX_SHOTGUN_FIRE_SHEET
			frame.region = Rect2(col * SHOTGUN_FRAME_SIZE, row * SHOTGUN_FRAME_SIZE, SHOTGUN_FRAME_SIZE, SHOTGUN_FRAME_SIZE)
			_shotgun_frames.append(frame)

func _play_shotgun_animation() -> void:
	shotgun_sprite.visible = true
	for frame in _shotgun_frames:
		shotgun_sprite.texture = frame
		await get_tree().create_timer(SHOTGUN_FRAME_SECONDS).timeout

func _shake_world() -> void:
	var rest_position := position
	var tween := create_tween()
	for _i in 6:
		var offset := Vector2(randf_range(-8.0, 8.0), randf_range(-8.0, 8.0))
		tween.tween_property(self, "position", rest_position + offset, 0.03)
	tween.tween_property(self, "position", rest_position, 0.03)

func _flash_kill_screen() -> void:
	kill_flash.modulate.a = 1.0
	kill_flash.visible = true
	var tween := create_tween()
	tween.tween_property(kill_flash, "modulate:a", 0.0, 0.4)
	await tween.finished
	kill_flash.visible = false

func _on_run_ended(final_score: int, is_new_high: bool) -> void:
	final_score_label.text = "Score: %d" % final_score
	high_score_label.text = "High Score: %d%s" % [SaveSystem.highest_score, "  (NEW!)" if is_new_high else ""]
	combo_board.visible = false
	combo_timer_bar_bg.visible = false
	suicide_darken.visible = false
	pause_menu.visible = false
	game_over_panel.visible = true

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
