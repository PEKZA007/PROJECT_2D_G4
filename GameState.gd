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
var player_name := "แพรวา"
var upgrade_fast_scoop := false      # "ตักเจลาโต้ไว" -> ลดเวลาคูลดาวน์การตัก
var upgrade_expand_counter := false  # "ขยายตู้" -> ถ้วยใส่วัตถุดิบได้เพิ่ม 1 ชิ้น
var upgrade_auto_churn := false      # "ปั่นออโต้" -> มินิเกมตักเจลาโต้ง่ายขึ้น
var upgrade_patience_boost := false  # "ลูกค้าใจเย็นขึ้น" -> เพิ่มเวลาอดทนของลูกค้า 20%
var upgrade_combo_saver := false     # "ตาข่ายกันคอมโบหลุด" -> เสิร์ฟผิดครั้งแรกในด่านไม่ทำคอมโบหลุด
var upgrade_coin_boost := false      # "โบนัสเหรียญพิเศษ" -> ได้เหรียญจากทุกออเดอร์เพิ่ม 10%

# --- Decor: ธีมตกแต่งร้าน ซื้อ/สวมใส่ได้ในร้านค้า ("classic" ฟรีตั้งแต่แรก) ---
var owned_decor := {
	"classic": true,
	"pastel": false,
	"tropical": false,
	"midnight": false,
	"mint_choc": false,
	"sunset_citrus": false,
}
var equipped_decor := "classic"

# --- Skins: สกินที่ตัก/เคาน์เตอร์โชว์ของ ซื้อ/สวมใส่ได้ในร้านค้า ("classic" ฟรีตั้งแต่แรก) ---
var owned_skins := {
	"classic": true,
	"gold": false,
	"mint": false,
}
var equipped_skin := "classic"

# --- Levels ---
# stars: 0-3, unlocked: bool, max_order_size: จำนวนรสเจลาโต้สูงสุดต่อออเดอร์
# (ไม่มีระบบจำกัดเวลาต่อด่านแล้ว — เล่นจนกว่าจะเสิร์ฟครบ target_customers)
var levels := [
	{"name": "Day 0", "target_customers": 6, "max_order_size": 1, "stars": 0, "unlocked": true},
	{"name": "Day 1", "target_customers": 8, "max_order_size": 1, "stars": 0, "unlocked": false},
	{"name": "Day 2", "target_customers": 10, "max_order_size": 2, "stars": 0, "unlocked": false},
	{"name": "Day 3", "target_customers": 12, "max_order_size": 2, "stars": 0, "unlocked": false},
	{"name": "Day 4", "target_customers": 14, "max_order_size": 2, "stars": 0, "unlocked": false},
	{"name": "Day 5", "target_customers": 16, "max_order_size": 2, "stars": 0, "unlocked": false},
	{"name": "Day 6", "target_customers": 18, "max_order_size": 2, "stars": 0, "unlocked": false},
	{"name": "Day 7", "target_customers": 20, "max_order_size": 2, "stars": 0, "unlocked": false},
]

var current_level_id := 0

# --- Settings ---
var sfx_enabled := true
var music_enabled := true
var fullscreen := true

# --- Story (Visual Novel) ---
var seen_chapters := {}
var seen_tutorial_days := {}
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


func has_seen_tutorial(day_id: int) -> bool:
	return seen_tutorial_days.get(str(day_id), false)


func mark_tutorial_seen(day_id: int) -> void:
	seen_tutorial_days[str(day_id)] = true
	save_game()


# Day 0-1 มี 3 รสแรก และ Day 2 เป็นต้นไปปลดล็อกเจลาโต้ทุกรส
func is_flavor_unlocked(key: String) -> bool:
	var index := GelatoData.FLAVOR_ORDER.find(key)
	if index < 0:
		return false
	return index < 3 if current_level_id < 2 else true

func are_toppings_unlocked() -> bool:
	return current_level_id >= 1


func is_equipment_owned(key: String) -> bool:
	match key:
		"fast_scoop": return upgrade_fast_scoop
		"expand_counter": return upgrade_expand_counter
		"auto": return upgrade_auto_churn
		"patience_boost": return upgrade_patience_boost
		"combo_saver": return upgrade_combo_saver
		"coin_boost": return upgrade_coin_boost
		_: return false


func buy_equipment(key: String, price: int) -> bool:
	if is_equipment_owned(key):
		return false
	if coins < price:
		return false
	coins -= price
	if key == "fast_scoop":
		upgrade_fast_scoop = true
	elif key == "expand_counter":
		upgrade_expand_counter = true
	elif key == "auto":
		upgrade_auto_churn = true
	elif key == "patience_boost":
		upgrade_patience_boost = true
	elif key == "combo_saver":
		upgrade_combo_saver = true
	elif key == "coin_boost":
		upgrade_coin_boost = true
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


