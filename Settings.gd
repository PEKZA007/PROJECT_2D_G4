extends Node2D

# หน้าตั้งค่า: โครงสร้างหน้าจอทั้งหมดอยู่ใน Settings.tscn แล้ว
# สคริปต์นี้แค่โหลดค่าปัจจุบันมาแสดง และบันทึกค่าที่ผู้เล่นเลือก

@onready var back_button: Button = $BackButton
@onready var sfx_check: CheckButton = $SfxCheck
@onready var music_check: CheckButton = $MusicCheck
@onready var fullscreen_option: OptionButton = $FullscreenOption
@onready var save_button: Button = $SaveButton


func _ready() -> void:
	back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://MainMenu.tscn"))
	save_button.pressed.connect(_on_save)

	sfx_check.button_pressed = GameState.sfx_enabled
	music_check.button_pressed = GameState.music_enabled

	fullscreen_option.clear()
	fullscreen_option.add_item("เต็มจอ")
	fullscreen_option.add_item("หน้าต่าง")
	fullscreen_option.selected = 0 if GameState.fullscreen else 1


func _on_save() -> void:
	var full := fullscreen_option.selected == 0
	GameState.apply_settings(sfx_check.button_pressed, music_check.button_pressed, full)
	get_tree().change_scene_to_file("res://MainMenu.tscn")
