extends Button
class_name CounterHotspot

# จุดกดบนภาพเคาน์เตอร์ (ถังเจลาโต้ / ท็อปปิ้ง / โคน-ถ้วย) — Game.tscn
# แต่เดิมกดครั้งเดียวก็เลือกวัตถุดิบเลย ตอนนี้เปลี่ยนเป็น "ลาก" ไปวางที่ถ้วย/โคน
# บน DropZone แทน (เหมือนกับถาดไอคอนสำรอง) ใช้ metadata "ingredient_key"/"kind"
# ที่ตั้งไว้ในแต่ละโหนดของ Game.tscn


func _get_drag_data(_at_position: Vector2):
	if disabled:
		return null

	var key: String = get_meta("ingredient_key", "")
	var kind: String = get_meta("kind", "")
	if key == "":
		return null

	if kind == "flavor":
		CursorFX.set_flavor(key)

	# preview จริงไม่จำเป็น เพราะเคอร์เซอร์เองเปลี่ยนเป็นที่ตัก/รสชาติให้อยู่แล้ว
	var preview := Control.new()
	preview.custom_minimum_size = Vector2(1, 1)
	set_drag_preview(preview)

	return {"ingredient": key, "emoji": "", "kind": kind}


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		CursorFX.set_empty()
