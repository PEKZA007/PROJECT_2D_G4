extends Node2D

# ------------------------------------------------------------
#  ฉากเล่นเกมหลัก
#  - นาฬิกานับถอยหลังของด่าน (บนซ้าย) / จำนวนลูกค้า X/Y (บนขวา)
#  - กล่องคำสั่งลูกค้า + แถบความอดทน (ซ้าย)
#  - ลากวัตถุดิบจากถาดด้านล่างลงถ้วย -> เข้าสู่มินิเกมจับจังหวะ
#    (กด SPACE ให้ตรงโซนสีเขียว) ถึงจะตักสำเร็จ จากนั้นมีคูลดาวน์
#    ก่อนตักครั้งถัดไปได้ -> เมื่อวัตถุดิบครบตรงออเดอร์ กด SPACE
#    (ตอนไม่ได้อยู่ในมินิเกมตัก) เพื่อเสิร์ฟ
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
const PLAYER_TEXTURE_PATH := "res://assets/characters/Player.png"
const GAMEPLAY_MUSIC_PATH := "res://assets/audio/gameplay_theme.mp3"
const CHALLENGE_TIME_LIMIT := 3.0
const TRAY_SLOT_COUNT := 8

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

# node refs
var timer_label: Label
var progress_label: Label
var order_label: Label
var patience_bar: ProgressBar
var cup_label: Label
var message_label: Label
var combo_label: Label
var scoop_status_label: Label
var queue_portraits: Array = []
var customer_textures: Array = []
var bg_music: AudioStreamPlayer

var challenge_panel: Panel
var challenge_track: ColorRect
var challenge_zone: ColorRect
var challenge_marker: ColorRect


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

	_build_ui()
	_setup_audio()
	_spawn_customer()


