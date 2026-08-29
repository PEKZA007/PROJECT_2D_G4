extends Node2D

# หน้าจบวัน: โครงสร้างหน้าจอทั้งหมดอยู่ใน Results.tscn แล้ว
# สคริปต์นี้แค่เติมผลลัพธ์ของรอบล่าสุดจาก GameState.last_run

const STAR_FILLED := preload("res://assets/icons/star_filled.svg")
const STAR_OUTLINE := preload("res://assets/icons/star_outline.svg")

@onready var star_icons: Array = [$StarsRow/Star1, $StarsRow/Star2, $StarsRow/Star3]
@onready var stats_label: Label = $StatsPanel/StatsLabel
@onready var replay_button: Button = $ReplayButton
@onready var home_button: Button = $HomeButton
@onready var next_button: Button = $NextButton


func _ready() -> void:
	get_tree().paused = false
	replay_button.pressed.connect(_on_replay)
	home_button.pressed.connect(_on_home)
	next_button.pressed.connect(_on_next)
	_populate()
	if int(GameState.last_run["stars"]) > 0:
		SFX.play("success")
	else:
		SFX.play("error")


func _populate() -> void:
	var run: Dictionary = GameState.last_run

	for i in range(3):
		star_icons[i].texture = STAR_FILLED if i < int(run["stars"]) else STAR_OUTLINE

	stats_label.text = "ลูกค้าที่พอใจ: %d/%d\nเหรียญที่ได้รับ: +%d\nเวลาเฉลี่ยต่อออเดอร์: %.1f วิ\nคอมโบสูงสุด: x%d" % [
		run["satisfied"], run["target"], run["coins_earned"], run["avg_order_time"], run["max_combo"]
	]

	var next_id: int = int(run["level_id"]) + 1
	var has_next: bool = next_id < GameState.levels.size() and GameState.levels[next_id]["unlocked"]
	var is_last_level: bool = next_id >= GameState.levels.size()
	var show_ending: bool = is_last_level and int(run["stars"]) > 0 and not GameState.has_seen_chapter("ending")

	if show_ending:
		next_button.text = "ดูตอนจบเรื่อง"
		next_button.disabled = false
	else:
		next_button.text = "ด่านถัดไป"
		next_button.disabled = not has_next


func _on_replay() -> void:
	GameState.current_level_id = GameState.last_run["level_id"]
	get_tree().change_scene_to_file("res://Game.tscn")


func _on_home() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")


func _on_next() -> void:
	var run: Dictionary = GameState.last_run
	var next_id: int = int(run["level_id"]) + 1
	var is_last_level: bool = next_id >= GameState.levels.size()

	if is_last_level and int(run["stars"]) > 0 and not GameState.has_seen_chapter("ending"):
		GameState.start_story("ending", "res://MainMenu.tscn")
		get_tree().change_scene_to_file("res://VisualNovel.tscn")
	else:
		GameState.current_level_id = next_id
		get_tree().change_scene_to_file("res://Game.tscn")
