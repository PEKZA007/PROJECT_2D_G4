extends Node2D

# ฉากเล่นบทสนทนา (visual novel) — โครงสร้างภาพอยู่ใน VisualNovel.tscn แล้ว
# อ่านบทจาก StoryData ตาม GameState.pending_story_chapter แล้วเล่นทีละบรรทัด
# คลิกที่ไหนก็ได้ (หรือกด Space/Enter) เพื่อไปประโยคถัดไป, "ข้าม" เพื่อข้ามทั้งตอน

@onready var left_portrait: TextureRect = $LeftPortrait
@onready var right_portrait: TextureRect = $RightPortrait
@onready var name_label: Label = $NameBox/NameLabel
@onready var dialogue_label: Label = $DialogueBox/DialogueLabel
@onready var advance_button: Button = $AdvanceButton
@onready var skip_button: Button = $SkipButton
@onready var bg_music: AudioStreamPlayer = $BGMusic

var lines: Array = []
var line_index: int = -1
var chapter_id: String = ""
var next_scene_path: String = "res://LevelSelect.tscn"


func _ready() -> void:
	chapter_id = GameState.pending_story_chapter
	next_scene_path = GameState.pending_story_next_scene
	lines = StoryData.CHAPTERS.get(chapter_id, [])

	advance_button.pressed.connect(_advance)
	skip_button.pressed.connect(_finish)

	if bg_music.stream and bg_music.stream is AudioStreamMP3:
		bg_music.stream.loop = true
	if GameState.music_enabled:
		bg_music.play()

	if lines.is_empty():
		# เลื่อนออกไปเฟรมถัดไป กัน error "busy adding/removing children" ถ้าเผลอมาถึง
		# ฉากนี้ทั้งที่ยังไม่ได้ตั้ง chapter ไว้ (ตอน tree กำลังตั้งฉากนี้อยู่พอดี)
		call_deferred("_finish")
		return
	_advance()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			_advance()


func _advance() -> void:
	line_index += 1
	if line_index >= lines.size():
		_finish()
		return
	_show_line(lines[line_index])


func _show_line(line: Dictionary) -> void:
	name_label.text = line.get("speaker", "")
	dialogue_label.text = line.get("text", "")

	var portrait_file: String = line.get("portrait", "")
	var tex = load(StoryData.portrait_path(portrait_file)) if portrait_file != "" else null
	var is_player: bool = line.get("speaker", "") == "เรา"

	if is_player:
		right_portrait.texture = tex
		right_portrait.modulate = Color(1, 1, 1, 1)
		left_portrait.modulate = Color(1, 1, 1, 0.4)
	else:
		left_portrait.texture = tex
		left_portrait.modulate = Color(1, 1, 1, 1)
		right_portrait.modulate = Color(1, 1, 1, 0.4)


func _finish() -> void:
	if chapter_id != "":
		GameState.mark_story_seen(chapter_id)
	get_tree().change_scene_to_file(next_scene_path)
