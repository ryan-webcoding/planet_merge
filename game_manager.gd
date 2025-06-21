extends Node

#total score
var score: int = 0

#below are for counting planet number
var mercury_number: int = 0
var mars_number: int = 0
var venus_number: int = 0
var earth_number: int = 0
var neptune_number: int =0
var uranus_number: int =0
var saturn_number: int =0
var jupiter_number: int =0

func add_score(amount: int) -> void:
	score += amount
	update_score_label()

func update_score_label() -> void:
	var main_scene = get_tree().get_current_scene()
	if main_scene:
		var label = main_scene.get_node_or_null("score")
		if label and label is Label:
			label.text = "Current Score: %d" % score
