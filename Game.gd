extends Node2D

# ------------------------------------------------------------
#  ฉากเล่นเกมหลัก — โครงสร้าง UI ทั้งหมดอยู่ใน Game.tscn แล้ว
#  (HUD, กล่องคำสั่งลูกค้า, คิวลูกค้า, ถ้วย, แผงจับจังหวะตัก, ถาดวัตถุดิบ)
#  สคริปต์นี้เหลือแค่ตรรกะเกม: คูลดาวน์การตัก, มินิเกมจับจังหวะ (กด SPACE
#  ให้ตรงโซนสีเขียว), การเสิร์ฟ, รางวัลตามมูลค่ารสชาติ, และจบด่าน
# ------------------------------------------------------------

enum ScoopState { IDLE, CHALLENGE, COOLDOWN }

const INGREDIENTS := {
	"vanilla": {"emoji": "🍦", "name": "วานิลลา", "value": 6},
	"chocolate": {"emoji": "🍫", "name": "ช็อกโกแลต", "value": 8},
	"strawberry": {"emoji": "🍓", "name": "สตรอเบอร์รี่", "value": 8},
	"mango": {"emoji": "🥭", "name": "มะม่วง", "value": 10},
	"orange": {"emoji": "🍊", "name": "ส้ม", "value": 12, "unlock_price": 80},
	"blueberry": {"emoji": "🫐", "name": "บลูเบอร์รี่", "value": 14, "unlock_price": 110},
	"cherry": {"emoji": "🍒", "name": "เชอร์รี่", "value": 16, "unlock_price": 140},
	"mint": {"emoji": "🌿", "name": "มินต์", "value": 18, "unlock_price": 170},
}
const CUSTOMER_TEXTURE_PATHS := [
	"res://assets/characters/CustomerA.png",
	"res://assets/characters/CustomerB.png",
	"res://assets/characters/CustomerC.png",
	"res://assets/characters/CustomerD.png",
	"res://assets/characters/CustomerE.png",
	"res://assets/characters/CustomerF.png",
]
const CHALLENGE_TIME_LIMIT := 3.0

var level: Dictionary
var level_id: int

var level_time_left: float
var customers_served := 0
var customers_satisfied := 0
var combo := 0
var max_combo := 0
var total_order_time := 0.0
var coins_earned := 0

var current_order: Array = []
var patience_time := 0.0
var patience_max := 0.0
var cup_contents: Array = []
var max_cup_capacity := 3

var is_running := true
var _space_was_pressed := false

# --- Scoop cooldown + rhythm challenge state ---
var scoop_state: int = ScoopState.IDLE
var scoop_pending_key: String = ""
var marker_t := 0.0
var marker_dir := 1
var marker_speed := 1.1
var zone_start := 0.4
var zone_end := 0.6
var challenge_timeout := 0.0
var cooldown_time_left := 0.0

var customer_textures: Array = []

# --- Node references (all real nodes, defined in Game.tscn) ---
@onready var timer_label: Label = $TimerLabel
@onready var progress_label: Label = $ProgressLabel
@onready var combo_label: Label = $ComboLabel
@onready var message_label: Label = $MessageLabel
@onready var order_label: Label = $OrderLabel
@onready var patience_bar: ProgressBar = $PatienceBar
@onready var cup_label: Label = $CupLabel
@onready var cup_zone: Panel = $CupZone
@onready var scoop_status_label: Label = $ScoopStatusLabel
@onready var clear_button: Button = $ClearButton
@onready var serve_button: Button = $ServeButton
@onready var bg_music: AudioStreamPlayer = $BGMusic
@onready var tray: HBoxContainer = $Tray

@onready var challenge_panel: Panel = $ChallengePanel
@onready var challenge_pending_label: Label = $ChallengePanel/PendingEmoji
@onready var challenge_track: ColorRect = $ChallengePanel/ChallengeTrack
@onready var challenge_zone: ColorRect = $ChallengePanel/ChallengeZone
@onready var challenge_marker: ColorRect = $ChallengePanel/ChallengeMarker

@onready var queue_portraits: Array = [
	$QueueSlot1/Portrait, $QueueSlot2/Portrait, $QueueSlot3/Portrait,
]


func _ready() -> void:
	level_id = GameState.current_level_id
	level = GameState.get_level(level_id)
	level_time_left = level["time_limit"]
	max_cup_capacity = level["max_order_size"] + 1 + (1 if GameState.upgrade_expand_counter else 0)
	randomize()

	for p in CUSTOMER_TEXTURE_PATHS:
		var tex := load(p)
		if tex:
			customer_textures.append(tex)

	clear_button.pressed.connect(_on_clear_cup)
	serve_button.pressed.connect(_serve)
	cup_zone.ingredient_dropped.connect(_on_ingredient_dropped)

	_setup_audio()
	_setup_tray()
	_spawn_customer()
	_update_hud()
	_update_scoop_status_label()


