extends Control
## เส้นทางของมินิเกม "ตักเจลาโต้" วาดเป็นเส้นครึ่งวงรี (โค้งเหมือนวิถีช้อนตักไอศกรีม)
## ตัวชี้ (marker) จะไล่จากซ้าย -> ผ่านจุดสูงสุดกลางโค้ง -> ขวา แทนที่จะวิ่งเป็นเส้นตรงแบบเดิม

@export var track_color: Color = Color(0.882353, 0.882353, 0.882353, 1)
@export var zone_color: Color = Color(0.470588, 0.862745, 0.54902, 1)
@export var marker_color: Color = Color(0.156863, 0.156863, 0.156863, 1)
@export var marker_ring_color: Color = Color(1, 1, 1, 0.9)
@export var track_thickness: float = 7.0
@export var zone_thickness: float = 14.0
@export var marker_radius: float = 10.0

const SEGMENTS := 48

var zone_start: float = 0.4
var zone_end: float = 0.6
var marker_t: float = 0.0


func set_zone(start_t: float, end_t: float) -> void:
	zone_start = start_t
	zone_end = end_t
	queue_redraw()


func set_marker(t: float) -> void:
	marker_t = t
	queue_redraw()


## คืนตำแหน่ง (พิกัดภายในโหนดนี้) บนเส้นครึ่งวงรี ที่ตำแหน่ง t (0 = ซ้ายสุด, 0.5 = ยอดโค้งกลาง, 1 = ขวาสุด)
func point_at(t: float) -> Vector2:
	var rx: float = size.x / 2.0
	var ry: float = size.y
	var cx: float = rx
	var cy: float = size.y
	var angle: float = PI - clamp(t, 0.0, 1.0) * PI
	return Vector2(cx + rx * cos(angle), cy - ry * sin(angle))


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return

	# เส้นราง — ครึ่งวงรีเต็มเส้น
	var track_points: PackedVector2Array = []
	for i in range(SEGMENTS + 1):
		track_points.append(point_at(float(i) / SEGMENTS))
	draw_polyline(track_points, track_color, track_thickness, true)

	# โซนเป้าหมายสีเขียว — ช่วงส่วนโค้งระหว่าง zone_start ถึง zone_end
	var span: float = clamp(zone_end - zone_start, 0.0, 1.0)
	var zone_segments: int = max(2, int(ceil(SEGMENTS * span)))
	var zone_points: PackedVector2Array = []
	for i in range(zone_segments + 1):
		var t: float = zone_start + span * (float(i) / zone_segments)
		zone_points.append(point_at(t))
	draw_polyline(zone_points, zone_color, zone_thickness, true)

	# ตัวชี้ที่วิ่งไปตามส่วนโค้ง
	var marker_pos: Vector2 = point_at(marker_t)
	draw_circle(marker_pos, marker_radius + 3.0, marker_ring_color)
	draw_circle(marker_pos, marker_radius, marker_color)
