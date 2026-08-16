extends Node2D

# หน้าเมนูหลัก: WACHI JELLATO / เกมใหม่ / เล่นต่อ / ตั้งค่า / ออก

const BG_COLOR := Color8(255, 214, 224)
const MENU_MUSIC_PATH := "res://assets/audio/menu_theme.mp3"

var bg_music: AudioStreamPlayer


func _ready() -> void:
	_build_ui()
	_setup_audio()


func _setup_audio() -> void:
	bg_music = AudioStreamPlayer.new()
	var stream := load(MENU_MUSIC_PATH)
	if stream:
		if stream is AudioStreamMP3:
			stream.loop = true
		bg_music.stream = stream
		bg_music.volume_db = -10
		add_child(bg_music)
		if GameState.music_enabled:
			bg_music.play()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = BG_COLOR
	bg.size = Vector2(960, 640)
	add_child(bg)

	var title := UIUtils.make_label("WACHI JELLATO", Vector2(0, 90), 52, Color8(120, 60, 20))
	title.size = Vector2(960, 80)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)

	var subtitle := UIUtils.make_label("🍨 ร้านไอศกรีมของคุณ 🍨", Vector2(0, 165), 22, Color8(150, 90, 40))
	subtitle.size = Vector2(960, 40)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(subtitle)

	var btn_new := UIUtils.make_button("เกมใหม่", Vector2(360, 260), Vector2(240, 55), Color8(255, 183, 197))
	btn_new.pressed.connect(_on_new_game)
	add_child(btn_new)

	var btn_continue := UIUtils.make_button("เล่นต่อ", Vector2(360, 330), Vector2(240, 55), Color8(183, 224, 255))
	btn_continue.pressed.connect(_on_continue)
	add_child(btn_continue)

	var btn_settings := UIUtils.make_button("ตั้งค่า", Vector2(360, 400), Vector2(240, 55), Color8(200, 230, 190))
	btn_settings.pressed.connect(_on_settings)
	add_child(btn_settings)

	var btn_quit := UIUtils.make_button("ออก", Vector2(360, 470), Vector2(240, 55), Color8(230, 230, 230))
	btn_quit.pressed.connect(_on_quit)
	add_child(btn_quit)


func _on_new_game() -> void:
	GameState.start_new_game()
	get_tree().change_scene_to_file("res://LevelSelect.tscn")


func _on_continue() -> void:
	get_tree().change_scene_to_file("res://LevelSelect.tscn")


func _on_settings() -> void:
	get_tree().change_scene_to_file("res://Settings.tscn")


func _on_quit() -> void:
	get_tree().quit()
