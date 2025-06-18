extends Marker2D

# Preload your planet scenes
var planet_scenes := [
	preload("res://planets/mercury/mercury.tscn"),
	preload("res://planets/mars/mars.tscn"),
]

var current_planet: Node = null

func _ready() -> void:
	randomize()
	spawn_new_planet()

func spawn_new_planet():
	print("Spawning new planet...")

	# Pick random planet scene
	var index = randi() % planet_scenes.size()
	var planet_scene = planet_scenes[index]
	var planet_instance = planet_scene.instantiate()

	# Position at the Marker2D location
	planet_instance.position = position

	# Connect signal
	if planet_instance.has_signal("launched"):
		planet_instance.connect("launched", Callable(self, "_on_planet_launched"))
	else:
		print("WARNING: planet does not have 'launched' signal")

	# Add to scene using deferred call to avoid timing errors
	get_tree().current_scene.call_deferred("add_child", planet_instance)

	current_planet = planet_instance
	print("Planet spawned:", planet_instance)

func _on_planet_launched():
	print("Planet launched! Spawning next...")
	await get_tree().create_timer(0.3).timeout
	spawn_new_planet()
