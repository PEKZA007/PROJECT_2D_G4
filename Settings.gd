extends Node2D

# หน้าตั้งค่า: เสียง / ภาษา / จอภาพ / ปุ่มควบคุม / บันทึกการตั้งค่า

var sfx_check: CheckButton
var music_check: CheckButton
var fullscreen_option: OptionButton


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

	var title := UIUtils.make_label("ตั้งค่า", Vector2(0, 25), 34, Color8(60, 40, 20))
	title.size = Vector2(960, 50)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)

	# --- เสียง ---
	add_child(UIUtils.make_label("เสียง", Vector2(80, 100), 18, Color8(140, 140, 140)))

	add_child(UIUtils.make_label("เสียงเอฟเฟกต์", Vector2(100, 140), 20, Color8(40, 40, 40)))
	sfx_check = CheckButton.new()
	sfx_check.position = Vector2(320, 133)
	sfx_check.button_pressed = GameState.sfx_enabled
	add_child(sfx_check)

	add_child(UIUtils.make_label("เสียงเพลง", Vector2(100, 190), 20, Color8(40, 40, 40)))
	music_check = CheckButton.new()
	music_check.position = Vector2(320, 183)
	music_check.button_pressed = GameState.music_enabled
	add_child(music_check)

	add_child(UIUtils.make_label("ภาษา", Vector2(560, 140), 20, Color8(40, 40, 40)))
	add_child(UIUtils.make_label("ไทย  (ภาษาอื่นเร็วๆ นี้)", Vector2(650, 140), 16, Color8(120, 120, 120)))

	# --- จอภาพ ---
	add_child(UIUtils.make_label("จอภาพ", Vector2(80, 250), 18, Color8(140, 140, 140)))

	add_child(UIUtils.make_label("ความละเอียด", Vector2(100, 290), 20, Color8(40, 40, 40)))
	add_child(UIUtils.make_label("1920 x 1080", Vector2(320, 290), 20, Color8(90, 90, 90)))

	add_child(UIUtils.make_label("การแสดงผล", Vector2(100, 330), 20, Color8(40, 40, 40)))
	fullscreen_option = OptionButton.new()
	fullscreen_option.position = Vector2(320, 322)
	fullscreen_option.add_item("เต็มจอ")
	fullscreen_option.add_item("หน้าต่าง")
	fullscreen_option.selected = 0 if GameState.fullscreen else 1
	add_child(fullscreen_option)

	# --- ปุ่มควบคุม ---
	add_child(UIUtils.make_label("ปุ่มควบคุม", Vector2(560, 250), 18, Color8(140, 140, 140)))
	add_child(UIUtils.make_label("ลากส่วนผสม", Vector2(560, 292), 18, Color8(40, 40, 40)))
	add_child(_make_key_tag("MOUSE DRAG", Vector2(760, 290)))
	add_child(UIUtils.make_label("จับจังหวะตัก / เสิร์ฟ", Vector2(560, 330), 16, Color8(40, 40, 40)))
	add_child(_make_key_tag("SPACE", Vector2(760, 328)))
	add_child(UIUtils.make_label("หยุดเกมชั่วคราว", Vector2(560, 368), 18, Color8(40, 40, 40)))
	add_child(_make_key_tag("ESC", Vector2(760, 366)))

	var save_btn := UIUtils.make_button("บันทึกการตั้งค่า", Vector2(680, 550), Vector2(240, 55), Color8(50, 50, 50), 20, Color.WHITE)
	save_btn.pressed.connect(_on_save)
	add_child(save_btn)


func _make_key_tag(text: String, pos: Vector2) -> Panel:
	var p := UIUtils.make_panel(pos, Vector2(90, 28), Color8(235, 235, 235), 6)
	var style := p.get_theme_stylebox("panel") as StyleBoxFlat
	style.set_border_width_all(1)
	style.border_color = Color8(180, 180, 180)
	var l := Label.new()
	l.text = text
	l.set_anchors_preset(Control.PRESET_FULL_RECT)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 13)
	p.add_child(l)
	return p


func _on_save() -> void:
	var full := fullscreen_option.selected == 0
	GameState.apply_settings(sfx_check.button_pressed, music_check.button_pressed, full)
	get_tree().change_scene_to_file("res://MainMenu.tscn")
