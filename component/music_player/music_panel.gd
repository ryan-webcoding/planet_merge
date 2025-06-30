extends Node

@onready var music_player = $music_player
@onready var left_button = $left_button
@onready var mid_button = $mid_button
@onready var right_button = $right_button
@onready var animated_sprite = $AnimatedSprite2D
@onready var volume_slider = $HSlider

const MUSIC_FILES = [
	"1full.ogg",
	"2full.ogg",
	"3full.ogg",
	"4full.ogg",
	"5full.ogg",
	"6full.ogg",
	"7full.ogg",
	"8full.ogg",
	"9full.ogg",
	"10full.ogg",
	"11full.ogg",
]

const AUDIO_STREAMS = {
	"1full.ogg": preload("res://music/1full.ogg"),
	"2full.ogg": preload("res://music/2full.ogg"),
	"3full.ogg": preload("res://music/3full.ogg"),
	"4full.ogg": preload("res://music/4full.ogg"),
	"5full.ogg": preload("res://music/5full.ogg"),
	"6full.ogg": preload("res://music/6full.ogg"),
	"7full.ogg": preload("res://music/7full.ogg"),
	"8full.ogg": preload("res://music/8full.ogg"),
	"9full.ogg": preload("res://music/9full.ogg"),
	"10full.ogg": preload("res://music/10full.ogg"),
	"11full.ogg": preload("res://music/11full.ogg"),
}

const PLAY_ICON := preload("res://img/component_img/music_player/mid_button_play.png")
const PAUSE_ICON := preload("res://img/component_img/music_player/mid_button_pause.png")

var current_index = 0
var is_paused = false

var animation_schedules = {
	"1full.ogg": [
		{ "action": "play", "time": 9.4, "fps": 0.865 },
		{ "action": "restart", "time": 17.3 },
		{ "action": "play", "time": 18.8, "fps": 0.867 },
		{ "action": "restart", "time": 36.0 },
		{ "action": "play", "time": 37.6, "fps": 0.866 },
		{ "action": "restart", "time": 76.0 },
		{ "action": "play", "time": 112.4, "fps": 0.8655 },
	],
	"2full.ogg": [
		{ "action": "play", "time": 4.5, "fps": 0.912 },
		{ "action": "restart", "time": 12.9 },
		{ "action": "play", "time": 13.25, "fps": 0.9 },
		{ "action": "restart", "time": 21.2 },
		{ "action": "play", "time": 22.4, "fps": 0.9 },
	],
	"3full.ogg": [
		{ "action": "play", "time": 0.1, "fps": 1.02 },
		{ "action": "restart", "time": 14.0 },
		{ "action": "play", "time": 15.6, "fps": 0.99 },
	],
	"4full.ogg": [
		{ "action": "play", "time": 15.6, "fps": 0.978 },
	],
	"5full.ogg": [
		{ "action": "play", "time": 1.7, "fps": 1.255 },
	],
	"6full.ogg": [
		{ "action": "play", "time": 0.2, "fps": 0.65 },
		{ "action": "play", "time": 12.95, "fps": 1.22 },
	],
	"7full.ogg": [
		{ "action": "play", "time": 6.0, "fps": 1.335 },
	],
	"8full.ogg": [
		{ "action": "play", "time": 1.0, "fps": 0.97 },
	],
	"9full.ogg": [
		{ "action": "play", "time": 0.2, "fps": 0.928 },
	],
	"10full.ogg": [
		{ "action": "play", "time": 0.7, "fps": 0.7 },
		{ "action": "restart", "time": 33.0 },
		{ "action": "play", "time": 34.6, "fps": 0.69 },
		{ "action": "restart", "time": 43.3 },
		{ "action": "play", "time": 45.2, "fps": 0.7 },
	],
	"11full.ogg": [
		{ "action": "play", "time": 8.0, "fps": 1.01 },
		{ "action": "restart", "time": 25.0 },
		{ "action": "play", "time": 32.0, "fps": 1.01 },
		{ "action": "restart", "time": 56.0 },
		{ "action": "play", "time": 66.0, "fps": 1.015 },
	],
}

var schedule_timer := Timer.new()
var schedule_queue: Array = []
var schedule_index = 0

func _ready():
	add_child(schedule_timer)
	schedule_timer.one_shot = true
	schedule_timer.timeout.connect(_on_schedule_timer_timeout)

	left_button.pressed.connect(_on_left_button_pressed)
	right_button.pressed.connect(_on_right_button_pressed)
	mid_button.pressed.connect(_on_mid_button_pressed)
	music_player.finished.connect(_on_music_finished)

	volume_slider.value_changed.connect(_on_volume_slider_changed)
	_on_volume_slider_changed(volume_slider.value)

	print("✅ MUSIC FILES LOADED:", MUSIC_FILES)
	play_music(0)

func _on_volume_slider_changed(value: float):
	music_player.volume_db = lerp(-80.0, 0.0, value)

func play_music(index):
	if index < 0 or index >= MUSIC_FILES.size():
		print("Invalid music index:", index)
		return

	current_index = index
	var file_name = MUSIC_FILES[index]

	if not AUDIO_STREAMS.has(file_name):
		print("❌ Missing preload for:", file_name)
		return

	music_player.stream = AUDIO_STREAMS[file_name]
	music_player.play()
	is_paused = false
	mid_button.texture_normal = PAUSE_ICON
	print("🎵 Playing:", file_name)

	animated_sprite.stop()
	animated_sprite.frame = 0
	schedule_timer.stop()
	schedule_index = 0
	schedule_queue.clear()

	if animation_schedules.has(file_name):
		schedule_queue = animation_schedules[file_name].duplicate()
		schedule_index = 0
		_run_next_animation_step()
	else:
		print("No animation schedule found for:", file_name)

func _run_next_animation_step():
	if schedule_index >= schedule_queue.size():
		return
	var step = schedule_queue[schedule_index]
	var delay = step.time - music_player.get_playback_position()
	schedule_timer.start(max(delay, 0.0))

func _on_schedule_timer_timeout():
	if schedule_index >= schedule_queue.size():
		return
	var step = schedule_queue[schedule_index]
	match step.action:
		"play":
			animated_sprite.animation = "twerk"
			animated_sprite.speed_scale = step.fps
			animated_sprite.play()
		"restart":
			animated_sprite.stop()
			animated_sprite.frame = 0
	schedule_index += 1
	_run_next_animation_step()

func _on_left_button_pressed():
	play_music((current_index - 1 + MUSIC_FILES.size()) % MUSIC_FILES.size())

func _on_right_button_pressed():
	play_music((current_index + 1) % MUSIC_FILES.size())

func _on_mid_button_pressed():
	is_paused = !is_paused
	music_player.stream_paused = is_paused
	if is_paused:
		animated_sprite.pause()
		mid_button.texture_normal = PLAY_ICON
	else:
		animated_sprite.play()
		mid_button.texture_normal = PAUSE_ICON

func _on_music_finished():
	play_music((current_index + 1) % MUSIC_FILES.size())