func _setup_audio() -> void:
	bg_music = AudioStreamPlayer.new()
	var stream := load(GAMEPLAY_MUSIC_PATH)
	if stream:
		if stream is AudioStreamMP3:
			stream.loop = true
		bg_music.stream = stream
		bg_music.volume_db = -10
		add_child(bg_music)
		if GameState.music_enabled:
			bg_music.play()


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


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color8(179, 229, 252)
	bg.size = Vector2(960, 640)
	add_child(bg)

	var counter := ColorRect.new()
	counter.color = Color8(141, 85, 36)
	counter.position = Vector2(0, 500)
	counter.size = Vector2(960, 140)
	add_child(counter)

	# --- Top HUD ---
	timer_label = UIUtils.make_label("00:00", Vector2(20, 15), 26, Color8(40, 40, 40))
	add_child(timer_label)

	progress_label = UIUtils.make_label("", Vector2(820, 15), 22, Color8(40, 40, 40))
	add_child(progress_label)

	combo_label = UIUtils.make_label("", Vector2(400, 15), 20, Color8(200, 80, 20))
	add_child(combo_label)

	message_label = UIUtils.make_label("", Vector2(230, 45), 18, Color8(150, 40, 40))
	message_label.size = Vector2(500, 26)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(message_label)

	# --- Order box ---
	add_child(UIUtils.make_panel(Vector2(30, 90), Vector2(300, 95), Color8(255, 255, 255, 210), 14))
	add_child(UIUtils.make_label("คำสั่งลูกค้า", Vector2(45, 98), 16, Color8(120, 120, 120)))
	order_label = UIUtils.make_label("", Vector2(45, 122), 18, Color8(30, 30, 30))
	order_label.size = Vector2(270, 55)
	order_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(order_label)

	add_child(UIUtils.make_label("ความอดทน", Vector2(30, 195), 14, Color8(120, 120, 120)))
	patience_bar = ProgressBar.new()
	patience_bar.position = Vector2(30, 216)
	patience_bar.size = Vector2(300, 18)
	patience_bar.show_percentage = false
	add_child(patience_bar)

	# --- Customer queue portraits ---
	var slot_specs := [
		{"panel_pos": Vector2(430, 130), "panel_size": Vector2(130, 130), "tex_size": Vector2(150, 200), "alpha": 1.0},
		{"panel_pos": Vector2(610, 165), "panel_size": Vector2(95, 95), "tex_size": Vector2(105, 140), "alpha": 0.65},
		{"panel_pos": Vector2(750, 165), "panel_size": Vector2(95, 95), "tex_size": Vector2(105, 140), "alpha": 0.65},
	]
	for spec in slot_specs:
		var panel_pos: Vector2 = spec["panel_pos"]
		var panel_size: Vector2 = spec["panel_size"]
		var backdrop := UIUtils.make_panel(panel_pos, panel_size, Color8(255, 224, 178), int(panel_size.x / 2))
		add_child(backdrop)

		var tex_size: Vector2 = spec["tex_size"]
		var portrait := TextureRect.new()
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.size = tex_size
		portrait.position = panel_pos + (panel_size - tex_size) / 2.0
		portrait.modulate = Color(1, 1, 1, spec["alpha"])
		add_child(portrait)
		queue_portraits.append(portrait)

	# --- Player avatar (decorative) ---
	var player_portrait := TextureRect.new()
	player_portrait.texture = load(PLAYER_TEXTURE_PATH)
	player_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	player_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	player_portrait.position = Vector2(10, 358)
	player_portrait.size = Vector2(130, 175)
	add_child(player_portrait)

	var player_tag := UIUtils.make_label("Player", Vector2(10, 534), 14, Color.WHITE)
	player_tag.size = Vector2(130, 20)
	player_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(player_tag)

	# --- Cup drop zone ---
	add_child(UIUtils.make_panel(Vector2(400, 330), Vector2(220, 110), Color8(255, 255, 255, 220), 16))
	add_child(UIUtils.make_label("ถ้วยไอศกรีม (ลากวัตถุดิบมาวาง)", Vector2(390, 305), 13, Color8(90, 90, 90)))

	var cup_zone := Panel.new()
	cup_zone.set_script(load("res://CupDropZone.gd"))
	cup_zone.position = Vector2(400, 330)
	cup_zone.size = Vector2(220, 110)
	cup_zone.self_modulate = Color(1, 1, 1, 0)
	cup_zone.ingredient_dropped.connect(_on_ingredient_dropped)
	add_child(cup_zone)

	cup_label = Label.new()
	cup_label.position = Vector2(400, 330)
	cup_label.size = Vector2(220, 110)
	cup_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cup_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cup_label.add_theme_font_size_override("font_size", 24)
	cup_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cup_label)

	# --- Rhythm scoop-challenge overlay (sits on top of the cup, hidden by default) ---
	challenge_panel = Panel.new()
	challenge_panel.position = Vector2(400, 330)
	challenge_panel.size = Vector2(220, 110)
	var cp_style := StyleBoxFlat.new()
	cp_style.bg_color = Color8(255, 255, 255, 245)
	cp_style.set_corner_radius_all(16)
	challenge_panel.add_theme_stylebox_override("panel", cp_style)
	challenge_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	challenge_panel.visible = false
	add_child(challenge_panel)

	var instruction := UIUtils.make_label("กด SPACE ให้ตรงจังหวะ!", Vector2(10, 8), 13, Color8(60, 60, 60))
	instruction.size = Vector2(200, 20)
	instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	challenge_panel.add_child(instruction)

	var pending_label := Label.new()
	pending_label.name = "PendingEmoji"
	pending_label.position = Vector2(10, 28)
	pending_label.size = Vector2(200, 26)
	pending_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pending_label.add_theme_font_size_override("font_size", 20)
	challenge_panel.add_child(pending_label)

	challenge_track = ColorRect.new()
	challenge_track.color = Color8(225, 225, 225)
	challenge_track.position = Vector2(10, 62)
	challenge_track.size = Vector2(200, 18)
	challenge_panel.add_child(challenge_track)

	challenge_zone = ColorRect.new()
	challenge_zone.color = Color8(120, 220, 140)
	challenge_zone.position = Vector2(10, 62)
	challenge_zone.size = Vector2(40, 18)
	challenge_panel.add_child(challenge_zone)

	challenge_marker = ColorRect.new()
	challenge_marker.color = Color8(40, 40, 40)
	challenge_marker.size = Vector2(4, 26)
	challenge_marker.position = Vector2(10, 58)
	challenge_panel.add_child(challenge_marker)

	var clear_btn := UIUtils.make_button("ล้าง", Vector2(400, 450), Vector2(100, 34), Color8(230, 230, 230), 14)
	clear_btn.pressed.connect(_on_clear_cup)
	add_child(clear_btn)

	var serve_btn := UIUtils.make_button("เสิร์ฟ ✔️ (Space)", Vector2(700, 445), Vector2(230, 50), Color8(50, 50, 50), 18, Color.WHITE)
	serve_btn.pressed.connect(_serve)
	add_child(serve_btn)

	# --- Scoop status line (above tray) ---
	scoop_status_label = UIUtils.make_label("", Vector2(170, 528), 15, Color.WHITE)
	scoop_status_label.size = Vector2(600, 22)
	add_child(scoop_status_label)

	# --- Ingredient tray (only shows unlocked flavors) ---
	var tray := HBoxContainer.new()
	tray.position = Vector2(40, 555)
	tray.add_theme_constant_override("separation", 12)
	add_child(tray)
	var avail := _available_flavor_keys()
	for i in TRAY_SLOT_COUNT:
		var key: String = avail[i % avail.size()]
		var info: Dictionary = INGREDIENTS[key]
		var icon := Panel.new()
		icon.set_script(load("res://IngredientIcon.gd"))
		icon.custom_minimum_size = Vector2(64, 64)
		icon.setup(key, info["emoji"])
		tray.add_child(icon)

	_update_hud()
	_update_scoop_status_label()


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
	var pending_label: Label = challenge_panel.get_node("PendingEmoji")
	pending_label.text = "กำลังตัก %s" % INGREDIENTS[scoop_pending_key]["emoji"]
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
