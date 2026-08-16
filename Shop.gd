extends Node2D

# หน้าร้านค้า: ใช้เหรียญซื้ออัปเกรด (อุปกรณ์) และปลดล็อกรสชาติใหม่

const FLAVOR_INFO := {
	"vanilla": {"emoji": "🍦", "name": "วานิลลา", "value": 6},
	"chocolate": {"emoji": "🍫", "name": "ช็อกโกแลต", "value": 8},
	"strawberry": {"emoji": "🍓", "name": "สตรอเบอร์รี่", "value": 8},
	"mango": {"emoji": "🥭", "name": "มะม่วง", "value": 10},
	"orange": {"emoji": "🍊", "name": "ส้ม", "value": 12, "unlock_price": 80},
	"blueberry": {"emoji": "🫐", "name": "บลูเบอร์รี่", "value": 14, "unlock_price": 110},
	"cherry": {"emoji": "🍒", "name": "เชอร์รี่", "value": 16, "unlock_price": 140},
	"mint": {"emoji": "🌿", "name": "มินต์", "value": 18, "unlock_price": 170},
}

var coin_label: Label
var items_container: Control
var current_tab: String = "equipment"


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color8(250, 250, 245)
	bg.size = Vector2(960, 640)
	add_child(bg)

	var back_btn := UIUtils.make_button("←", Vector2(20, 20), Vector2(50, 50), Color8(230, 230, 230), 24)
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://LevelSelect.tscn"))
	add_child(back_btn)

	var title := UIUtils.make_label("ร้านค้า", Vector2(0, 25), 34, Color8(60, 40, 20))
	title.size = Vector2(960, 50)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)

	coin_label = UIUtils.make_label("", Vector2(800, 30), 22, Color8(180, 120, 0))
	add_child(coin_label)

	var tabs := HBoxContainer.new()
	tabs.position = Vector2(30, 90)
	tabs.add_theme_constant_override("separation", 10)
	add_child(tabs)

	var tab_defs := [
		{"key": "equipment", "label": "อุปกรณ์"},
		{"key": "flavors", "label": "รสชาติ"},
		{"key": "decor", "label": "ตกแต่งร้าน"},
	]
	for tab_def in tab_defs:
		var t := UIUtils.make_button(tab_def["label"], Vector2.ZERO, Vector2(130, 36), Color8(235, 235, 235), 16)
		t.pressed.connect(_switch_tab.bind(tab_def["key"]))
		tabs.add_child(t)

	items_container = Control.new()
	items_container.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(items_container)

	_render_tab()


func _switch_tab(tab: String) -> void:
	current_tab = tab
	_render_tab()


func _render_tab() -> void:
	for c in items_container.get_children():
		items_container.remove_child(c)
		c.free()

	coin_label.text = "🪙 %d" % GameState.coins

	if current_tab == "equipment":
		_render_equipment()
	elif current_tab == "flavors":
		_render_flavors()
	else:
		var soon := UIUtils.make_label("เร็วๆ นี้", Vector2(0, 260), 24, Color8(150, 150, 150))
		soon.size = Vector2(960, 40)
		soon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		items_container.add_child(soon)


func _render_equipment() -> void:
	_build_equipment_item(Vector2(40, 160), "ตักไอศกรีมไว", "ลดเวลาคูลดาวน์การตักไอศกรีมลงประมาณครึ่งหนึ่ง", 120, "fast_scoop")
	_build_equipment_item(Vector2(370, 160), "ขยายตู้", "ใส่วัตถุดิบในถ้วยได้เพิ่มอีก 1 ชิ้น", 200, "expand_counter")
	_build_equipment_item(Vector2(700, 160), "ปั่นออโต้", "เร็วๆ นี้", -1, "auto")


