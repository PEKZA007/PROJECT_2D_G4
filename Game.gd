extends Node2D

# ------------------------------------------------------------
#  ฉากเล่นเกมหลัก — Good Goods Gelato House
#  ลำดับการเสิร์ฟ: ลากภาชนะมาวางก่อน (โคน 1 รส / ถ้วยเล็ก 1 รส / ถ้วยใหญ่ 2 รส)
#  -> ตักเจลาโต้ (จับจังหวะ กด SPACE) -> ใส่ท็อปปิ้งได้ (หลังตักอย่างน้อย 1 ครั้ง)
#  -> กด SPACE เพื่อเสิร์ฟ
# ------------------------------------------------------------

enum ScoopState { IDLE, CHALLENGE, COOLDOWN }

const MAX_TOPPING_CAPACITY := 1
const CUSTOMER_TEXTURE_PATHS := [
	"res://assets/characters/CustomerA.png",
	"res://assets/characters/CustomerB.png",
	"res://assets/characters/CustomerC.png",
	"res://assets/characters/CustomerD.png",
	"res://assets/characters/CustomerE.png",
	"res://assets/characters/CustomerF.png",
]
const CHALLENGE_TIME_LIMIT := 3.0

const CONE_BACK := "res://assets/gelato/cone/cone_back.png"
const CONE_FRONT := "res://assets/gelato/cone/cone_front.png"
const SMALL_CUP := "res://assets/gelato/small/cup.png"
const LARGE_CUP := "res://assets/gelato/large/cup.png"

# ตำแหน่ง/ขนาด (offset_left, offset_top, offset_right, offset_bottom) ภายใน BuildStage (410x410)
const RECT_FULL := Rect2(0, 0, 410, 410)

var level: Dictionary
var level_id: int

var customers_served := 0
var customers_satisfied := 0
var combo := 0
var max_combo := 0
var total_order_time := 0.0
var coins_earned := 0

var current_order: Dictionary = {}     # {"container": key, "flavors": [...], "toppings": [...]}
var patience_time := 0.0
var patience_max := 0.0

var chosen_container: String = ""
var cup_flavor_contents: Array = []
var cup_topping_contents: Array = []

const CAT_BONUS_COOLDOWN := 12.0
const CAT_BONUS_MIN := 3
const CAT_BONUS_MAX := 8
var cat_bonus_cooldown_left := 0.0

var is_running := true
var _space_was_pressed := false
var _combo_saver_used := false   # ใช้สิทธิ์ "ตาข่ายกันคอมโบหลุด" ไปแล้วในด่านนี้หรือยัง
var _last_serve_msec := 0
const SERVE_DEBOUNCE_MSEC := 150 # กันกดเสิร์ฟรัว ๆ (ปุ่ม+SPACE ยิงซ้อนกันจนถ้วยหาย)

# --- Scoop cooldown + rhythm challenge state (ใช้เฉพาะตอนตักเจลาโต้) ---
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
@onready var background_rect: ColorRect = $Background
@onready var scene_backdrop: TextureRect = $RoomBackdrop
@onready var counter_rect: ColorRect = $Counter
@onready var counter_art: TextureRect = $CounterArt
@onready var run_coins_label: Label = $CoinsLabel
@onready var progress_label: Label = $ProgressLabel
@onready var combo_label: Label = $ComboLabel
@onready var message_label: Label = $MessageLabel
@onready var order_label: Label = $OrderLabel
@onready var patience_bar: ProgressBar = $PatienceBar
@onready var scoop_status_label: Label = $ScoopStatusLabel
@onready var clear_button: Button = $ClearButton
@onready var serve_button: Button = $ServeButton
@onready var bg_music: AudioStreamPlayer = $BGMusic
@onready var tray: HBoxContainer = $Tray
@onready var topping_tray: HBoxContainer = $ToppingTray
@onready var container_tray: HBoxContainer = $ContainerTray