func _setup_audio() -> void:
	if bg_music.stream and bg_music.stream is AudioStreamMP3:
		bg_music.stream.loop = true
	if GameState.music_enabled:
		bg_music.play()


func _setup_tray() -> void:
	var avail := _available_flavor_keys()
	var icons := tray.get_children()
	for i in icons.size():
		var key: String = avail[i % avail.size()]
		icons[i].setup(key, INGREDIENTS[key]["emoji"])


func _available_flavor_keys() -> Array:
	var keys: Array = []
	for k in INGREDIENTS.keys():
		if GameState.is_flavor_unlocked(k):
			keys.append(k)
	if keys.is_empty():
		keys.append("vanilla")
	return keys


func _scoop_cooldown_duration() -> float:
	return 0.35 if GameState.upgrade_fast_scoop else 0.65


func _update_hud() -> void:
	var minutes := int(level_time_left) / 60
	var seconds := int(level_time_left) % 60
	timer_label.text = "⏱ %02d:%02d" % [minutes, seconds]
	progress_label.text = "🍦 %d/%d" % [customers_served, level["target_customers"]]
	combo_label.text = ("🔥 คอมโบ x%d" % combo) if combo > 0 else ""


func _update_scoop_status_label() -> void:
	if scoop_state == ScoopState.IDLE:
		scoop_status_label.text = "🍦 พร้อมตัก — ลากวัตถุดิบมาวางที่ถ้วย"
	elif scoop_state == ScoopState.CHALLENGE:
		scoop_status_label.text = "🎯 กด SPACE ให้ตรงโซนสีเขียว!"
	else:
		scoop_status_label.text = "✋ พักมือ... %.1f วิ" % max(cooldown_time_left, 0.0)


func _process(delta: float) -> void:
	if not is_running:
		return

	level_time_left -= delta
	if level_time_left <= 0:
		level_time_left = 0
		_end_level()
		return

	if current_order.size() > 0:
		patience_time -= delta
		patience_bar.value = max(patience_time, 0.0)
		if patience_time <= 0.0:
			_customer_left(false)

	if scoop_state == ScoopState.CHALLENGE:
		_process_scoop_challenge(delta)
	elif scoop_state == ScoopState.COOLDOWN:
		_process_cooldown(delta)

	var space_now := Input.is_physical_key_pressed(KEY_SPACE)
	if space_now and not _space_was_pressed:
		if scoop_state == ScoopState.CHALLENGE:
			_resolve_scoop_challenge()
		else:
			_serve()
	_space_was_pressed = space_now

	_update_hud()
	_update_scoop_status_label()


func _process_scoop_challenge(delta: float) -> void:
	marker_t += marker_dir * marker_speed * delta
	if marker_t > 1.0:
		marker_t = 1.0
		marker_dir = -1
	elif marker_t < 0.0:
		marker_t = 0.0
		marker_dir = 1
	challenge_timeout -= delta
	challenge_marker.position.x = 10 + marker_t * 200 - 2
	if challenge_timeout <= 0.0:
		_resolve_scoop_challenge(true)


func _process_cooldown(delta: float) -> void:
	cooldown_time_left -= delta
	if cooldown_time_left <= 0.0:
		scoop_state = ScoopState.IDLE


func _spawn_customer() -> void:
	if not is_running:
		return
	scoop_state = ScoopState.IDLE
	_hide_challenge_ui()

	var avail := _available_flavor_keys()
	var order_size: int = randi_range(1, min(level["max_order_size"], avail.size()))
	avail.shuffle()
	current_order = avail.slice(0, order_size)

	var names: Array = []
	for k in current_order:
		names.append("%s %s" % [INGREDIENTS[k]["emoji"], INGREDIENTS[k]["name"]])
	order_label.text = " + ".join(names)

	patience_max = max(6.0, 12.0 - customers_served * 0.3)
	patience_time = patience_max
	patience_bar.max_value = patience_max
	patience_bar.value = patience_max

	cup_contents.clear()
	_update_cup_label()
	_update_queue_faces()


func _update_queue_faces() -> void:
	if customer_textures.is_empty():
		return
	for portrait in queue_portraits:
		portrait.texture = customer_textures[randi() % customer_textures.size()]


