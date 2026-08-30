extends RefCounted
class_name CursorFX

# ------------------------------------------------------------
#  CursorFX - เปลี่ยนเคอร์เซอร์เมาส์ในฉากเล่นเกมให้เป็น "ที่ตักไอศกรีม"
#  ปกติโชว์ที่ตักเปล่า ระหว่างลากรสชาติจะเปลี่ยนเป็นที่ตักที่มีรสนั้นอยู่
#  ใช้ร่วมกันระหว่าง CounterHotspot.gd (จุดกดบนเคาน์เตอร์) และ
#  IngredientIcon.gd (ถาดไอคอนสำรอง) — ทั้งสองจุดเริ่มลากไอเทมได้เหมือนกัน
# ------------------------------------------------------------

const EMPTY := preload("res://assets/icons/cursor/cursor_empty.png")

# จุด hotspot ของภาพเคอร์เซอร์ (ตำแหน่งปลายที่ตักที่ควรตรงกับตำแหน่งเมาส์จริง)
const HOTSPOT := Vector2(13, 29)

const BY_FLAVOR := {
	"choc_mint": preload("res://assets/icons/cursor/cursor_choc_mint.png"),
	"cookies_cream": preload("res://assets/icons/cursor/cursor_cookies_cream.png"),
	"dark_chocolate": preload("res://assets/icons/cursor/cursor_dark_chocolate.png"),
	"lemon": preload("res://assets/icons/cursor/cursor_lemon.png"),
	"pistachio": preload("res://assets/icons/cursor/cursor_pistachio.png"),
	"strawberry_cheesecake": preload("res://assets/icons/cursor/cursor_strawberry_cheesecake.png"),
}


static func set_empty() -> void:
	Input.set_custom_mouse_cursor(EMPTY, Input.CURSOR_ARROW, HOTSPOT)


static func set_flavor(key: String) -> void:
	var tex: Texture2D = BY_FLAVOR.get(key, EMPTY)
	Input.set_custom_mouse_cursor(tex, Input.CURSOR_ARROW, HOTSPOT)


# เรียกตอนออกจากฉากเกม เพื่อคืนเคอร์เซอร์ปกติให้ฉากอื่น
static func clear() -> void:
	Input.set_custom_mouse_cursor(null)