func _build_equipment_item(pos: Vector2, title_text: String, desc: String, price: int, key: String) -> void:
	items_container.add_child(UIUtils.make_panel(pos, Vector2(230, 340), Color8(240, 240, 236), 16))
	items_container.add_child(UIUtils.make_panel(pos + Vector2(65, 20), Vector2(100, 100), Color8(35, 35, 35), 10))

	var name_label := UIUtils.make_label(title_text, pos + Vector2(0, 140), 20, Color8(50, 50, 50))
	name_label.size = Vector2(230, 30)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	items_container.add_child(name_label)

	var desc_label := UIUtils.make_label(desc, pos + Vector2(15, 178), 14, Color8(110, 110, 110))
	desc_label.size = Vector2(200, 55)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	items_container.add_child(desc_label)

	var owned := (key == "fast_scoop" and GameState.upgrade_fast_scoop) \
		or (key == "expand_counter" and GameState.upgrade_expand_counter)

	if key == "auto":
		var lock_btn := UIUtils.make_button("ล็อก 🔒", pos + Vector2(15, 260), Vector2(200, 45), Color8(220, 220, 220), 18)
		lock_btn.disabled = true
		items_container.add_child(lock_btn)
	elif owned:
		var owned_btn := UIUtils.make_button("ซื้อแล้ว ✔️", pos + Vector2(15, 260), Vector2(200, 45), Color8(200, 230, 200), 18)
		owned_btn.disabled = true
		items_container.add_child(owned_btn)
	else:
		var buy_btn := UIUtils.make_button("🪙 %d" % price, pos + Vector2(15, 260), Vector2(200, 45), Color8(40, 40, 40), 18, Color.WHITE)
		buy_btn.pressed.connect(_on_buy_equipment.bind(key, price))
		items_container.add_child(buy_btn)


func _on_buy_equipment(key: String, price: int) -> void:
	if GameState.coins < price:
		return
	GameState.coins -= price
	if key == "fast_scoop":
		GameState.upgrade_fast_scoop = true
	elif key == "expand_counter":
		GameState.upgrade_expand_counter = true
	_render_tab()


func _render_flavors() -> void:
	var keys: Array = FLAVOR_INFO.keys()
	for i in keys.size():
		var key: String = keys[i]
		var info: Dictionary = FLAVOR_INFO[key]
		var col: int = i % 4
		var row: int = i / 4
		var x := 35 + col * 225
		var y := 160 + row * 210
		_build_flavor_card(Vector2(x, y), key, info)


func _build_flavor_card(pos: Vector2, key: String, info: Dictionary) -> void:
	items_container.add_child(UIUtils.make_panel(pos, Vector2(210, 195), Color8(240, 240, 236), 16))
	items_container.add_child(UIUtils.make_panel(pos + Vector2(70, 15), Vector2(70, 70), Color8(255, 255, 255), 35))

	var icon_label := UIUtils.make_label(info["emoji"], pos + Vector2(70, 15), 34, Color8(0, 0, 0))
	icon_label.size = Vector2(70, 70)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	items_container.add_child(icon_label)

	var name_label := UIUtils.make_label(info["name"], pos + Vector2(0, 95), 18, Color8(50, 50, 50))
	name_label.size = Vector2(210, 26)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	items_container.add_child(name_label)

	var value_label := UIUtils.make_label("มูลค่า +%d 🪙/ออเดอร์" % int(info["value"]), pos + Vector2(0, 122), 13, Color8(120, 120, 120))
	value_label.size = Vector2(210, 20)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	items_container.add_child(value_label)

	var unlocked := GameState.is_flavor_unlocked(key)
	if unlocked:
		var owned_btn := UIUtils.make_button("ปลดล็อกแล้ว ✔️", pos + Vector2(15, 150), Vector2(180, 35), Color8(200, 230, 200), 14)
		owned_btn.disabled = true
		items_container.add_child(owned_btn)
	else:
		var price: int = int(info.get("unlock_price", 999))
		var buy_btn := UIUtils.make_button("ปลดล็อก 🪙 %d" % price, pos + Vector2(15, 150), Vector2(180, 35), Color8(40, 40, 40), 14, Color.WHITE)
		buy_btn.pressed.connect(_on_unlock_flavor.bind(key, price))
		items_container.add_child(buy_btn)


func _on_unlock_flavor(key: String, price: int) -> void:
	if GameState.coins < price:
		return
	GameState.coins -= price
	GameState.unlock_flavor(key)
	_render_tab()
