extends Area2D

signal gameover

var is_rigidbody_inside := false
var time_inside := 0.0
var seconds_counter := 0
var detected_position := Vector2.ZERO

@onready var anim_player := $dashed_circle_sprite/AnimationPlayer
@onready var red_cross_scene := preload("res://component/red_cross/red_cross_sprite.tscn")

func _ready():
	set_process(true)
	anim_player.play("normal")
	anim_player.set_speed_scale(1)

func _process(delta):
	var found := false

	for body in get_overlapping_bodies():
		if body is RigidBody2D:
			found = true
			detected_position = body.global_position
			break

	if found:
		if not is_rigidbody_inside:
			is_rigidbody_inside = true
			time_inside = 0.0
			seconds_counter = 0
			anim_player.set_speed_scale(0)
		else:
			time_inside += delta
			if time_inside >= seconds_counter + 1:
				seconds_counter += 1
				print("rigidbody found %d second" % seconds_counter)
				if seconds_counter == 1:
					emit_signal("gameover")

					var red_cross = red_cross_scene.instantiate()
					red_cross.global_position = detected_position
					get_tree().current_scene.add_child(red_cross)

					Engine.time_scale = 0
	else:
		if is_rigidbody_inside:
			print("rigidbody not found")
			is_rigidbody_inside = false
			time_inside = 0.0
			seconds_counter = 0
			anim_player.set_speed_scale(1)
