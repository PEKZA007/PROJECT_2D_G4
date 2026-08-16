extends Node2D

# หน้าจบวัน: แสดงดาว + สถิติ + เล่นซ้ำ / กลับหน้าแรก / ด่านถัดไป


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	var run: Dictionary = GameState.last_run

	var bg := ColorRect.new()
	bg.color = Color8(250, 250, 245)
	bg.size = Vector2(960, 640)
	add_child(bg)

	var title := UIUtils.make_label("จบวัน! ผลลัพธ์", Vector2(0, 60), 38, Color8(60, 40, 20))
	title.size = Vector2(960, 60)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)

	var stars_text := ""
	for i in range(3):
		stars_text += "★" if i < int(run["stars"]) else "☆"
	var stars_label := UIUtils.make_label(stars_text, Vector2(0, 140), 60, Color8(230, 180, 20))
	stars_label.size = Vector2(960, 80)
	stars_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(stars_label)

	add_child(UIUtils.make_panel(Vector2(280, 250), Vector2(400, 190), Color8(240, 240, 236), 16))

	var stats_text := "ลูกค้าที่พอใจ: %d/%d\nเหรียญที่ได้รับ: +%d 🪙\nเวลาเฉลี่ยต่อออเดอร์: %.1f วิ\nคอมโบสูงสุด: x%d" % [
		run["satisfied"], run["target"], run["coins_earned"], run["avg_order_time"], run["max_combo"]
	]
	var stats_label := UIUtils.make_label(stats_text, Vector2(310, 275), 18, Color8(40, 40, 40))
	stats_label.size = Vector2(340, 150)
	add_child(stats_label)

	var replay_btn := UIUtils.make_button("เล่นซ้ำ", Vector2(80, 500), Vector2(220, 55), Color8(255, 255, 255), 18)
	replay_btn.pressed.connect(_on_replay)
	add_child(replay_btn)

	var home_btn := UIUtils.make_button("กลับหน้าแรก", Vector2(370, 500), Vector2(220, 55), Color8(255, 255, 255), 18)
	home_btn.pressed.connect(_on_home)
	add_child(home_btn)

	var next_id: int = int(run["level_id"]) + 1
	var has_next: bool = next_id < GameState.levels.size() and GameState.levels[next_id]["unlocked"]
	var next_color := Color8(40, 40, 40) if has_next else Color8(220, 220, 220)
	var next_font_color := Color.WHITE if has_next else Color8(150, 150, 150)
	var next_btn := UIUtils.make_button("ด่านถัดไป", Vector2(660, 500), Vector2(220, 55), next_color, 18, next_font_color)
	next_btn.disabled = not has_next
	if has_next:
		next_btn.pressed.connect(_on_next)
	add_child(next_btn)


func _on_replay() -> void:
	GameState.current_level_id = GameState.last_run["level_id"]
	get_tree().change_scene_to_file("res://Game.tscn")


func _on_home() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")


func _on_next() -> void:
	GameState.current_level_id = GameState.last_run["level_id"] + 1
	get_tree().change_scene_to_file("res://Game.tscn")