func _on_ingredient_dropped(key: String, _emoji: String) -> void:
	if not is_running or current_order.is_empty():
		return
	if scoop_state != ScoopState.IDLE:
		message_label.text = "รอแปปนึง กำลังตักอยู่!"
		return
	if cup_contents.size() >= max_cup_capacity:
		message_label.text = "ถ้วยเต็มแล้ว!"
		return
	_start_scoop_challenge(key)


func _start_scoop_challenge(key: String) -> void:
	scoop_pending_key = key
	scoop_state = ScoopState.CHALLENGE
	marker_t = 0.0
	marker_dir = 1
	challenge_timeout = CHALLENGE_TIME_LIMIT
	marker_speed = 1.1 + level_id * 0.12 + customers_served * 0.02
	var zone_width: float = clamp(0.32 - level_id * 0.02 - customers_served * 0.005, 0.14, 0.32)
	zone_start = randf() * (1.0 - zone_width)
	zone_end = zone_start + zone_width
	_show_challenge_ui()


func _show_challenge_ui() -> void:
	challenge_panel.visible = true
	cup_label.visible = false
	challenge_pending_label.text = "กำลังตัก %s" % INGREDIENTS[scoop_pending_key]["emoji"]
	challenge_zone.position.x = 10 + zone_start * 200
	challenge_zone.size.x = (zone_end - zone_start) * 200
	challenge_marker.position.x = 10 + marker_t * 200 - 2


func _hide_challenge_ui() -> void:
	challenge_panel.visible = false
	cup_label.visible = true


func _resolve_scoop_challenge(forced_miss: bool = false) -> void:
	var hit: bool = (not forced_miss) and marker_t >= zone_start and marker_t <= zone_end
	if hit:
		cup_contents.append(scoop_pending_key)
		_update_cup_label()
		message_label.text = "ตักสวย! 🎯"
	else:
		message_label.text = "พลาดจังหวะ! ตักไม่ทัน 😵"
	scoop_pending_key = ""
	scoop_state = ScoopState.COOLDOWN
	cooldown_time_left = _scoop_cooldown_duration()
	_hide_challenge_ui()


func _update_cup_label() -> void:
	var emojis: Array = []
	for k in cup_contents:
		emojis.append(INGREDIENTS[k]["emoji"])
	cup_label.text = " ".join(emojis)


func _on_clear_cup() -> void:
	cup_contents.clear()
	_update_cup_label()


func _serve() -> void:
	if not is_running or current_order.is_empty():
		return
	if scoop_state == ScoopState.CHALLENGE:
		message_label.text = "ตักให้เสร็จก่อนสิ! กด SPACE ให้ตรงจังหวะ"
		return
	var a: Array = current_order.duplicate()
	var b: Array = cup_contents.duplicate()
	a.sort()
	b.sort()
	if a == b:
		var order_time := patience_max - patience_time
		total_order_time += order_time
		var value_sum := 0
		for k in current_order:
			value_sum += int(INGREDIENTS[k]["value"])
		var reward := 5 + value_sum + combo * 3
		coins_earned += reward
		combo += 1
		max_combo = max(max_combo, combo)
		customers_satisfied += 1
		message_label.text = "เสิร์ฟถูกใจ! +%d 🪙" % reward
		_customer_left(true)
	else:
		message_label.text = "ยังไม่ตรงออเดอร์นะ 😅"


func _customer_left(satisfied: bool) -> void:
	if not satisfied:
		combo = 0
		message_label.text = "ลูกค้าเดินหนีไปแล้ว 😠"
	customers_served += 1
	current_order = []
	cup_contents.clear()
	_update_cup_label()
	scoop_state = ScoopState.IDLE
	_hide_challenge_ui()

	if customers_served >= level["target_customers"]:
		_end_level()
	else:
		_spawn_customer()


func _end_level() -> void:
	if not is_running:
		return
	is_running = false

	var ratio: float = float(customers_satisfied) / float(max(level["target_customers"], 1))
	var stars := 0
	if ratio >= 0.85:
		stars = 3
	elif ratio >= 0.6:
		stars = 2
	elif ratio > 0.0:
		stars = 1

	var avg_time := 0.0
	if customers_satisfied > 0:
		avg_time = total_order_time / customers_satisfied

	GameState.last_run = {
		"served": customers_served,
		"satisfied": customers_satisfied,
		"target": level["target_customers"],
		"coins_earned": coins_earned,
		"avg_order_time": avg_time,
		"max_combo": max_combo,
		"stars": stars,
		"level_id": level_id,
	}
	GameState.complete_level(level_id, stars, coins_earned)
	get_tree().change_scene_to_file("res://Results.tscn")
