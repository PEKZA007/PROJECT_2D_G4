extends RefCounted
class_name UIUtils

# ------------------------------------------------------------
#  ฟังก์ชันช่วยสร้าง UI แบบเดียวกันในทุกฉาก จะได้ไม่ต้องเขียนซ้ำ
# ------------------------------------------------------------

static func make_label(text: String, pos: Vector2, font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.position = pos
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	return l


static func make_panel(pos: Vector2, size: Vector2, bg: Color, radius: int = 12) -> Panel:
	var p := Panel.new()
	p.position = pos
	p.size = size
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.set_corner_radius_all(radius)
	p.add_theme_stylebox_override("panel", style)
	return p


static func make_button(text: String, pos: Vector2, size: Vector2, bg: Color, font_size: int = 20, font_color: Color = Color.BLACK) -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.size = size
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.set_corner_radius_all(12)
	b.add_theme_stylebox_override("normal", style)
	b.add_theme_stylebox_override("hover", style)
	b.add_theme_stylebox_override("pressed", style)
	b.add_theme_font_size_override("font_size", font_size)
	b.add_theme_color_override("font_color", font_color)
	return b
