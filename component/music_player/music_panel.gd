extends Node

@onready var music_player = $music_player
@onready var left_button = $left_button
@onready var mid_button = $mid_button
@onready var right_button = $right_button
@onready var animated_sprite = $AnimatedSprite2D
@onready var volume_slider = $HSlider

const MUSIC_FOLDER := "res://music"
const PLAY_ICON := preload("res://img/component_img/music_player/mid_button_play.png")
const PAUSE_ICON := preload("res://img/component_img/music_player/mid_button_pause.png")

var music_files = []
var current_index = 0
var is_paused = false

var animation_schedules = {
	"1full.mp3": [
		{ "action": "play", "time": 9.4, "fps": 0.865 },
		{ "action": "restart", "time": 17.3 },
		{ "action": "play", "time": 18.8, "fps": 0.867 },
		{ "action": "restart", "time": 36.0 },
		{ "action": "play", "time": 37.6, "fps": 0.866 },
		{ "action": "restart", "time": 76.0 },
		{ "action": "play", "time": 112.4, "fps": 0.8655 },
	],
	"2full.mp3": [
		{ "action": "play", "time": 4.5, "fps": 0.912 },
		{ "action": "restart", "time": 12.9 },
		{ "action": "play", "time": 13.25, "fps": 0.9 },
		{ "action": "restart", "time": 21.2 },
		{ "action": "play", "time": 22.4, "fps": 0.9 },
	],
	"3full.mp3": [
		{ "action": "play", "time": 0.1, "fps": 1.02 },
		{ "action": "restart", "time": 14.0 },
		{ "action": "play", "time": 15.6, "fps": 0.99 },
	],
	"4full.mp3": [
		{ "action": "play", "time": 15.6, "fps": 0.978 }],
	"5full.mp3": [{ "action": "play", "time": 1.7, "fps": 1.255 }],
	"6full.mp3": [
		{ "action": "play", "time": 0.2, "fps": 0.65 },
		{ "action": "play", "time": 12.95, "fps": 1.22 },
	],
	"7full.mp3": [{ "action": "play", "time": 6.0, "fps": 1.335 }],
	"8full.mp3": [{ "action": "play", "time": 1.0, "fps": 0.97 }],
	"9full.mp3": [{ "action": "play", "time": 0.2, "fps": 0.928 }],
	"10full.mp3": [
		{ "action": "play", "time": 0.7, "fps": 0.7 },
		{ "action": "restart", "time": 33.0 },
		{ "action": "play", "time": 34.6, "fps": 0.69 },
		{ "action": "restart", "time": 43.3 },
		{ "action": "play", "time": 45.2, "fps": 0.7 }
	],
	"11full.mp3": [
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
	var dir = DirAccess.open(MUSIC_FOLDER)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension() in ["ogg", "mp3", "wav"]:
				music_files.append(MUSIC_FOLDER + "/" + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()

	music_files.sort()

	if music_files.size() > 0:
		play_music(0)

	left_button.pressed.connect(_on_left_button_pressed)
	right_button.pressed.connect(_on_right_button_pressed)
	mid_button.pressed.connect(_on_mid_button_pressed)
	music_player.finished.connect(_on_music_finished)

	add_child(schedule_timer)
	schedule_timer.one_shot = true
	schedule_timer.timeout.connect(_on_schedule_timer_timeout)

	# Connect the volume slider
	volume_slider.value_changed.connect(_on_volume_slider_changed)
	_on_volume_slider_changed(volume_slider.value)

func _on_volume_slider_changed(value: float):
	# volume_db = 0 is system volume, -80 is mute
	var db = lerp(-80.0, 0.0, value)
	music_player.volume_db = db

func play_music(index):
	if index < 0 or index >= music_files.size():
		return
	current_index = index
	var stream = load(music_files[index])
	music_player.stream = stream
	music_player.play()
	is_paused = false
	mid_button.texture_normal = PAUSE_ICON

	animated_sprite.stop()
	animated_sprite.frame = 0
	schedule_timer.stop()
	schedule_index = 0
	schedule_queue.clear()

	var file_name = music_files[index].get_file()
	if animation_schedules.has(file_name):
		schedule_queue = animation_schedules[file_name].duplicate()
		schedule_index = 0
		await get_tree().process_frame
		_run_next_animation_step()

func _run_next_animation_step():
	if schedule_index >= schedule_queue.size():
		return
	var step = schedule_queue[schedule_index]
	var delay = step.time - music_player.get_playback_position()
	delay = max(delay, 0.0)
	schedule_timer.start(delay)

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
	var new_index = (current_index - 1 + music_files.size()) % music_files.size()
	play_music(new_index)

func _on_right_button_pressed():
	var new_index = (current_index + 1) % music_files.size()
	play_music(new_index)

func _on_mid_button_pressed():
	if is_paused:
		music_player.stream_paused = false
		animated_sprite.play()
		mid_button.texture_normal = PAUSE_ICON
		is_paused = false
	else:
		music_player.stream_paused = true
		animated_sprite.pause()
		mid_button.texture_normal = PLAY_ICON
		is_paused = true

func _on_music_finished():
	var next_index = (current_index + 1) % music_files.size()
	play_music(next_index)
