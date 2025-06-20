extends Node

var score: int = 0

func add_score(amount: int) -> void:
	score += amount
	update_score_label()

func update_score_label() -> void:
	var main_scene = get_tree().get_current_scene()
	if main_scene:
		var label = main_scene.get_node_or_null("score")
		if label and label is Label:
			label.text = "Current Score: %d" % score
