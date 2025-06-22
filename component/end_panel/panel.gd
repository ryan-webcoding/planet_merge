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

	var main = get_tree().current_scene

	# Reset GameManager
	GameManager.reset()

	# Remove all dynamically spawned children
	for child in main.get_children():
		var keep_names = ["sun", "dashed_circle_detector", "score"]
		if not keep_names.has(child.name):
			child.queue_free()

	# Remove and replace planet_spawner
	var old_spawner = main.get_node_or_null("planet_spawner")
	if old_spawner:
		var position = old_spawner.position
		old_spawner.free()  # <- Immediate deletion

		var spawner_scene = preload("res://component/planet_spawner/planet_spawner.tscn")
		var new_spawner = spawner_scene.instantiate()
		new_spawner.name = "planet_spawner"
		new_spawner.position = position
		main.add_child(new_spawner)
		print("Spawner added, name:", new_spawner.name)


	# Close the panel
	queue_free()