@onready var build_stage: Control = $BuildStage
@onready var layer_cup: TextureRect = $BuildStage/LayerCup
@onready var layer_scoop_back: TextureRect = $BuildStage/LayerScoopBack
@onready var layer_scoop_mid: TextureRect = $BuildStage/LayerScoopMid
@onready var layer_scoop_front: TextureRect = $BuildStage/LayerScoopFront
@onready var layer_container_front: TextureRect = $BuildStage/LayerContainerFront
@onready var layer_topping: TextureRect = $BuildStage/LayerTopping
@onready var empty_stage_label: Label = $BuildStage/EmptyStageLabel
@onready var drop_zone: Panel = $DropZone
@onready var cat_bonus_button: Button = $CatBonusButton
@onready var trash_bin_zone: Panel = $TrashBinZone

@onready var challenge_panel: Panel = $ChallengePanel
@onready var challenge_pending_label: Label = $ChallengePanel/PendingLabel
@onready var challenge_arc: Control = $ChallengePanel/ChallengeArc

@onready var queue_portraits: Array = [
	$QueueSlot1/Portrait,
]


func _ready() -> void:
	level_id = GameState.current_level_id
	level = GameState.get_level(level_id)
	randomize()
	_apply_decor_theme()
	_apply_skin()

	for p in CUSTOMER_TEXTURE_PATHS:
		var tex := load(p)
		if tex:
			customer_textures.append(tex)

	clear_button.pressed.connect(_on_clear_cup)
	serve_button.pressed.connect(_serve)
	drop_zone.ingredient_dropped.connect(_on_ingredient_dropped)
	cat_bonus_button.pressed.connect(_on_cat_bonus_pressed)
	trash_bin_zone.ingredient_dropped.connect(_on_trash_ingredient_dropped)

	# ปุ่ม Serve/Clear ไม่ควรรับโฟกัสคีย์บอร์ด เพราะ Godot จะยิงสัญญาณ "pressed"
	# ซ้ำอัตโนมัติเวลากด SPACE/Enter ตอนปุ่มมีโฟกัส ซึ่งจะไปชนกับการเช็ค SPACE
	# แบบ manual ใน _process() ทำให้ _serve() ถูกเรียกซ้อนกันสองครั้งในเฟรมเดียว
	# (ถ้วยที่เพิ่งวางไว้เลยดูเหมือน "หาย" เพราะออเดอร์ถัดไปมาแทนที่ทันที)
	serve_button.focus_mode = Control.FOCUS_NONE
	clear_button.focus_mode = Control.FOCUS_NONE

	CursorFX.set_empty()

	_setup_audio()
	_setup_container_tray()
	_setup_tray()
	_setup_topping_tray()
	_setup_counter_hotspots()
	_spawn_customer()
	_update_hud()
	_update_scoop_status_label()
	_refresh_build_visual()


func _exit_tree() -> void:
	CursorFX.clear()


func _setup_counter_hotspots() -> void:
	# ล็อกวัตถุดิบบนเคาน์เตอร์ให้ตรงกับกติกาของวันปัจจุบัน
	# สำคัญ: อย่าล็อกเฉพาะรส เพราะผู้เล่นสามารถลากภาชนะใหญ่/ท็อปปิ้งจาก hotspot ได้เช่นกัน
	var unlocked_flavors: Array = _available_flavor_keys()
	var available_containers: Array = _available_container_keys()
	var toppings_unlocked := GameState.are_toppings_unlocked()

	for child in get_children():
		if child is Button and child.name.begins_with("Hotspot"):
			var key: String = str(child.get_meta("ingredient_key", ""))
			var kind: String = str(child.get_meta("kind", ""))
			var allowed := true
			match kind:
				"flavor": allowed = unlocked_flavors.has(key)
				"container": allowed = available_containers.has(key)
				"topping": allowed = toppings_unlocked and GelatoData.TOPPINGS.has(key)
				_: allowed = false

			child.disabled = not allowed
			if child.has_node("LockOverlay"):
				child.get_node("LockOverlay").visible = not allowed


