extends Node2D

# หน้า "วิธีเล่น" — อธิบายขั้นตอนหลักของเกมให้ผู้เล่นใหม่เข้าใจก่อนเริ่มเล่นจริง
# มี 2 หน้าย่อยให้สลับดูได้: หน้า 1 การ์ดขั้นตอนเล่น, หน้า 2 ภาพรวม tutorial

const TAB_STYLE_INACTIVE := preload("res://theme/style_tab_button.tres")
const TAB_STYLE_ACTIVE := preload("res://theme/style_tab_button_active.tres")

@onready var back_button: Button = $BackButton
@onready var start_button: Button = $StartButton
@onready var page1: Node2D = $Page1
@onready var page2: Node2D = $Page2
@onready var page1_tab_button: Button = $Tabs/Page1TabButton
@onready var page2_tab_button: Button = $Tabs/Page2TabButton


func _ready() -> void:
	get_tree().paused = false
	back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://MainMenu.tscn"))
	start_button.pressed.connect(func(): get_tree().change_scene_to_file("res://LevelSelect.tscn"))
	page1_tab_button.pressed.connect(func(): _switch_page("page1"))
	page2_tab_button.pressed.connect(func(): _switch_page("page2"))
	_switch_page("page1")


func _switch_page(page: String) -> void:
	page1.visible = (page == "page1")
	page2.visible = (page == "page2")

	var tab_buttons := {"page1": page1_tab_button, "page2": page2_tab_button}
	for key in tab_buttons.keys():
		var btn: Button = tab_buttons[key]
		var active: bool = (key == page)
		var style: StyleBox = TAB_STYLE_ACTIVE if active else TAB_STYLE_INACTIVE
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://MainMenu.tscn")
