extends Control

# แผงหยุดเกมชั่วคราว — ใช้ซ้ำได้ทุกฉาก (Game, VisualNovel)
# กด ESC (ui_cancel) เพื่อหยุด/เล่นต่อ ทำงานได้แม้ตอน tree paused
# เพราะ node นี้ตั้ง process_mode เป็น ALWAYS ไว้ใน .tscn

@export var quit_scene_path: String = "res://LevelSelect.tscn"
@export var quit_button_text: String = "กลับหน้าเลือกด่าน"

@onready var resume_button: Button = $Card/ResumeButton
@onready var tutorial_button: Button = $Card/TutorialButton
@onready var quit_button: Button = $Card/QuitButton


func _ready() -> void:
	resume_button.pressed.connect(_on_resume)
	tutorial_button.pressed.connect(_on_tutorial)
	quit_button.pressed.connect(_on_quit)
	quit_button.text = quit_button_text
	# ระบบสอนเล่นมีเฉพาะ Day 0-2
	tutorial_button.visible = get_parent().has_method("open_tutorial") and int(get_parent().get("level_id")) >= 0 and int(get_parent().get("level_id")) <= 2
	visible = false
	# กันเหตุการณ์ tree ค้าง paused ข้ามฉากจากรอบก่อนหน้า
	get_tree().paused = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			_on_resume()
		else:
			_pause()
		get_viewport().set_input_as_handled()


func _pause() -> void:
	get_tree().paused = true
	visible = true


func _on_resume() -> void:
	get_tree().paused = false
	visible = false


func _on_tutorial() -> void:
	get_tree().paused = false
	visible = false
	var game := get_parent()
	if game.has_method("open_tutorial"):
		game.open_tutorial()


func _on_quit() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(quit_scene_path)