func _apply_decor_theme() -> void:
	var decor: Dictionary = DecorData.get_theme(GameState.equipped_decor)
	background_rect.color = decor["background"]
	scene_backdrop.modulate = (decor["background"] as Color).lerp(Color.WHITE, 0.6)
	counter_rect.color = decor["counter"]
	run_coins_label.add_theme_color_override("font_color", decor["text_color"])
	progress_label.add_theme_color_override("font_color", decor["text_color"])
	combo_label.add_theme_color_override("font_color", decor["combo_color"])
	message_label.add_theme_color_override("font_color", decor["message_color"])


func _apply_skin() -> void:
	var skin: Dictionary = SkinData.get_skin(GameState.equipped_skin)
	var tex: Texture2D = load(skin.get("counter_texture", "")) as Texture2D
	if tex:
		counter_art.texture = tex


func _setup_audio() -> void:
	if bg_music.stream and bg_music.stream is AudioStreamMP3:
		bg_music.stream.loop = true
	if GameState.music_enabled:
		bg_music.play()


func _setup_container_tray() -> void:
	var available := _available_container_keys()
	var icons := container_tray.get_children()
	for i in icons.size():
		var icon = icons[i]
		icon.visible = i < available.size()
		if i < available.size():
			var key: String = available[i]
			var info: Dictionary = GelatoData.CONTAINERS[key]
			icon.setup(key, "", "container", info["thumb"])


func _setup_tray() -> void:
	var available := _available_flavor_keys()
	var icons := tray.get_children()
	for i in icons.size():
		var icon = icons[i]
		icon.visible = i < available.size()
		if i < available.size():
			var key: String = available[i]
			var info: Dictionary = GelatoData.FLAVORS[key]
			icon.setup(key, "", "flavor", info["thumb"])


func _setup_topping_tray() -> void:
	var unlocked := GameState.are_toppings_unlocked()
	topping_tray.visible = unlocked
	var keys: Array = GelatoData.TOPPING_ORDER if unlocked else []
	var icons := topping_tray.get_children()
	for i in icons.size():
		var icon = icons[i]
		icon.visible = i < keys.size()
		if i < keys.size():
			var key: String = keys[i]
			var info: Dictionary = GelatoData.TOPPINGS[key]
			icon.setup(key, "", "topping", info["thumb"])


func _available_flavor_keys() -> Array:
	var keys: Array = []
	for k in GelatoData.FLAVOR_ORDER:
		if GameState.is_flavor_unlocked(k):
			keys.append(k)
	if keys.is_empty():
		keys.append("choc_mint")
	return keys


func _available_container_keys() -> Array:
	var keys: Array = []
	for k in GelatoData.CONTAINER_ORDER:
		var cap: int = GelatoData.container_capacity(k)
		if cap <= int(level["max_order_size"]):
			keys.append(k)
		elif k == "large_cup" and GameState.upgrade_expand_counter:
			keys.append(k)
	if keys.is_empty():
		keys.append("cone")
	return keys


func _scoop_cooldown_duration() -> float:
	return 0.35 if GameState.upgrade_fast_scoop else 0.65


func _update_hud() -> void:
	run_coins_label.text = "%d เหรียญ" % coins_earned
	progress_label.text = "ออเดอร์ %d/%d" % [customers_served, level["target_customers"]]
	combo_label.text = ("คอมโบ x%d" % combo) if combo > 0 else ""


func _update_scoop_status_label() -> void:
	if scoop_state == ScoopState.COOLDOWN:
		scoop_status_label.text = "พักมือ... %.1f วิ" % max(cooldown_time_left, 0.0)
	elif scoop_state == ScoopState.CHALLENGE:
		scoop_status_label.text = "กด SPACE ให้ตรงโซนสีเขียว!"
	elif chosen_container == "":
		scoop_status_label.text = "ลากภาชนะมาวางก่อนเลย"
	elif cup_flavor_contents.is_empty():
		scoop_status_label.text = "ตักเจลาโต้ได้เลย"
	elif cup_flavor_contents.size() < GelatoData.container_capacity(chosen_container):
		scoop_status_label.text = "ตักต่อได้อีก หรือใส่ท็อปปิ้งก็ได้"
	else:
		scoop_status_label.text = "ใส่ท็อปปิ้ง หรือเสิร์ฟได้เลย"


