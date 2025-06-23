extends Node2D

func _ready():
	# Start with the dashed_circle's idle animation playing
	$dashed_circle/AnimationPlayer.play("idle")

	# Hide the arrow initially
	$arrow.visible = false

func _on_drag_started():
	# Stop and reset the idle animation when user starts dragging
	$dashed_circle/AnimationPlayer.stop()
	$dashed_circle/AnimationPlayer.seek(0, true)

	# Show the arrow
	$arrow.visible = true

func _on_dragging(direction: Vector2):
	# Rotate the whole launcher (affects arrow direction)
	rotation = direction.angle()

func _on_planet_launched():
	# Resume idle animation and hide arrow again after launch
	$dashed_circle/AnimationPlayer.play("idle")
	$arrow.visible = false
