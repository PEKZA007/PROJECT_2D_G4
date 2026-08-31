extends Node2D

# หน้าเมนูหลัก: Good Goods Gelato House / เกมใหม่ / เล่นต่อ / ตั้งค่า / ออก
# โครงสร้างหน้าจอทั้งหมดอยู่ใน MainMenu.tscn แล้ว สคริปต์นี้แค่ผูกปุ่มกับตรรกะ

@onready var new_game_button: Button = $NewGameButton
@onready var continue_button: Button = $ContinueButton
@onready var settings_button: Button = $SettingsButton
@onready var quit_button: Button = $QuitButton
@onready var how_to_play_button: Button = $HowToPlayButton
@onready var credits_button: Button = $CreditsButton
@onready var new_game_confirm_dialog: ConfirmationDialog = $NewGameConfirmDialog
@onready var bg_music: AudioStreamPlayer = $BGMusic
@onready var name_dialog: AcceptDialog = $PlayerNameDialog
@onready var name_edit: LineEdit = $PlayerNameDialog/NameEdit


func _ready() -> void:
	get_tree().paused = false
	new_game_button.pressed.connect(_on_new_game)
	continue_button.pressed.connect(_on_continue)
	settings_button.pressed.connect(_on_settings)
	quit_button.pressed.connect(_on_quit)
	how_to_play_button.pressed.connect(_on_how_to_play)
	credits_button.pressed.connect(_on_credits)

	new_game_confirm_dialog.confirmed.connect(_ask_player_name)
	new_game_confirm_dialog.get_label().add_theme_font_size_override("font_size", 24)
	new_game_confirm_dialog.get_cancel_button().text = "ยกเลิก"
	name_dialog.confirmed.connect(_start_new_game_with_name)
	name_edit.text = GameState.player_name

	if bg_music.stream and bg_music.stream is AudioStreamMP3:
		bg_music.stream.loop = true
	if GameState.music_enabled:
		bg_music.play()


func _on_new_game() -> void:
	if GameState.has_progress():
		new_game_confirm_dialog.popup_centered()
	else:
		_ask_player_name()


func _ask_player_name() -> void:
	name_edit.text = GameState.player_name
	name_dialog.popup_centered()
	name_edit.grab_focus()


func _start_new_game_with_name() -> void:
	var entered := name_edit.text.strip_edges()
	if entered.is_empty():
		entered = "แพรวา"
	GameState.start_new_game()
	GameState.player_name = entered
	GameState.save_game()
	get_tree().change_scene_to_file("res://LevelSelect.tscn")


func _on_continue() -> void:
	get_tree().change_scene_to_file("res://LevelSelect.tscn")


func _on_settings() -> void:
	get_tree().change_scene_to_file("res://Settings.tscn")


func _on_how_to_play() -> void:
	get_tree().change_scene_to_file("res://HowToPlay.tscn")


func _on_credits() -> void:
	get_tree().change_scene_to_file("res://Credits.tscn")


func _on_quit() -> void:
	get_tree().quit()