func _process(delta: float) -> void:
	if not is_running:
		return

	if not current_order.is_empty():
		patience_time -= delta
		patience_bar.value = max(patience_time, 0.0)
		if patience_time <= 0.0:
			_customer_left(false)

	if scoop_state == ScoopState.CHALLENGE:
		_process_scoop_challenge(delta)
	elif scoop_state == ScoopState.COOLDOWN:
		_process_cooldown(delta)

	if cat_bonus_cooldown_left > 0.0:
		cat_bonus_cooldown_left -= delta
		if cat_bonus_cooldown_left <= 0.0:
			cat_bonus_cooldown_left = 0.0
			cat_bonus_button.modulate = Color(1, 1, 1, 1)

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
	challenge_arc.set_marker(marker_t)
	if challenge_timeout <= 0.0:
		_resolve_scoop_challenge(true)


func _process_cooldown(delta: float) -> void:
	cooldown_time_left -= delta
	if cooldown_time_left <= 0.0:
		scoop_state = ScoopState.IDLE


func _spawn_customer() -> void:
	if not is_running:
		return

	# ลูกค้าที่มีเนื้อเรื่องสามารถสุ่มเข้ามาระหว่างเล่นในวันที่กำหนด
	var story_chapter: String = str(StoryData.RANDOM_CUSTOMER_STORIES.get(level_id, ""))
	if story_chapter != "" and not GameState.has_seen_chapter(story_chapter) and randf() < 0.18:
		GameState.start_story(story_chapter, "res://Game.tscn")
		get_tree().change_scene_to_file("res://VisualNovel.tscn")
		return

	scoop_state = ScoopState.IDLE
	_hide_challenge_ui()

	var avail_containers := _available_container_keys()
	var order_container: String = avail_containers[randi() % avail_containers.size()]
	var capacity: int = GelatoData.container_capacity(order_container)

	var avail := _available_flavor_keys()
	avail.shuffle()
	var flavor_count: int = min(capacity, avail.size())
	var order_flavors: Array = avail.slice(0, flavor_count)

	var topping_keys: Array = GelatoData.TOPPING_ORDER.duplicate()
	topping_keys.shuffle()
	var topping_count: int = randi_range(0, min(MAX_TOPPING_CAPACITY, topping_keys.size()))
	var order_toppings: Array = topping_keys.slice(0, topping_count)

	current_order = {"container": order_container, "flavors": order_flavors, "toppings": order_toppings}

	var text := "ภาชนะ: %s\n" % GelatoData.container_name(order_container)
	var flavor_names: Array = []
	for k in order_flavors:
		flavor_names.append(GelatoData.flavor_name(k))
	text += " + ".join(flavor_names)
	if not order_toppings.is_empty():
		var topping_names: Array = []
		for k in order_toppings:
			topping_names.append(GelatoData.topping_name(k))
		text += "\nท็อปปิ้ง: " + " + ".join(topping_names)
	order_label.text = text

	patience_max = max(12.0, 20.0 - customers_served * 0.3)
	if GameState.upgrade_patience_boost:
		patience_max *= 1.2
	patience_time = patience_max
	patience_bar.max_value = patience_max
	patience_bar.value = patience_max

	chosen_container = ""
	cup_flavor_contents.clear()
	cup_topping_contents.clear()
	_refresh_build_visual()
	_update_queue_faces()


func _update_queue_faces() -> void:
	if customer_textures.is_empty():
		return
	for portrait in queue_portraits:
		portrait.texture = customer_textures[randi() % customer_textures.size()]


