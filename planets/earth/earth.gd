extends "res://planets/planet_base.gd"

func _ready():
	super()  # run planet_base.gd _ready()
	connect("body_entered", Callable(self, "_on_body_entered"))



func get_planet_type() -> String:
	return "earth" # in mercury.gd


func _on_body_entered(body: Node) -> void:
	if body is RigidBody2D and body.has_method("get_planet_type"):
		if body.get_planet_type() == "earth":
			# Only the instance with the lower instance ID performs the merge
			if self.get_instance_id() > body.get_instance_id():
				return

			print("Merging 2 Earth planets")

			var midpoint = (global_position + body.global_position) / 2

			self.queue_free()
			body.queue_free()

			var neptune_scene = preload("res://planets/neptune/neptune.tscn")
			var neptune_instance = neptune_scene.instantiate()
			neptune_instance.position = midpoint
			
			get_tree().root.get_node("main").add_child(neptune_instance)
			
			if neptune_instance.has_method("disable_dragging"):
				neptune_instance.disable_dragging()
			GameManager.add_score(5)
			
