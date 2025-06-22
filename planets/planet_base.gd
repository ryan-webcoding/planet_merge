extends RigidBody2D

signal launched

var is_dragging = false
var drag_start_position := Vector2.ZERO
var has_been_launched = false

func _ready() -> void:
	gravity_scale = 0
	collision_layer = 2
	collision_mask = 0

func get_planet_type() -> String:
	return "unknown"

func _on_input_mouseclicking(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if has_been_launched:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		is_dragging = true
		drag_start_position = event.position

func _input(event: InputEvent) -> void:
	if has_been_launched:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if is_dragging:
			var drag_end_position = event.position
			var drag_vector = drag_end_position - drag_start_position

			var max_strength = 1000
			var clamped_vector = 4 * drag_vector.limit_length(max_strength)
			apply_impulse(-clamped_vector, Vector2.ZERO)
			is_dragging = false
			has_been_launched = true
			gravity_scale = 1
			collision_layer = 1
			collision_mask = 1
			emit_signal("launched")

			# ✅ Notify GameManager about launch
			if has_method("get_planet_type"):
				var type = get_planet_type()
				GameManager.increment_planet_count(type)
			
			#increase launch_time by one
			GameManager.num_launched_planet+=1

func disable_dragging():
	is_dragging = false
	has_been_launched = true
	gravity_scale = 1
	collision_layer = 1
	collision_mask = 1
	set_process_input(false)
