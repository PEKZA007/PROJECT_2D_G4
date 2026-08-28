extends Node2D

# หน้าร้านค้า: การ์ดอุปกรณ์ 3 ใบ และการ์ดตกแต่งร้าน 4 ใบ เป็น instance ที่วางไว้
# ใน Shop.tscn แล้ว (แยกเป็น 2 หน้าแท็บ สลับด้วยการซ่อน/แสดง)
# ระบบซื้อ/ปลดล็อกรสชาติถูกตัดออกแล้ว — ตอนนี้ทุกรสชาติเล่นได้ตั้งแต่แรก
# สคริปต์นี้แค่เติมข้อมูลและจัดการการซื้อ

const EQUIPMENT_INFO := [
	{"key": "fast_scoop", "icon": "ไว", "title": "ตักเจลาโต้ไว", "desc": "ลดเวลาคูลดาวน์การตักเจลาโต้ลงประมาณครึ่งหนึ่ง", "price": 120},
	{"key": "expand_counter", "icon": "ใหญ่", "title": "ปลดล็อกถ้วยใหญ่ก่อนใคร", "desc": "เจอออเดอร์ถ้วยใหญ่ (3 รส) ได้ ตั้งแต่ด่านต้นๆ", "price": 200},
	{"key": "auto", "icon": "ออโต้", "title": "ปั่นออโต้", "desc": "มินิเกมตักเจลาโต้ง่ายขึ้น: ตัวชี้เดินช้าลงและโซนตักกว้างขึ้น", "price": 160},
]

const TAB_STYLE_INACTIVE := preload("res://theme/style_tab_button.tres")
const TAB_STYLE_ACTIVE := preload("res://theme/style_tab_button_active.tres")
const TAB_COLOR_INACTIVE := Color(0.235294, 0.156863, 0.0784314, 1)
const TAB_COLOR_ACTIVE := Color(1, 1, 1, 1)

@onready var back_button: Button = $BackButton
@onready var coin_label: Label = $CoinLabel
@onready var tab_equipment_button: Button = $Tabs/EquipmentTabButton
@onready var tab_decor_button: Button = $Tabs/DecorTabButton
@onready var equipment_page: Control = $EquipmentPage
@onready var decor_page: Control = $DecorPage

@onready var equipment_cards: Array = [
	$EquipmentPage/Card1, $EquipmentPage/Card2, $EquipmentPage/Card3,
]
@onready var decor_cards: Array = [
	$DecorPage/Card1, $DecorPage/Card2, $DecorPage/Card3, $DecorPage/Card4,
]
@onready var tab_buttons: Dictionary = {
	"equipment": tab_equipment_button,
	"decor": tab_decor_button,
}


func _ready() -> void:
	get_tree().paused = false
	back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://LevelSelect.tscn"))
	tab_equipment_button.pressed.connect(func(): _switch_tab("equipment"))
	tab_decor_button.pressed.connect(func(): _switch_tab("decor"))

	for c in equipment_cards:
		c.buy_pressed.connect(_on_buy_equipment)
	for c in decor_cards:
		c.buy_pressed.connect(_on_buy_decor)
		c.equip_pressed.connect(_on_equip_decor)

	_refresh_all()
	_switch_tab("equipment")


func _switch_tab(tab: String) -> void:
	equipment_page.visible = (tab == "equipment")
	decor_page.visible = (tab == "decor")

	for key in tab_buttons.keys():
		var btn: Button = tab_buttons[key]
		var active: bool = (key == tab)
		var style: StyleBox = TAB_STYLE_ACTIVE if active else TAB_STYLE_INACTIVE
		var color: Color = TAB_COLOR_ACTIVE if active else TAB_COLOR_INACTIVE
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
		btn.add_theme_color_override("font_color", color)
		btn.add_theme_color_override("font_hover_color", color)
		btn.add_theme_color_override("font_pressed_color", color)


func _refresh_all() -> void:
	coin_label.text = "%d เหรียญ" % GameState.coins

	for i in equipment_cards.size():
		var info: Dictionary = EQUIPMENT_INFO[i]
		var state := "buy"
		if info["key"] == "fast_scoop" and GameState.upgrade_fast_scoop:
			state = "owned"
		elif info["key"] == "expand_counter" and GameState.upgrade_expand_counter:
			state = "owned"
		elif info["key"] == "auto" and GameState.upgrade_auto_churn:
			state = "owned"
		equipment_cards[i].configure(info["key"], info["title"], info["desc"], info["price"], state, info["icon"])

	for i in decor_cards.size():
		var key: String = DecorData.THEME_ORDER[i]
		var info: Dictionary = DecorData.THEMES[key]
		var owned: bool = GameState.owned_decor.get(key, false)
		var equipped: bool = GameState.equipped_decor == key
		decor_cards[i].configure(key, info, owned, equipped)


func _on_buy_equipment(key: String, price: int) -> void:
	if not GameState.buy_equipment(key, price):
		SFX.play("error")
		return
	SFX.play("coin")
	_refresh_all()


func _on_buy_decor(key: String, price: int) -> void:
	if not GameState.buy_decor(key, price):
		SFX.play("error")
		return
	SFX.play("coin")
	_refresh_all()


func _on_equip_decor(key: String) -> void:
	GameState.equip_decor(key)
	SFX.play("click")
	_refresh_all()
