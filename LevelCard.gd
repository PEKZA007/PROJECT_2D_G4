extends Control
class_name LevelCard

# การ์ดด่านหนึ่งใบ (โครงสร้างภาพกำหนดไว้ใน LevelCard.tscn)
# LevelSelect.gd เรียก configure() เพื่อเติมข้อมูลด่านให้การ์ดนี้

signal play_pressed(level_id: int)

@onready var name_label: Label = $NameLabel
@onready var stars_label: Label = $StarsLabel
@onready var info_label: Label = $InfoLabel
@onready var action_button: Button = $ActionButton

var level_id: int = -1


func _ready() -> void:
	action_button.pressed.connect(func(): play_pressed.emit(level_id))


func configure(id: int, level: Dictionary) -> void:
	level_id = id
	name_label.text = level["name"]

	var stars_text := ""
	for s in range(3):
		stars_text += "★" if s < level["stars"] else "☆"
	stars_label.text = stars_text

	info_label.text = "ลูกค้า %d คน\nเวลา %d วิ • วัตถุดิบสูงสุด %d" % [
		level["target_customers"], int(level["time_limit"]), level["max_order_size"]
	]

	if level["unlocked"]:
		action_button.text = "เล่น"
		action_button.disabled = false
	else:
		action_button.text = "ล็อก 🔒"
		action_button.disabled = true
