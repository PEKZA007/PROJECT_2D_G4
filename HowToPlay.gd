extends Node2D

# หน้า "วิธีเล่น" — อธิบายขั้นตอนหลักของเกมให้ผู้เล่นใหม่เข้าใจก่อนเริ่มเล่นจริง

@onready var back_button: Button = $BackButton
@onready var start_button: Button = $StartButton


func _ready() -> void:
	get_tree().paused = false
	back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://MainMenu.tscn"))
	start_button.pressed.connect(func(): get_tree().change_scene_to_file("res://LevelSelect.tscn"))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://MainMenu.tscn")
