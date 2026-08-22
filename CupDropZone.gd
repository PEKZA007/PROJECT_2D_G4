extends Panel
class_name CupDropZone

# พื้นที่วางภาชนะเจลาโต้ - ปล่อยของที่ลากมาตรงนี้ (ภาชนะ / รสเจลาโต้ / ท็อปปิ้ง)

signal ingredient_dropped(key: String, emoji: String, kind: String)


func _can_drop_data(_at_position: Vector2, data) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.has("ingredient")


func _drop_data(_at_position: Vector2, data) -> void:
	ingredient_dropped.emit(data["ingredient"], data["emoji"], data.get("kind", "flavor"))
