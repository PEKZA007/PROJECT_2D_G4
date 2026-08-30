extends Control
class_name SkinCard

# การ์ดสกินหนึ่งใบ ในแท็บ "สกิน" ของร้านค้า
# มี 3 สถานะ: ยังไม่ปลดล็อก (ซื้อ) / ปลดล็อกแล้วแต่ยังไม่ได้ใช้ (สวมใส่) / กำลังใช้งานอยู่

signal buy_pressed(skin_key: String, price: int)
signal equip_pressed(skin_key: String)

const OWNED_STYLE := preload("res://theme/style_owned_button.tres")
const LOCKED_STYLE := preload("res://theme/style_locked_button.tres")
const BUY_STYLE := preload("res://theme/style_dark_button.tres")

@onready var swatch_counter: TextureRect = $SwatchCounter
@onready var swatch_cursor: TextureRect = $CursorBadge/SwatchCursor
@onready var name_label: Label = $NameLabel
@onready var desc_label: Label = $DescLabel
@onready var action_button: Button = $ActionButton

var skin_key: String = ""
var skin_price: int = 0
var _owned: bool = false
var _equipped: bool = false


func _ready() -> void:
	action_button.pressed.connect(_on_pressed)


func configure(key: String, info: Dictionary, owned: bool, equipped: bool) -> void:
	skin_key = key
	skin_price = int(info.get("price", 0))
	_owned = owned
	_equipped = equipped

	swatch_counter.texture = load(info["counter_thumb"])
	swatch_cursor.texture = load(info["cursor_texture"])
	name_label.text = info["name"]
	desc_label.text = info["desc"]

	if equipped:
		action_button.text = "ใช้งานอยู่"
		action_button.disabled = true
		_set_button_style(OWNED_STYLE)
		action_button.add_theme_color_override("font_disabled_color", Color8(40, 90, 40))
	elif owned:
		action_button.text = "ใช้สกินนี้"
		action_button.disabled = false
		_set_button_style(LOCKED_STYLE)
		action_button.add_theme_color_override("font_color", Color(0.105882, 0.294118, 0.615686, 1))
		action_button.add_theme_color_override("font_hover_color", Color(0.105882, 0.294118, 0.615686, 1))
		action_button.add_theme_color_override("font_pressed_color", Color(0.105882, 0.294118, 0.615686, 1))
	else:
		action_button.text = "%d เหรียญ" % skin_price
		action_button.disabled = false
		_set_button_style(BUY_STYLE)
		action_button.add_theme_color_override("font_color", Color.WHITE)
		action_button.add_theme_color_override("font_hover_color", Color.WHITE)
		action_button.add_theme_color_override("font_pressed_color", Color.WHITE)


func _on_pressed() -> void:
	if _equipped:
		return
	if _owned:
		equip_pressed.emit(skin_key)
	else:
		buy_pressed.emit(skin_key, skin_price)


func _set_button_style(style: StyleBox) -> void:
	action_button.add_theme_stylebox_override("normal", style)
	action_button.add_theme_stylebox_override("hover", style)
	action_button.add_theme_stylebox_override("pressed", style)
	action_button.add_theme_stylebox_override("disabled", style)
