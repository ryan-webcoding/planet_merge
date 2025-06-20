extends Marker2D

var planet_scenes := [
	preload("res://planets/mercury/mercury.tscn"),
	preload("res://planets/mars/mars.tscn"),
	preload("res://planets/venus/venus.tscn"),
	preload("res://planets/earth/earth.tscn"),
]

var planet_names := ["Mercury", "Mars", "Venus", "Earth"]

var current_planet: Node = null
var next_planet_scene: PackedScene = null
var timer = 0

@onready var forecast_sprite: Sprite2D = $forecast_sprite
@onready var forecast_label: Label = $forecast_label # Optional name display

func _ready() -> void:
	randomize()
	_pick_next_planet()
	spawn_new_planet()

func _pick_next_planet():
	var index = randi() % planet_scenes.size()
	next_planet_scene = planet_scenes[index]

	# Optional: update label with name
	forecast_label.text = "next planet: " + planet_names[index]

	# Temporary instance to extract sprite
	var temp_planet = next_planet_scene.instantiate()
	if temp_planet.has_node("Sprite2D"):
		var sprite = temp_planet.get_node("Sprite2D") as Sprite2D
		forecast_sprite.texture = sprite.texture
	temp_planet.queue_free()

func spawn_new_planet():
	var planet_instance = next_planet_scene.instantiate()
	planet_instance.position = position

	if planet_instance.has_signal("launched"):
		planet_instance.connect("launched", Callable(self, "_on_planet_launched"))

	get_tree().current_scene.call_deferred("add_child", planet_instance)
	current_planet = planet_instance

	_pick_next_planet()

func _on_planet_launched():
	await get_tree().create_timer(0.3).timeout
	spawn_new_planet()
	GameManager.add_score(1)
