extends Control

signal finished

const PAGES: Array[Dictionary] = [
	{
		"title": "How to Build a Sandwich",
		"body": "The monster across the table looks away (safe) or right at you (danger).\n\n- While it's not looking, click the ingredients in order: Bread, Butter, Jam, then Bread again to close it up.\n\n- Click the wrong ingredient and your run ends — you'll have to hit the reset button to start over.\n\n- If the monster is watching and you click anything at all, it shoots you. Game over.\n\n- Staying still while it watches is safe. When it looks away again, you get paid for the sandwiches you've eaten since your last reward.\n\n- Once your sandwich is closed, click it on the plate to eat it and bank your score.",
	},
	{
		"title": "Score, Speed & Combo",
		"body": "Score = ingredients used x speed score x combo.\n\n- The speed meter starts at 10 and counts down while you build — finish fast for a higher score.\n\n- Combo goes up by 1 every time you eat a sandwich, and resets to 0 if 7 seconds pass without eating another.\n\n- The combo counter glows green at 5x, yellow at 10x, red at 15x, and rainbow at 20x and above.",
	},
	{
		"title": "Shop Items",
		"body": "- Ice Cream and Chocolate: unlock these on the table to add extra steps to your recipe — bigger sandwich, bigger score.\n\n- Combo Potion: instantly boosts your combo and pauses its timer for a while.\n\n- Gamble Coin: a 50/50 coin flip for extra money.\n\n- Every shop item is just as dangerous as an ingredient — clicking any of them while the monster is watching gets you killed too.\n\n- The button in the corner lets you reset your run any time you want, no questions asked.",
	},
	{
		"title": "Tips",
		"body": "- You can change the difficulty (Normal or Beginner) any time from Settings — on the main menu, or from the pause menu (Esc) mid-run.",
	},
]

@onready var title_label: Label = $Box/TitleLabel
@onready var body_label: Label = $Box/BodyLabel
@onready var page_indicator_label: Label = $Box/PageIndicatorLabel
@onready var prev_button: Button = $Box/PrevButton
@onready var next_button: Button = $Box/NextButton
@onready var play_button: Button = $Box/PlayButton

var _page_index: int = 0

func _ready() -> void:
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	play_button.pressed.connect(_on_play_pressed)
	visibility_changed.connect(_on_visibility_changed)
	_show_page(0)

func _on_visibility_changed() -> void:
	if visible:
		_show_page(0)

func _show_page(index: int) -> void:
	_page_index = clampi(index, 0, PAGES.size() - 1)
	var page: Dictionary = PAGES[_page_index]
	title_label.text = page["title"]
	body_label.text = page["body"]
	page_indicator_label.text = "%d / %d" % [_page_index + 1, PAGES.size()]
	prev_button.disabled = _page_index == 0
	next_button.disabled = _page_index == PAGES.size() - 1

func _on_prev_pressed() -> void:
	_show_page(_page_index - 1)

func _on_next_pressed() -> void:
	_show_page(_page_index + 1)

func _on_play_pressed() -> void:
	finished.emit()
