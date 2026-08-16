extends Panel
class_name IngredientIcon

# วัตถุดิบชิ้นหนึ่งในถาด ลากไปวางบนถ้วยไอศกรีมได้ (MOUSE DRAG)

var ingredient_key: String = ""
var emoji: String = ""


func setup(key: String, e: String) -> void:
	ingredient_key = key
	emoji = e

	var style := StyleBoxFlat.new()
	style.bg_color = Color8(255, 255, 255, 235)
	style.set_corner_radius_all(200)
	style.set_border_width_all(2)
	style.border_color = Color8(200, 200, 200)
	add_theme_stylebox_override("panel", style)

	var label := Label.new()
	label.text = e
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 30)
	add_child(label)


func _get_drag_data(_at_position: Vector2):
	var preview := Label.new()
	preview.text = emoji
	preview.add_theme_font_size_override("font_size", 38)
	set_drag_preview(preview)
	return {"ingredient": ingredient_key, "emoji": emoji}
