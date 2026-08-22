extends Node2D

# หน้า "เครดิต" — รายชื่อผู้จัดทำและเครื่องมือที่ใช้สร้างเกม

@onready var back_button: Button = $BackButton


func _ready() -> void:
	get_tree().paused = false
	back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://MainMenu.tscn"))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://MainMenu.tscn")
