extends Node2D

# หน้าเลือกด่าน: การ์ดทั้ง 8 ใบเป็น instance ของ LevelCard.tscn ที่วางไว้ใน
# LevelSelect.tscn อยู่แล้ว สคริปต์นี้แค่เติมข้อมูลด่านแต่ละใบและรับสัญญาณ

@onready var back_button: Button = $BackButton
@onready var shop_button: Button = $ShopButton
@onready var coin_label: Label = $CoinLabel
@onready var cards: Array = [
	$LevelCard1, $LevelCard2, $LevelCard3, $LevelCard4,
	$LevelCard5, $LevelCard6, $LevelCard7, $LevelCard8,
]


func _ready() -> void:
	get_tree().paused = false
	back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://MainMenu.tscn"))
	shop_button.pressed.connect(func(): get_tree().change_scene_to_file("res://Shop.tscn"))
	coin_label.text = "🪙 %d" % GameState.coins

	for i in cards.size():
		if i < GameState.levels.size():
			cards[i].configure(i, GameState.levels[i])
			cards[i].play_pressed.connect(_on_play_level)


func _on_play_level(id: int) -> void:
	GameState.current_level_id = id
	var chapter: String = StoryData.LEVEL_INTRO_CHAPTERS.get(id, "")
	if chapter != "" and not GameState.has_seen_chapter(chapter):
		GameState.start_story(chapter, "res://Game.tscn")
		get_tree().change_scene_to_file("res://VisualNovel.tscn")
	else:
		get_tree().change_scene_to_file("res://Game.tscn")