func _on_cat_bonus_pressed() -> void:
	if cat_bonus_cooldown_left > 0.0:
		message_label.text = "แมวขอพักก่อนนะ เดี๋ยวลูบใหม่ได้"
		return
	var bonus: int = randi_range(CAT_BONUS_MIN, CAT_BONUS_MAX)
	coins_earned += bonus
	cat_bonus_cooldown_left = CAT_BONUS_COOLDOWN
	cat_bonus_button.modulate = Color(1, 1, 1, 0.55)
	message_label.text = "ลูบแมวแล้ว เหมียว~ +%d เหรียญ" % bonus
	SFX.play("coin")
	_update_hud()


func _on_trash_ingredient_dropped(_key: String, _emoji: String, _kind: String) -> void:
	# ลากวัตถุดิบ/ช้อนตักมาทิ้งที่ถังขยะ = ล้างช้อน ยกเลิกสิ่งที่กำลังจะตัก/หยิบอยู่
	# ไม่มีผลกับเจลาโต้ที่ตักลงถ้วยไปแล้ว แค่ยกเลิกของที่กำลังลากอยู่ในมือ
	CursorFX.set_empty()
	message_label.text = "ล้างช้อนตักแล้ว สะอาดพร้อมตักใหม่!"
	SFX.play("click")


func _on_ingredient_dropped(key: String, _emoji: String, kind: String) -> void:
	if not is_running or current_order.is_empty():
		return
	if scoop_state != ScoopState.IDLE:
		message_label.text = "รอแปปนึง กำลังตักอยู่!"
		return

	match kind:
		"container":
			if not _available_container_keys().has(key):
				message_label.text = "ภาชนะนี้ยังไม่ปลดล็อกในวันนี้นะ!"
				return
			if chosen_container != "":
				message_label.text = "มีภาชนะอยู่แล้วนะ!"
				return
			chosen_container = key
			cup_flavor_contents.clear()
			cup_topping_contents.clear()
			_refresh_build_visual()
			message_label.text = "วาง%sเรียบร้อย ตักเจลาโต้ได้เลย!" % GelatoData.container_name(key)
			SFX.play("click")
		"flavor":
			if not _available_flavor_keys().has(key):
				message_label.text = "รสนี้ยังไม่ปลดล็อกในวันนี้นะ!"
				return
			if chosen_container == "":
				message_label.text = "ต้องวางภาชนะก่อนนะ!"
				return
			if cup_flavor_contents.size() >= GelatoData.container_capacity(chosen_container):
				message_label.text = "เจลาโต้เต็มแล้ว!"
				return
			_start_scoop_challenge(key)
		"topping":
			if not GameState.are_toppings_unlocked() or not GelatoData.TOPPINGS.has(key):
				message_label.text = "ท็อปปิ้งจะปลดล็อกตั้งแต่ Day 1 นะ!"
				return
			if chosen_container == "":
				message_label.text = "ต้องวางภาชนะก่อนนะ!"
				return
			if cup_flavor_contents.is_empty():
				message_label.text = "ตักเจลาโต้ก่อนสิ ค่อยใส่ท็อปปิ้งทีหลัง!"
				return
			if cup_topping_contents.size() >= MAX_TOPPING_CAPACITY:
				message_label.text = "ท็อปปิ้งเต็มแล้ว!"
				return
			cup_topping_contents.append(key)
			_refresh_build_visual()
			message_label.text = "ใส่ท็อปปิ้ง%sแล้ว" % GelatoData.topping_name(key)
			SFX.play("click")


func _start_scoop_challenge(key: String) -> void:
	scoop_pending_key = key
	scoop_state = ScoopState.CHALLENGE
	marker_t = 0.0
	marker_dir = 1
	challenge_timeout = CHALLENGE_TIME_LIMIT
	marker_speed = 1.1 + level_id * 0.12 + customers_served * 0.02
	var zone_width: float = clamp(0.32 - level_id * 0.02 - customers_served * 0.005, 0.14, 0.32)
	if GameState.upgrade_auto_churn:
		marker_speed *= 0.8
		zone_width = clamp(zone_width + 0.05, 0.14, 0.37)
	zone_start = randf() * (1.0 - zone_width)
	zone_end = zone_start + zone_width
	_show_challenge_ui()


