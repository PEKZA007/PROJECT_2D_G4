extends Node

# ------------------------------------------------------------
#  GameState - Autoload (Project Settings > Autoload)
#  เก็บสถานะที่ต้องใช้ร่วมกันข้ามฉาก: เหรียญ, ความคืบหน้าด่าน,
#  การตั้งค่า, อัปเกรด/รสชาติที่ปลดล็อกแล้ว, และผลลัพธ์ของรอบล่าสุด
#  บันทึกลงดิสก์อัตโนมัติทุกครั้งที่มีการเปลี่ยนแปลงสำคัญ
# ------------------------------------------------------------

signal settings_changed

const SAVE_PATH := "user://savegame.json"

# --- Currency & upgrades (ของจริงที่มีผลต่อเกมเพลย์ ดูใน Game.gd) ---
var coins := 0
var upgrade_fast_scoop := false      # "ตักเจลาโต้ไว" -> ลดเวลาคูลดาวน์การตัก
var upgrade_expand_counter := false  # "ขยายตู้" -> ถ้วยใส่วัตถุดิบได้เพิ่ม 1 ชิ้น
var upgrade_auto_churn := false      # "ปั่นออโต้" -> มินิเกมตักเจลาโต้ง่ายขึ้น

# --- Decor: ธีมตกแต่งร้าน ซื้อ/สวมใส่ได้ในร้านค้า ("classic" ฟรีตั้งแต่แรก) ---
var owned_decor := {
	"classic": true,
	"pastel": false,
	"tropical": false,
	"midnight": false,
}
var equipped_decor := "classic"

# --- Levels ---
# stars: 0-3, unlocked: bool, max_order_size: จำนวนรสเจลาโต้สูงสุดต่อออเดอร์
# (ไม่มีระบบจำกัดเวลาต่อด่านแล้ว — เล่นจนกว่าจะเสิร์ฟครบ target_customers)
var levels := [
	{"name": "ด่าน 1", "target_customers": 6, "max_order_size": 1, "stars": 0, "unlocked": true},
	{"name": "ด่าน 2", "target_customers": 8, "max_order_size": 1, "stars": 0, "unlocked": false},
	{"name": "ด่าน 3", "target_customers": 10, "max_order_size": 2, "stars": 0, "unlocked": false},
	{"name": "ด่าน 4", "target_customers": 12, "max_order_size": 2, "stars": 0, "unlocked": false},
	{"name": "ด่าน 5", "target_customers": 14, "max_order_size": 2, "stars": 0, "unlocked": false},
	{"name": "ด่าน 6", "target_customers": 16, "max_order_size": 2, "stars": 0, "unlocked": false},
	{"name": "ด่าน 7", "target_customers": 18, "max_order_size": 2, "stars": 0, "unlocked": false},
	{"name": "ด่าน 8", "target_customers": 20, "max_order_size": 2, "stars": 0, "unlocked": false},
]

var current_level_id := 0

# --- Settings ---
var sfx_enabled := true
var music_enabled := true
var fullscreen := true

# --- Story (Visual Novel) ---
var seen_chapters := {}
var pending_story_chapter: String = ""
var pending_story_next_scene: String = "res://LevelSelect.tscn"

# --- Last run (read by Results.gd, not persisted to disk) ---
var last_run := {
	"served": 0,
	"satisfied": 0,
	"target": 0,
	"coins_earned": 0,
	"avg_order_time": 0.0,
	"max_combo": 0,
	"stars": 0,
	"level_id": 0,
}


func _ready() -> void:
	load_game()


func get_level(id: int) -> Dictionary:
	return levels[id]


func has_seen_chapter(id: String) -> bool:
	return seen_chapters.get(id, false)


func mark_story_seen(id: String) -> void:
	seen_chapters[id] = true
	save_game()


func start_story(chapter_id: String, next_scene: String) -> void:
	pending_story_chapter = chapter_id
	pending_story_next_scene = next_scene


# รสชาติทั้งหมดเปิดให้เล่นได้ตั้งแต่แรก ไม่มีระบบซื้อ/ปลดล็อกอีกต่อไป
func is_flavor_unlocked(_key: String) -> bool:
	return true


func buy_equipment(key: String, price: int) -> bool:
	if coins < price:
		return false
	coins -= price
	if key == "fast_scoop":
		upgrade_fast_scoop = true
	elif key == "expand_counter":
		upgrade_expand_counter = true
	elif key == "auto":
		upgrade_auto_churn = true
	save_game()
	return true


func buy_decor(key: String, price: int) -> bool:
	if owned_decor.get(key, false):
		return false
	if coins < price:
		return false
	coins -= price
	owned_decor[key] = true
	save_game()
	return true


