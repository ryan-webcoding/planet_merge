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
@onready var forecast_label: Label = $forecast_label
@onready var planet_launcher: Node = get_parent().get_node("planet_launcher")  # 🔧 FIX HERE

func _ready():
	randomize()
	_pick_next_planet()
	spawn_new_planet()

func _pick_next_planet():
	var index = randi() % planet_scenes.size()
	next_planet_scene = planet_scenes[index]

	forecast_label.text = "next planet: " + planet_names[index]

	var temp_planet = next_planet_scene.instantiate()
	if temp_planet.has_node("Sprite2D"):
		var sprite = temp_planet.get_node("Sprite2D") as Sprite2D
		forecast_sprite.texture = sprite.texture
	temp_planet.queue_free()

func spawn_new_planet():
	var planet_instance = next_planet_scene.instantiate()
	planet_instance.position = position

	# Connect signals to self (spawner)
	planet_instance.connect("launched", Callable(self, "_on_planet_launched"))

	# Connect signals to planet_launcher (visual effect controller)
	planet_instance.connect("drag_started", Callable(planet_launcher, "_on_drag_started"))
	planet_instance.connect("dragging", Callable(planet_launcher, "_on_dragging"))
	planet_instance.connect("launched", Callable(planet_launcher, "_on_planet_launched"))

	get_tree().current_scene.call_deferred("add_child", planet_instance)
	current_planet = planet_instance

	_pick_next_planet()


func _on_planet_launched():
	await get_tree().create_timer(0.3).timeout
	spawn_new_planet()
	GameManager.add_score(1)