func _show_challenge_ui() -> void:
	challenge_panel.visible = true
	build_stage.visible = false
	challenge_pending_label.text = "กำลังตัก%s" % GelatoData.flavor_name(scoop_pending_key)
	challenge_arc.set_zone(zone_start, zone_end)
	challenge_arc.set_marker(marker_t)


func _hide_challenge_ui() -> void:
	challenge_panel.visible = false
	build_stage.visible = true


func _resolve_scoop_challenge(forced_miss: bool = false) -> void:
	var hit: bool = (not forced_miss) and marker_t >= zone_start and marker_t <= zone_end
	if hit:
		cup_flavor_contents.append(scoop_pending_key)
		_refresh_build_visual()
		message_label.text = "ตักสวย!"
		SFX.play("success")
	else:
		message_label.text = "พลาดจังหวะ! ตักไม่ทัน"
		SFX.play("error")
	scoop_pending_key = ""
	scoop_state = ScoopState.COOLDOWN
	cooldown_time_left = _scoop_cooldown_duration()
	_hide_challenge_ui()


func _reset_scoop_rect(layer: TextureRect) -> void:
	layer.offset_left = RECT_FULL.position.x
	layer.offset_top = RECT_FULL.position.y
	layer.offset_right = RECT_FULL.position.x + RECT_FULL.size.x
	layer.offset_bottom = RECT_FULL.position.y + RECT_FULL.size.y


func _refresh_build_visual() -> void:
	_reset_scoop_rect(layer_scoop_mid)
	_reset_scoop_rect(layer_scoop_front)
	_reset_scoop_rect(layer_scoop_back)

	if chosen_container == "":
		layer_cup.texture = null
		layer_scoop_back.texture = null
		layer_scoop_mid.texture = null
		layer_scoop_front.texture = null
		layer_container_front.texture = null
		layer_topping.texture = null
		empty_stage_label.visible = true
		return

	empty_stage_label.visible = false
	var n := cup_flavor_contents.size()

	if chosen_container == "cone":
		layer_cup.texture = load(CONE_BACK)
		layer_container_front.texture = load(CONE_FRONT)
		layer_scoop_back.texture = null
		layer_scoop_front.texture = null
		layer_scoop_mid.texture = load(GelatoData.FLAVORS[cup_flavor_contents[0]]["cone"]) if n >= 1 else null
		layer_topping.texture = load(GelatoData.TOPPINGS[cup_topping_contents[0]]["cone"]) if not cup_topping_contents.is_empty() else null

	elif chosen_container == "small_cup":
		layer_cup.texture = load(SMALL_CUP)
		layer_container_front.texture = null
		layer_scoop_back.texture = null
		layer_scoop_front.texture = null
		layer_scoop_mid.texture = load(GelatoData.FLAVORS[cup_flavor_contents[0]]["small"]) if n >= 1 else null
		layer_topping.texture = load(GelatoData.TOPPINGS[cup_topping_contents[0]]["small"]) if not cup_topping_contents.is_empty() else null

	elif chosen_container == "large_cup":
		layer_cup.texture = load(LARGE_CUP)
		layer_container_front.texture = null
		layer_scoop_back.texture = null
		layer_scoop_front.texture = load(GelatoData.FLAVORS[cup_flavor_contents[0]]["large1"]) if n >= 1 else null
		layer_scoop_mid.texture = load(GelatoData.FLAVORS[cup_flavor_contents[1]]["large2"]) if n >= 2 else null
		layer_topping.texture = load(GelatoData.TOPPINGS[cup_topping_contents[0]]["large"]) if not cup_topping_contents.is_empty() else null


