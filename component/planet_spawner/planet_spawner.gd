extends Marker2D

var planet_scenes := [
	preload("res://planets/mercury/mercury.tscn"),
	preload("res://planets/mars/mars.tscn"),
]

var current_planet: Node = null
var timer = 0

func _ready() -> void:
	randomize()
	spawn_new_planet()

func spawn_new_planet():
	var index = randi() % planet_scenes.size()
	var planet_instance = planet_scenes[index].instantiate()
	planet_instance.position = position

	if planet_instance.has_signal("launched"):
		planet_instance.connect("launched", Callable(self, "_on_planet_launched"))

	get_tree().current_scene.call_deferred("add_child", planet_instance)
	current_planet = planet_instance

func _on_planet_launched():
	await get_tree().create_timer(1).timeout
	spawn_new_planet()
