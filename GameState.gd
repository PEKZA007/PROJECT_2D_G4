extends Node

# ------------------------------------------------------------
#  GameState - Autoload (Project Settings > Autoload)
#  เก็บสถานะที่ต้องใช้ร่วมกันข้ามฉาก: เหรียญ, ความคืบหน้าด่าน,
#  การตั้งค่า, อัปเกรด/รสชาติที่ปลดล็อกแล้ว, และผลลัพธ์ของรอบล่าสุด
# ------------------------------------------------------------

signal settings_changed

# --- Currency & upgrades (ของจริงที่มีผลต่อเกมเพลย์ ดูใน Game.gd) ---
var coins := 0
var upgrade_fast_scoop := false      # "ตักไอศกรีมไว" -> ลดเวลาคูลดาวน์การตัก
var upgrade_expand_counter := false  # "ขยายตู้" -> ถ้วยใส่วัตถุดิบได้เพิ่ม 1 ชิ้น

# --- Flavors: รสชาติพื้นฐาน 4 อย่างปลดล็อกให้ตั้งแต่แรก ที่เหลือซื้อในร้านค้า ---
var unlocked_flavors := {
	"vanilla": true,
	"chocolate": true,
	"strawberry": true,
	"mango": true,
	"orange": false,
	"blueberry": false,
	"cherry": false,
	"mint": false,
}

# --- Levels ---
# stars: 0-3, unlocked: bool, max_order_size: จำนวนวัตถุดิบสูงสุดต่อออเดอร์
var levels := [
	{"name": "ด่าน 1", "target_customers": 6, "time_limit": 45.0, "max_order_size": 2, "stars": 0, "unlocked": true},
	{"name": "ด่าน 2", "target_customers": 8, "time_limit": 50.0, "max_order_size": 2, "stars": 0, "unlocked": false},
	{"name": "ด่าน 3", "target_customers": 10, "time_limit": 55.0, "max_order_size": 3, "stars": 0, "unlocked": false},
	{"name": "ด่าน 4", "target_customers": 12, "time_limit": 60.0, "max_order_size": 3, "stars": 0, "unlocked": false},
	{"name": "ด่าน 5", "target_customers": 14, "time_limit": 65.0, "max_order_size": 3, "stars": 0, "unlocked": false},
	{"name": "ด่าน 6", "target_customers": 16, "time_limit": 70.0, "max_order_size": 4, "stars": 0, "unlocked": false},
	{"name": "ด่าน 7", "target_customers": 18, "time_limit": 75.0, "max_order_size": 4, "stars": 0, "unlocked": false},
	{"name": "ด่าน 8", "target_customers": 20, "time_limit": 80.0, "max_order_size": 4, "stars": 0, "unlocked": false},
]

var current_level_id := 0

# --- Settings ---
var sfx_enabled := true
var music_enabled := true
var fullscreen := true

# --- Last run (read by Results.gd) ---
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


func get_level(id: int) -> Dictionary:
	return levels[id]


func is_flavor_unlocked(key: String) -> bool:
	return unlocked_flavors.get(key, false)


func unlock_flavor(key: String) -> void:
	unlocked_flavors[key] = true


func start_new_game() -> void:
	coins = 0
	upgrade_fast_scoop = false
	upgrade_expand_counter = false
	for k in unlocked_flavors.keys():
		unlocked_flavors[k] = false
	unlocked_flavors["vanilla"] = true
	unlocked_flavors["chocolate"] = true
	unlocked_flavors["strawberry"] = true
	unlocked_flavors["mango"] = true
	for i in levels.size():
		levels[i]["stars"] = 0
		levels[i]["unlocked"] = (i == 0)
	current_level_id = 0


func complete_level(id: int, stars: int, coins_earned: int) -> void:
	coins += coins_earned
	if stars > levels[id]["stars"]:
		levels[id]["stars"] = stars
	if stars > 0 and id + 1 < levels.size():
		levels[id + 1]["unlocked"] = true


func apply_settings(sfx: bool, music: bool, full: bool) -> void:
	sfx_enabled = sfx
	music_enabled = music
	fullscreen = full
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if full else DisplayServer.WINDOW_MODE_WINDOWED
	)
	settings_changed.emit()
