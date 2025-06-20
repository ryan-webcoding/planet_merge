extends RigidBody2D

signal launched

var is_dragging = false
var drag_start_position := Vector2.ZERO
var has_been_launched = false


func _ready() -> void:
	gravity_scale = 0

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
			apply_impulse(-drag_vector, Vector2.ZERO)
			emit_signal("launched")
			is_dragging = false
			has_been_launched = true
			gravity_scale = 1


func disable_dragging():
	is_dragging = false
	has_been_launched = true
	gravity_scale = 1
	print(gravity_scale)
	set_process_input(false)
