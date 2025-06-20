extends "res://planets/planet_base.gd"

func _ready():
	super()  # run planet_base.gd _ready()
	connect("body_entered", Callable(self, "_on_body_entered"))


func get_planet_type() -> String:
	return "mars" # in mars.gd


func _on_body_entered(body: Node) -> void:
	if body is RigidBody2D and body.has_method("get_planet_type"):
		if body.get_planet_type() == "mars":
			# Only the instance with the lower instance ID performs the merge
			if self.get_instance_id() > body.get_instance_id():
				return

			print("Merging 2 Mars planets")

			self.queue_free()
			body.queue_free()
