extends Control
class_name ShopFlavorCard

# การ์ดรสชาติหนึ่งใบในแท็บ "รสชาติ" ของร้านค้า

signal unlock_pressed(flavor_key: String, price: int)

const OWNED_STYLE := preload("res://theme/style_owned_button.tres")
const BUY_STYLE := preload("res://theme/style_dark_button.tres")

@onready var icon_label: Label = $IconLabel
@onready var icon_rect: TextureRect = $IconRect
@onready var name_label: Label = $NameLabel
@onready var value_label: Label = $ValueLabel
@onready var action_button: Button = $ActionButton

var flavor_key: String = ""
var flavor_price: int = 0


func _ready() -> void:
	action_button.pressed.connect(func(): unlock_pressed.emit(flavor_key, flavor_price))


func configure(key: String, info: Dictionary, unlocked: bool) -> void:
	flavor_key = key
	if info.has("thumb"):
		icon_rect.texture = load(info["thumb"])
		icon_rect.visible = true
		icon_label.visible = false
	else:
		icon_label.text = info.get("emoji", "🍨")
		icon_rect.visible = false
		icon_label.visible = true
	name_label.text = info["name"]
	value_label.text = "มูลค่า +%d 🪙/ออเดอร์" % int(info["value"])

	if unlocked:
		action_button.text = "ปลดล็อกแล้ว ✔️"
		action_button.disabled = true
		_set_button_style(OWNED_STYLE)
		action_button.add_theme_color_override("font_disabled_color", Color8(40, 90, 40))
	else:
		flavor_price = int(info.get("unlock_price", 999))
		action_button.text = "ปลดล็อก 🪙 %d" % flavor_price
		action_button.disabled = false
		_set_button_style(BUY_STYLE)
		action_button.add_theme_color_override("font_color", Color.WHITE)


func _set_button_style(style: StyleBox) -> void:
	action_button.add_theme_stylebox_override("normal", style)
	action_button.add_theme_stylebox_override("hover", style)
	action_button.add_theme_stylebox_override("pressed", style)
	action_button.add_theme_stylebox_override("disabled", style)
