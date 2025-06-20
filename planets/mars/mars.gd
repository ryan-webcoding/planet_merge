extends "res://planets/planet_base.gd"

func _ready():
	super()  # run planet_base.gd _ready()
	connect("body_entered", Callable(self, "_on_body_entered"))



func get_planet_type() -> String:
	return "mars" # in mercury.gd


func _on_body_entered(body: Node) -> void:
	if body is RigidBody2D and body.has_method("get_planet_type"):
		if body.get_planet_type() == "mars":
			# Only the instance with the lower instance ID performs the merge
			if self.get_instance_id() > body.get_instance_id():
				return

			print("Merging 2 Mars planets")

			var midpoint = (global_position + body.global_position) / 2

			self.queue_free()
			body.queue_free()

			var venus_scene = preload("res://planets/venus/venus.tscn")
			var venus_instance = venus_scene.instantiate()
			venus_instance.position = midpoint
			
			get_tree().root.get_node("main").add_child(venus_instance)
			
			if venus_instance.has_method("disable_dragging"):
				venus_instance.disable_dragging()
			GameManager.add_score(3)
			