func _on_clear_cup() -> void:
	# ถ้ามีมินิเกมตัก (CHALLENGE) หรือกำลังพักมือ (COOLDOWN) ค้างอยู่ ต้องยกเลิกให้หมดก่อน
	# ไม่งั้นพอมินิเกมค้างนั้นมาผลลัพธ์ทีหลัง (ตักติด) มันจะ append รสเก่าใส่ถ้วยใหม่ที่เพิ่งวาง
	# ทำให้ถ้วยที่เพิ่งวาง (ยังไม่ได้ตักเองเลย) ดูเหมือน "เต็ม" ขึ้นมาเฉย ๆ
	if scoop_state != ScoopState.IDLE:
		scoop_state = ScoopState.IDLE
		scoop_pending_key = ""
		cooldown_time_left = 0.0
		_hide_challenge_ui()
	chosen_container = ""
	cup_flavor_contents.clear()
	cup_topping_contents.clear()
	_refresh_build_visual()


func _serve() -> void:
	var now_msec := Time.get_ticks_msec()
	if now_msec - _last_serve_msec < SERVE_DEBOUNCE_MSEC:
		return
	_last_serve_msec = now_msec

	if not is_running or current_order.is_empty():
		return
	if scoop_state == ScoopState.CHALLENGE:
		message_label.text = "ตักให้เสร็จก่อนสิ! กด SPACE ให้ตรงจังหวะ"
		return
	if chosen_container == "":
		message_label.text = "ยังไม่ได้วางภาชนะเลยนะ! ลากภาชนะมาวางก่อน"
		return

	var order_container: String = current_order["container"]
	var order_flavors: Array = current_order["flavors"]
	var order_toppings: Array = current_order["toppings"]

	var container_ok: bool = (chosen_container == order_container)

	var a: Array = order_flavors.duplicate()
	var b: Array = cup_flavor_contents.duplicate()
	a.sort()
	b.sort()
	var flavors_ok: bool = a == b

	var c: Array = order_toppings.duplicate()
	var d: Array = cup_topping_contents.duplicate()
	c.sort()
	d.sort()
	var toppings_ok: bool = c == d

	if container_ok and flavors_ok and toppings_ok:
		var order_time := patience_max - patience_time
		total_order_time += order_time
		var value_sum := GelatoData.CONTAINERS[order_container]["value"] as int
		for k in order_flavors:
			value_sum += int(GelatoData.FLAVORS[k]["value"])
		for k in order_toppings:
			value_sum += int(GelatoData.TOPPINGS[k]["value"])
		var reward := 5 + value_sum + combo * 3
		if GameState.upgrade_coin_boost:
			reward = int(round(reward * 1.1))
		coins_earned += reward
		combo += 1
		max_combo = max(max_combo, combo)
		customers_satisfied += 1
		message_label.text = "เสิร์ฟถูกใจ! +%d เหรียญ" % reward
		SFX.play("coin")
		_customer_left(true)
	elif not container_ok:
		message_label.text = "ลูกค้าอยากได้%sนะ ไม่ใช่%s!" % [GelatoData.container_name(order_container), GelatoData.container_name(chosen_container)]
		SFX.play("error")
	elif flavors_ok and not toppings_ok:
		message_label.text = "รสเจลาโต้ถูกแล้ว! แต่ท็อปปิ้งยังไม่ตรงนะ"
		SFX.play("error")
	elif toppings_ok and not flavors_ok:
		message_label.text = "ท็อปปิ้งโอเคแล้ว! แต่รสเจลาโต้ยังไม่ตรงนะ"
		SFX.play("error")
	else:
		message_label.text = "ยังไม่ตรงออเดอร์เลยนะ"
		SFX.play("error")


func _customer_left(satisfied: bool) -> void:
	if not satisfied:
		if GameState.upgrade_combo_saver and not _combo_saver_used and combo > 0:
			_combo_saver_used = true
			message_label.text = "ลูกค้าเดินหนีไปแล้ว! (ตาข่ายกันคอมโบช่วยไว้)"
		else:
			combo = 0
			message_label.text = "ลูกค้าเดินหนีไปแล้ว"
		SFX.play("error")
	customers_served += 1
	current_order = {}
	scoop_pending_key = ""
	chosen_container = ""
	cup_flavor_contents.clear()
	cup_topping_contents.clear()
	_refresh_build_visual()
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
