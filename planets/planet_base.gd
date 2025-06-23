extends RigidBody2D

signal launched
signal drag_started
signal dragging(direction: Vector2)  # New signal for dragging direction

@export var drag_detection_radius: float = 100

var is_dragging = false
var drag_start_position := Vector2.ZERO
var has_been_launched = false
var drag_area: Area2D

func _ready() -> void:
	gravity_scale = 0
	collision_layer = 2
	collision_mask = 0

	# Create Area2D for drag detection
	drag_area = Area2D.new()
	drag_area.name = "DragArea"
	drag_area.input_pickable = true

	var drag_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = drag_detection_radius
	drag_shape.shape = circle_shape
	drag_shape.name = "DragShape"

	drag_area.add_child(drag_shape)
	add_child(drag_area)

	drag_area.connect("input_event", Callable(self, "_on_drag_area_input_event"))

func get_planet_type() -> String:
	return "unknown"

func _on_drag_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if has_been_launched:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Emit drag_started signal when dragging starts
		is_dragging = true
		drag_start_position = event.position
		emit_signal("drag_started")  # Signal that dragging has started

func _process(delta: float) -> void:
	if has_been_launched:
		return
	
	# Emit the dragging signal when dragging is happening
	if is_dragging:
		var drag_vector = get_global_mouse_position() - drag_start_position  # Calculate current drag vector
		emit_signal("dragging", drag_vector)  # Emit dragging signal with direction

func _input(event: InputEvent) -> void:
	if has_been_launched:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if is_dragging:
			var drag_end_position = event.position
			var drag_vector = drag_end_position - drag_start_position

			var max_strength = 1000
			var clamped_vector = 7 * drag_vector.limit_length(max_strength)

			# If it's a click (short drag), apply small default impulse
			if clamped_vector.length() < 10:
				clamped_vector = Vector2(0, -50)  # small upward impulse

			apply_impulse(-clamped_vector, Vector2.ZERO)

			is_dragging = false
			has_been_launched = true
			gravity_scale = 1
			collision_layer = 1
			collision_mask = 1
			emit_signal("launched")

			if has_method("get_planet_type"):
				var type = get_planet_type()
				GameManager.increment_planet_count(type)

			GameManager.num_launched_planet += 1

func disable_dragging():
	is_dragging = false
	has_been_launched = true
	gravity_scale = 1
	collision_layer = 1
	collision_mask = 1
	set_process_input(false)
