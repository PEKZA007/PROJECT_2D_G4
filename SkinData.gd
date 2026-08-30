extends RefCounted
class_name SkinData

# ------------------------------------------------------------
#  สกินร้านค้า (ซื้อ/สวมใส่ได้ในแท็บ "สกิน" ของร้านค้า)
#  แต่ละสกินเปลี่ยนภาพ "ที่ตักไอศกรีม" (เคอร์เซอร์ตอนไม่ได้ลากอะไรอยู่)
#  และภาพ "ตู้โชว์ไอศกรีม" (กรอบเคาน์เตอร์กระจก) ในฉาก Game.tscn
#  "classic" คือค่าเริ่มต้นฟรี ใช้ภาพเดิมของเกมทุกประการ (ไม่กระทบผู้เล่นเดิม)
# ------------------------------------------------------------

const SKINS := {
	"classic": {
		"name": "คลาสสิกดั้งเดิม",
		"desc": "ที่ตักและตู้โชว์แบบดั้งเดิมของร้าน",
		"price": 0,
		"counter_texture": "res://assets/gelato/cabinet/counter_with_gelato.png",
		"counter_thumb": "res://assets/gelato/cabinet/skin_classic_counter_thumb.png",
		"cursor_texture": "res://assets/icons/cursor/cursor_empty.png",
	},
	"gold": {
		"name": "ทองหรูริมทะเล",
		"desc": "ที่ตักและตู้โชว์โทนทอง-บรอนซ์ หรูหราสะดุดตา",
		"price": 170,
		"counter_texture": "res://assets/gelato/cabinet/skin_gold_counter.png",
		"counter_thumb": "res://assets/gelato/cabinet/skin_gold_counter_thumb.png",
		"cursor_texture": "res://assets/icons/cursor/skin_gold_cursor.png",
	},
	"mint": {
		"name": "มินต์สดชื่น",
		"desc": "ที่ตักและตู้โชว์โทนมินต์เขียวสดชื่น สะอาดตา",
		"price": 170,
		"counter_texture": "res://assets/gelato/cabinet/skin_mint_counter.png",
		"counter_thumb": "res://assets/gelato/cabinet/skin_mint_counter_thumb.png",
		"cursor_texture": "res://assets/icons/cursor/skin_mint_cursor.png",
	},
}

const SKIN_ORDER := ["classic", "gold", "mint"]


static func get_skin(key: String) -> Dictionary:
	return SKINS.get(key, SKINS["classic"])
