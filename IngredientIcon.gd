extends Panel
class_name IngredientIcon

# ไอเทมหนึ่งชิ้นในถาด (โครงสร้างภาพกำหนดไว้ใน IngredientIcon.tscn แล้ว)
# ใช้ได้ทั้งภาชนะ / รสเจลาโต้ / ท็อปปิ้ง แยกกันด้วย "kind"
# ลากไปวางบนภาชนะเจลาโต้ได้ (MOUSE DRAG) — สคริปต์นี้แค่ตั้งค่าข้อมูล/ภาพ

@onready var label: Label = $Label
@onready var icon_rect: TextureRect = $IconRect

var ingredient_key: String = ""
var emoji: String = ""
var kind: String = "flavor"   # "container" | "flavor" | "topping"
var thumb_texture: Texture2D = null


func setup(key: String, e: String, k: String = "flavor", thumb_path: String = "") -> void:
	ingredient_key = key
	emoji = e
	kind = k
	if thumb_path != "":
		thumb_texture = load(thumb_path)
	if thumb_texture:
		icon_rect.texture = thumb_texture
		icon_rect.visible = true
		label.visible = false
	else:
		icon_rect.visible = false
		label.visible = true
		label.text = e


func _get_drag_data(_at_position: Vector2):
	var preview_control: Control
	if thumb_texture:
		var tex_rect := TextureRect.new()
		tex_rect.texture = thumb_texture
		tex_rect.custom_minimum_size = Vector2(72, 72)
		tex_rect.expand_mode = 1
		tex_rect.stretch_mode = 5
		preview_control = tex_rect
	else:
		var preview_label := Label.new()
		preview_label.text = emoji
		preview_label.add_theme_font_size_override("font_size", 38)
		preview_control = preview_label
	set_drag_preview(preview_control)
	return {"ingredient": ingredient_key, "emoji": emoji, "kind": kind}
