extends Control
class_name ShopEquipmentCard

# การ์ดไอเทมอุปกรณ์หนึ่งใบในร้านค้า (โครงสร้างภาพอยู่ใน ShopEquipmentCard.tscn)

signal buy_pressed(item_key: String, price: int)

const OWNED_STYLE := preload("res://theme/style_owned_button.tres")
const LOCKED_STYLE := preload("res://theme/style_locked_button.tres")
const BUY_STYLE := preload("res://theme/style_dark_button.tres")

@onready var name_label: Label = $NameLabel
@onready var desc_label: Label = $DescLabel
@onready var action_button: Button = $ActionButton

var item_key: String = ""
var item_price: int = 0


func _ready() -> void:
	action_button.pressed.connect(func(): buy_pressed.emit(item_key, item_price))


func configure(key: String, title_text: String, desc: String, price: int, state: String) -> void:
	item_key = key
	item_price = price
	name_label.text = title_text
	desc_label.text = desc

	if state == "locked":
		action_button.text = "ล็อก 🔒"
		action_button.disabled = true
		_set_button_style(LOCKED_STYLE)
		action_button.add_theme_color_override("font_disabled_color", Color8(150, 150, 150))
	elif state == "owned":
		action_button.text = "ซื้อแล้ว ✔️"
		action_button.disabled = true
		_set_button_style(OWNED_STYLE)
		action_button.add_theme_color_override("font_disabled_color", Color8(40, 90, 40))
	else:
		action_button.text = "🪙 %d" % price
		action_button.disabled = false
		_set_button_style(BUY_STYLE)
		action_button.add_theme_color_override("font_color", Color.WHITE)


func _set_button_style(style: StyleBox) -> void:
	action_button.add_theme_stylebox_override("normal", style)
	action_button.add_theme_stylebox_override("hover", style)
	action_button.add_theme_stylebox_override("pressed", style)
	action_button.add_theme_stylebox_override("disabled", style)
