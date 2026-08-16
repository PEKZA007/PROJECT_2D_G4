extends Panel
class_name IngredientIcon

# วัตถุดิบชิ้นหนึ่งในถาด (โครงสร้างภาพกำหนดไว้ใน IngredientIcon.tscn แล้ว)
# ลากไปวางบนถ้วยไอศกรีมได้ (MOUSE DRAG) — สคริปต์นี้แค่ตั้งค่าข้อมูล/ข้อความ

@onready var label: Label = $Label

var ingredient_key: String = ""
var emoji: String = ""


func setup(key: String, e: String) -> void:
	ingredient_key = key
	emoji = e
	label.text = e


func _get_drag_data(_at_position: Vector2):
	var preview := Label.new()
	preview.text = emoji
	preview.add_theme_font_size_override("font_size", 38)
	set_drag_preview(preview)
	return {"ingredient": ingredient_key, "emoji": emoji}
