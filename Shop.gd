extends Node2D

# หน้าร้านค้า: การ์ดอุปกรณ์ 3 ใบ และการ์ดรสชาติ 8 ใบ เป็น instance ที่วางไว้
# ใน Shop.tscn แล้ว (แยกเป็น 3 หน้าแท็บ สลับด้วยการซ่อน/แสดง)
# สคริปต์นี้แค่เติมข้อมูลและจัดการการซื้อ

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
const FLAVOR_ORDER := ["vanilla", "chocolate", "strawberry", "mango", "orange", "blueberry", "cherry", "mint"]
const EQUIPMENT_INFO := [
	{"key": "fast_scoop", "title": "ตักไอศกรีมไว", "desc": "ลดเวลาคูลดาวน์การตักไอศกรีมลงประมาณครึ่งหนึ่ง", "price": 120},
	{"key": "expand_counter", "title": "ขยายตู้", "desc": "ใส่วัตถุดิบในถ้วยได้เพิ่มอีก 1 ชิ้น", "price": 200},
	{"key": "auto", "title": "ปั่นออโต้", "desc": "เร็วๆ นี้", "price": -1},
]

@onready var back_button: Button = $BackButton
@onready var coin_label: Label = $CoinLabel
@onready var tab_equipment_button: Button = $Tabs/EquipmentTabButton
@onready var tab_flavors_button: Button = $Tabs/FlavorsTabButton
@onready var tab_decor_button: Button = $Tabs/DecorTabButton
@onready var equipment_page: Control = $EquipmentPage
@onready var flavors_page: Control = $FlavorsPage
@onready var decor_page: Control = $DecorPage

@onready var equipment_cards: Array = [
	$EquipmentPage/Card1, $EquipmentPage/Card2, $EquipmentPage/Card3,
]
@onready var flavor_cards: Array = [
	$FlavorsPage/Card1, $FlavorsPage/Card2, $FlavorsPage/Card3, $FlavorsPage/Card4,
	$FlavorsPage/Card5, $FlavorsPage/Card6, $FlavorsPage/Card7, $FlavorsPage/Card8,
]


func _ready() -> void:
	back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://LevelSelect.tscn"))
	tab_equipment_button.pressed.connect(func(): _switch_tab("equipment"))
	tab_flavors_button.pressed.connect(func(): _switch_tab("flavors"))
	tab_decor_button.pressed.connect(func(): _switch_tab("decor"))

	for c in equipment_cards:
		c.buy_pressed.connect(_on_buy_equipment)
	for c in flavor_cards:
		c.unlock_pressed.connect(_on_unlock_flavor)

	_refresh_all()
	_switch_tab("equipment")


func _switch_tab(tab: String) -> void:
	equipment_page.visible = (tab == "equipment")
	flavors_page.visible = (tab == "flavors")
	decor_page.visible = (tab == "decor")


func _refresh_all() -> void:
	coin_label.text = "🪙 %d" % GameState.coins

	for i in equipment_cards.size():
		var info: Dictionary = EQUIPMENT_INFO[i]
		var state := "buy"
		if info["key"] == "auto":
			state = "locked"
		elif info["key"] == "fast_scoop" and GameState.upgrade_fast_scoop:
			state = "owned"
		elif info["key"] == "expand_counter" and GameState.upgrade_expand_counter:
			state = "owned"
		equipment_cards[i].configure(info["key"], info["title"], info["desc"], info["price"], state)

	for i in flavor_cards.size():
		var key: String = FLAVOR_ORDER[i]
		flavor_cards[i].configure(key, FLAVOR_INFO[key], GameState.is_flavor_unlocked(key))


func _on_buy_equipment(key: String, price: int) -> void:
	if GameState.coins < price:
		return
	GameState.coins -= price
	if key == "fast_scoop":
		GameState.upgrade_fast_scoop = true
	elif key == "expand_counter":
		GameState.upgrade_expand_counter = true
	_refresh_all()


func _on_unlock_flavor(key: String, price: int) -> void:
	if GameState.coins < price:
		return
	GameState.coins -= price
	GameState.unlock_flavor(key)
	_refresh_all()
