extends Node

@onready var detector := $dashed_circle_detector
@onready var panel_scene := preload("res://component/end_panel/panel.tscn")

func _ready():
	detector.connect("gameover", Callable(self, "_on_gameover"))

func _on_gameover():
	
	# Manual delay for 1.5s using OS time
	var start_time = Time.get_ticks_msec()
	while Time.get_ticks_msec() - start_time < 1400:
		await get_tree().process_frame

	
	var panel = panel_scene.instantiate()
	var screen_size = get_viewport().get_visible_rect().size
	panel.global_position = screen_size / 2 - panel.size / 2

	add_child(panel)
