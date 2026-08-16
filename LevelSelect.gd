extends Node2D

# หน้าเลือกด่าน: การ์ดแต่ละด่านแสดงดาว, ล็อก/ปลดล็อกตามลำดับ
# จัดเป็นกริด 4 คอลัมน์ x 2 แถว เพื่อรองรับด่านที่เพิ่มขึ้น


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color8(250, 250, 245)
	bg.size = Vector2(960, 640)
	add_child(bg)

	var back_btn := UIUtils.make_button("←", Vector2(20, 20), Vector2(50, 50), Color8(230, 230, 230), 24)
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://MainMenu.tscn"))
	add_child(back_btn)

	var title := UIUtils.make_label("เลือกด่าน", Vector2(0, 22), 30, Color8(60, 40, 20))
	title.size = Vector2(960, 40)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)

	add_child(UIUtils.make_label("🪙 %d" % GameState.coins, Vector2(800, 26), 20, Color8(180, 120, 0)))

	var shop_btn := UIUtils.make_button("🛒 ร้านค้า", Vector2(400, 72), Vector2(160, 36), Color8(255, 224, 150), 16)
	shop_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://Shop.tscn"))
	add_child(shop_btn)

	var card_w := 205
	var card_h := 190
	var gap_x := 15
	var gap_y := 18
	var start_x := 30
	var start_y := 130

	for i in GameState.levels.size():
		var level: Dictionary = GameState.levels[i]
		var col: int = i % 4
		var row: int = i / 4
		var x: int = start_x + col * (card_w + gap_x)
		var y: int = start_y + row * (card_h + gap_y)
		_build_level_card(Vector2(x, y), Vector2(card_w, card_h), i, level)


func _build_level_card(pos: Vector2, size: Vector2, id: int, level: Dictionary) -> void:
	add_child(UIUtils.make_panel(pos, size, Color8(240, 240, 236), 14))

	var name_label := UIUtils.make_label(level["name"], pos + Vector2(0, 8), 20, Color8(50, 50, 50))
	name_label.size = Vector2(size.x, 26)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(name_label)

	var stars_text := ""
	for s in range(3):
		stars_text += "★" if s < level["stars"] else "☆"
	var stars_label := UIUtils.make_label(stars_text, pos + Vector2(0, 36), 22, Color8(230, 180, 20))
	stars_label.size = Vector2(size.x, 28)
	stars_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(stars_label)

	var info_label := UIUtils.make_label(
		"ลูกค้า %d คน\nเวลา %d วิ  •  วัตถุดิบสูงสุด %d" % [level["target_customers"], int(level["time_limit"]), level["max_order_size"]],
		pos + Vector2(0, 68), 13, Color8(110, 110, 110)
	)
	info_label.size = Vector2(size.x, 55)
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(info_label)

	if level["unlocked"]:
		var play_btn := UIUtils.make_button("เล่น", pos + Vector2(15, 140), Vector2(size.x - 30, 38), Color8(255, 255, 255), 18)
		play_btn.pressed.connect(_on_play_level.bind(id))
		add_child(play_btn)
	else:
		var lock_btn := UIUtils.make_button("ล็อก 🔒", pos + Vector2(15, 140), Vector2(size.x - 30, 38), Color8(220, 220, 220), 16)
		lock_btn.disabled = true
		add_child(lock_btn)


func _on_play_level(id: int) -> void:
	GameState.current_level_id = id
	get_tree().change_scene_to_file("res://Game.tscn")
