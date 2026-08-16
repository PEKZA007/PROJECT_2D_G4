extends Node2D

# หน้าเมนูหลัก: WACHI JELLATO / เกมใหม่ / เล่นต่อ / ตั้งค่า / ออก
# โครงสร้างหน้าจอทั้งหมดอยู่ใน MainMenu.tscn แล้ว สคริปต์นี้แค่ผูกปุ่มกับตรรกะ

@onready var new_game_button: Button = $NewGameButton
@onready var continue_button: Button = $ContinueButton
@onready var settings_button: Button = $SettingsButton
@onready var quit_button: Button = $QuitButton
@onready var bg_music: AudioStreamPlayer = $BGMusic


func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game)
	continue_button.pressed.connect(_on_continue)
	settings_button.pressed.connect(_on_settings)
	quit_button.pressed.connect(_on_quit)

	if bg_music.stream and bg_music.stream is AudioStreamMP3:
		bg_music.stream.loop = true
	if GameState.music_enabled:
		bg_music.play()


func _on_new_game() -> void:
	GameState.start_new_game()
	get_tree().change_scene_to_file("res://LevelSelect.tscn")


func _on_continue() -> void:
	get_tree().change_scene_to_file("res://LevelSelect.tscn")


func _on_settings() -> void:
	get_tree().change_scene_to_file("res://Settings.tscn")


func _on_quit() -> void:
	get_tree().quit()