func equip_decor(key: String) -> void:
	if not owned_decor.get(key, false):
		return
	equipped_decor = key
	save_game()


# มีความคืบหน้าที่จะเสียไปหรือยัง (ใช้ตัดสินใจว่าต้องถามยืนยันก่อนกด "เกมใหม่" หรือเปล่า)
func has_progress() -> bool:
	if coins > 0 or upgrade_fast_scoop or upgrade_expand_counter or upgrade_auto_churn:
		return true
	if equipped_decor != "classic":
		return true
	for k in owned_decor.keys():
		if k != "classic" and owned_decor[k]:
			return true
	if levels[0]["stars"] > 0:
		return true
	for i in range(1, levels.size()):
		if levels[i]["stars"] > 0 or levels[i]["unlocked"]:
			return true
	if not seen_chapters.is_empty():
		return true
	return false


func start_new_game() -> void:
	coins = 0
	upgrade_fast_scoop = false
	upgrade_expand_counter = false
	upgrade_auto_churn = false
	for k in owned_decor.keys():
		owned_decor[k] = (k == "classic")
	equipped_decor = "classic"
	seen_chapters.clear()
	for i in levels.size():
		levels[i]["stars"] = 0
		levels[i]["unlocked"] = (i == 0)
	current_level_id = 0
	save_game()


func complete_level(id: int, stars: int, coins_earned: int) -> void:
	coins += coins_earned
	if stars > levels[id]["stars"]:
		levels[id]["stars"] = stars
	if stars > 0 and id + 1 < levels.size():
		levels[id + 1]["unlocked"] = true
	save_game()


func apply_settings(sfx: bool, music: bool, full: bool) -> void:
	sfx_enabled = sfx
	music_enabled = music
	fullscreen = full
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if full else DisplayServer.WINDOW_MODE_WINDOWED
	)
	settings_changed.emit()
	save_game()


# ------------------------------------------------------------
#  บันทึก / โหลดเกม (user://savegame.json)
# ------------------------------------------------------------

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game() -> void:
	var data := {
		"coins": coins,
		"upgrade_fast_scoop": upgrade_fast_scoop,
		"upgrade_expand_counter": upgrade_expand_counter,
		"upgrade_auto_churn": upgrade_auto_churn,
		"owned_decor": owned_decor,
		"equipped_decor": equipped_decor,
		"levels": levels,
		"seen_chapters": seen_chapters,
		"sfx_enabled": sfx_enabled,
		"music_enabled": music_enabled,
		"fullscreen": fullscreen,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var text := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return false

	coins = int(parsed.get("coins", coins))
	upgrade_fast_scoop = bool(parsed.get("upgrade_fast_scoop", upgrade_fast_scoop))
	upgrade_expand_counter = bool(parsed.get("upgrade_expand_counter", upgrade_expand_counter))
	upgrade_auto_churn = bool(parsed.get("upgrade_auto_churn", upgrade_auto_churn))

	var loaded_decor = parsed.get("owned_decor", null)
	if typeof(loaded_decor) == TYPE_DICTIONARY:
		for k in loaded_decor.keys():
			if owned_decor.has(k):
				owned_decor[k] = bool(loaded_decor[k])
	owned_decor["classic"] = true
	equipped_decor = str(parsed.get("equipped_decor", equipped_decor))
	if not owned_decor.get(equipped_decor, false):
		equipped_decor = "classic"

	# เก็บเฉพาะ "stars" กับ "unlocked" ของแต่ละด่าน ไม่แตะพารามิเตอร์ออกแบบด่าน
	# (target_customers/max_order_size) เผื่ออนาคตปรับสมดุลด่านใหม่
	var loaded_levels = parsed.get("levels", null)
	if typeof(loaded_levels) == TYPE_ARRAY:
		for i in min(loaded_levels.size(), levels.size()):
			if typeof(loaded_levels[i]) == TYPE_DICTIONARY:
				levels[i]["stars"] = int(loaded_levels[i].get("stars", levels[i]["stars"]))
				levels[i]["unlocked"] = bool(loaded_levels[i].get("unlocked", levels[i]["unlocked"]))

	var loaded_chapters = parsed.get("seen_chapters", null)
	if typeof(loaded_chapters) == TYPE_DICTIONARY:
		seen_chapters = loaded_chapters

	sfx_enabled = bool(parsed.get("sfx_enabled", sfx_enabled))
	music_enabled = bool(parsed.get("music_enabled", music_enabled))
	fullscreen = bool(parsed.get("fullscreen", fullscreen))
	return true
