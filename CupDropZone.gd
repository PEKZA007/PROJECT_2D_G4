extends Panel
class_name CupDropZone

# พื้นที่ถ้วยไอศกรีม - ปล่อยวัตถุดิบที่ลากมาตรงนี้

signal ingredient_dropped(key: String, emoji: String)


func _can_drop_data(_at_position: Vector2, data) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.has("ingredient")


func _drop_data(_at_position: Vector2, data) -> void:
	ingredient_dropped.emit(data["ingredient"], data["emoji"])
