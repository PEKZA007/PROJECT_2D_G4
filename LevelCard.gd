extends Control
class_name LevelCard

# การ์ดด่านหนึ่งใบ (โครงสร้างภาพกำหนดไว้ใน LevelCard.tscn)
# LevelSelect.gd เรียก configure() เพื่อเติมข้อมูลด่านให้การ์ดนี้

signal play_pressed(level_id: int)

const STAR_FILLED := preload("res://assets/icons/star_filled.svg")
const STAR_OUTLINE := preload("res://assets/icons/star_outline.svg")

@onready var name_label: Label = $NameLabel
@onready var star_icons: Array = [$StarsRow/Star1, $StarsRow/Star2, $StarsRow/Star3]
@onready var info_label: Label = $InfoLabel
@onready var action_button: Button = $ActionButton

var level_id: int = -1


func _ready() -> void:
	action_button.pressed.connect(func(): play_pressed.emit(level_id))


func configure(id: int, level: Dictionary) -> void:
	level_id = id
	name_label.text = level["name"]

	for s in range(3):
		star_icons[s].texture = STAR_FILLED if s < level["stars"] else STAR_OUTLINE

	info_label.text = "ลูกค้า %d คน\nวัตถุดิบสูงสุด %d" % [
		level["target_customers"], level["max_order_size"]
	]

	if level["unlocked"]:
		action_button.text = "เล่น"
		action_button.disabled = false
	else:
		action_button.text = "ล็อก"
		action_button.disabled = true
