extends Area2D

signal gameover

var is_rigidbody_inside := false
var time_inside := 0.0
var seconds_counter := 0

@onready var anim_player := $dashed_circle_sprite/AnimationPlayer

func _ready():
	set_process(true)
	anim_player.play("normal")
	anim_player.set_speed_scale(1)  # Ensure it starts playing normally

func _process(delta):
	var found := false

	for body in get_overlapping_bodies():
		if body is RigidBody2D:
			found = true
			break

	if found:
		if not is_rigidbody_inside:
			is_rigidbody_inside = true
			time_inside = 0.0
			seconds_counter = 0
			anim_player.set_speed_scale(0)  # Pause the animation
		else:
			time_inside += delta
			if time_inside >= seconds_counter + 1:
				seconds_counter += 1
				print("rigidbody found %d second" % seconds_counter)
				if seconds_counter == 1:
					emit_signal("gameover")
	else:
		if is_rigidbody_inside:
			print("rigidbody not found")
			is_rigidbody_inside = false
			time_inside = 0.0
			seconds_counter = 0
			anim_player.set_speed_scale(1)  # Resume animation from paused state
