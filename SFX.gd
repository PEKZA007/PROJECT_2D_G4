extends Node

# ------------------------------------------------------------
#  SFX - Autoload: สร้างเสียงเอฟเฟกต์สั้นๆ ด้วยโค้ดล้วน (ไม่ต้องมีไฟล์เสียง)
#  เคารพ GameState.sfx_enabled จากหน้าตั้งค่า
# ------------------------------------------------------------

var _player: AudioStreamPlayer
var _cache: Dictionary = {}


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.volume_db = -6.0
	add_child(_player)


func play(kind: String) -> void:
	if not GameState.sfx_enabled:
		return
	if not _cache.has(kind):
		_cache[kind] = _generate(kind)
	_player.stream = _cache[kind]
	_player.play()


func _generate(kind: String) -> AudioStreamWAV:
	var mix_rate := 22050
	var freq := 700.0
	var duration := 0.09
	var volume := 0.35
	var rising := false

	match kind:
		"click":
			freq = 700.0
			duration = 0.06
		"success":
			freq = 900.0
			duration = 0.18
			rising = true
		"error":
			freq = 220.0
			duration = 0.15
		"coin":
			freq = 1200.0
			duration = 0.12
			rising = true
		_:
			pass

	var frame_count := maxi(int(mix_rate * duration), 1)
	var data := PackedByteArray()
	data.resize(frame_count * 2)
	for i in frame_count:
		var t := float(i) / mix_rate
		var progress := float(i) / float(maxi(frame_count - 1, 1))
		var cur_freq: float = freq * (1.0 + progress) if rising else freq
		var envelope := 1.0 - progress
		var sample := sin(TAU * cur_freq * t) * volume * envelope
		var v := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data[i * 2] = v & 0xFF
		data[i * 2 + 1] = (v >> 8) & 0xFF

	var stream := AudioStreamWAV.new()
	stream.data = data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	return stream