func buy_skin(key: String, price: int) -> bool:
	if owned_skins.get(key, false):
		return false
	if coins < price:
		return false
	coins -= price
	owned_skins[key] = true
	save_game()
	return true


func equip_skin(key: String) -> void:
	if not owned_skins.get(key, false):
		return
	equipped_skin = key
	save_game()


# มีความคืบหน้าที่จะเสียไปหรือยัง (ใช้ตัดสินใจว่าต้องถามยืนยันก่อนกด "เกมใหม่" หรือเปล่า)
func has_progress() -> bool:
	if coins > 0 or upgrade_fast_scoop or upgrade_expand_counter or upgrade_auto_churn:
		return true
	if upgrade_patience_boost or upgrade_combo_saver or upgrade_coin_boost:
		return true
	if equipped_decor != "classic":
		return true
	for k in owned_decor.keys():
		if k != "classic" and owned_decor[k]:
			return true
	if equipped_skin != "classic":
		return true
	for k in owned_skins.keys():
		if k != "classic" and owned_skins[k]:
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
	player_name = "แพรวา"
	upgrade_fast_scoop = false
	upgrade_expand_counter = false
	upgrade_auto_churn = false
	upgrade_patience_boost = false
	upgrade_combo_saver = false
	upgrade_coin_boost = false
	for k in owned_decor.keys():
		owned_decor[k] = (k == "classic")
	equipped_decor = "classic"
	for k in owned_skins.keys():
		owned_skins[k] = (k == "classic")
	equipped_skin = "classic"
	seen_chapters.clear()
	seen_tutorial_days.clear()
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
		"player_name": player_name,
		"upgrade_fast_scoop": upgrade_fast_scoop,
		"upgrade_expand_counter": upgrade_expand_counter,
		"upgrade_auto_churn": upgrade_auto_churn,
		"upgrade_patience_boost": upgrade_patience_boost,
		"upgrade_combo_saver": upgrade_combo_saver,
		"upgrade_coin_boost": upgrade_coin_boost,
		"owned_decor": owned_decor,
		"equipped_decor": equipped_decor,
		"owned_skins": owned_skins,
		"equipped_skin": equipped_skin,
		"levels": levels,
		"seen_chapters": seen_chapters,
		"seen_tutorial_days": seen_tutorial_days,
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
	player_name = str(parsed.get("player_name", player_name)).strip_edges()
	if player_name.is_empty(): player_name = "แพรวา"
	upgrade_fast_scoop = bool(parsed.get("upgrade_fast_scoop", upgrade_fast_scoop))
	upgrade_expand_counter = bool(parsed.get("upgrade_expand_counter", upgrade_expand_counter))
	upgrade_auto_churn = bool(parsed.get("upgrade_auto_churn", upgrade_auto_churn))
	upgrade_patience_boost = bool(parsed.get("upgrade_patience_boost", upgrade_patience_boost))
	upgrade_combo_saver = bool(parsed.get("upgrade_combo_saver", upgrade_combo_saver))
	upgrade_coin_boost = bool(parsed.get("upgrade_coin_boost", upgrade_coin_boost))

	var loaded_decor = parsed.get("owned_decor", null)
	if typeof(loaded_decor) == TYPE_DICTIONARY:
		for k in loaded_decor.keys():
			if owned_decor.has(k):
				owned_decor[k] = bool(loaded_decor[k])
	owned_decor["classic"] = true
	equipped_decor = str(parsed.get("equipped_decor", equipped_decor))
	if not owned_decor.get(equipped_decor, false):
		equipped_decor = "classic"

	var loaded_skins = parsed.get("owned_skins", null)
	if typeof(loaded_skins) == TYPE_DICTIONARY:
		for k in loaded_skins.keys():
			if owned_skins.has(k):
				owned_skins[k] = bool(loaded_skins[k])
	owned_skins["classic"] = true
	equipped_skin = str(parsed.get("equipped_skin", equipped_skin))
	if not owned_skins.get(equipped_skin, false):
		equipped_skin = "classic"

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

	var loaded_tutorial_days = parsed.get("seen_tutorial_days", null)
	if typeof(loaded_tutorial_days) == TYPE_DICTIONARY:
		seen_tutorial_days = loaded_tutorial_days

	sfx_enabled = bool(parsed.get("sfx_enabled", sfx_enabled))
	music_enabled = bool(parsed.get("music_enabled", music_enabled))
	fullscreen = bool(parsed.get("fullscreen", fullscreen))
	return true
