extends Panel

func _ready():
	# Set text for Mercury label
	$MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/mercury_container/Label.text = "*%d" % GameManager.mercury_number
	$MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/mars_container/Label.text = "*%d" % GameManager.mars_number
	$MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/venus_container/Label.text = "*%d" % GameManager.venus_number
	$MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/earth_container/Label.text = "*%d" % GameManager.earth_number

	$MarginContainer/VBoxContainer/HBoxContainer/MarginContainer2/VBoxContainer2/neptune_container/Label.text = "*%d" % GameManager.neptune_number
	$MarginContainer/VBoxContainer/HBoxContainer/MarginContainer2/VBoxContainer2/uranus_container/Label.text = "*%d" % GameManager.uranus_number
	$MarginContainer/VBoxContainer/HBoxContainer/MarginContainer2/VBoxContainer2/saturn_container/Label.text = "*%d" % GameManager.saturn_number
	$MarginContainer/VBoxContainer/HBoxContainer/MarginContainer2/VBoxContainer2/jupiter_container/Label.text = "*%d" % GameManager.jupiter_number
	
	$MarginContainer/VBoxContainer/HBoxContainer/MarginContainer3/VBoxContainer/total_launching_time.text = "total number of times planet launched: %d" % GameManager.num_launched_planet
	$MarginContainer/VBoxContainer/HBoxContainer/MarginContainer3/VBoxContainer/total_score.text = "total score: %d" % GameManager.score
	
	$MarginContainer/VBoxContainer/HBoxContainer/MarginContainer3/VBoxContainer/Button.connect("pressed", Callable(self, "_on_restart_button_pressed"))

func _on_restart_button_pressed():
	Engine.time_scale = 1
	var current_scene = get_tree().get_current_scene()
	var new_scene = load(current_scene.scene_file_path).instantiate()
	get_tree().root.call_deferred("add_child", new_scene)
	current_scene.queue_free()
