extends Node2D

# หน้าจบวัน: โครงสร้างหน้าจอทั้งหมดอยู่ใน Results.tscn แล้ว
# สคริปต์นี้แค่เติมผลลัพธ์ของรอบล่าสุดจาก GameState.last_run

@onready var stars_label: Label = $StarsLabel
@onready var stats_label: Label = $StatsPanel/StatsLabel
@onready var replay_button: Button = $ReplayButton
@onready var home_button: Button = $HomeButton
@onready var next_button: Button = $NextButton


func _ready() -> void:
	replay_button.pressed.connect(_on_replay)
	home_button.pressed.connect(_on_home)
	next_button.pressed.connect(_on_next)
	_populate()


func _populate() -> void:
	var run: Dictionary = GameState.last_run

	var stars_text := ""
	for i in range(3):
		stars_text += "★" if i < int(run["stars"]) else "☆"
	stars_label.text = stars_text

	stats_label.text = "ลูกค้าที่พอใจ: %d/%d\nเหรียญที่ได้รับ: +%d 🪙\nเวลาเฉลี่ยต่อออเดอร์: %.1f วิ\nคอมโบสูงสุด: x%d" % [
		run["satisfied"], run["target"], run["coins_earned"], run["avg_order_time"], run["max_combo"]
	]

	var next_id: int = int(run["level_id"]) + 1
	var has_next: bool = next_id < GameState.levels.size() and GameState.levels[next_id]["unlocked"]
	next_button.disabled = not has_next


func _on_replay() -> void:
	GameState.current_level_id = GameState.last_run["level_id"]
	get_tree().change_scene_to_file("res://Game.tscn")


func _on_home() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")


func _on_next() -> void:
	GameState.current_level_id = GameState.last_run["level_id"] + 1
	get_tree().change_scene_to_file("res://Game.tscn")
