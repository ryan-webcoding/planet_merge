extends Node

var score: int = 0

var num_launched_planet = 0
var mercury_number: int = 0
var mars_number: int = 0
var venus_number: int = 0
var earth_number: int = 0
var neptune_number: int = 0
var uranus_number: int = 0
var saturn_number: int = 0
var jupiter_number: int = 0

func add_score(amount: int) -> void:
	score += amount
	update_score_label()

func update_score_label() -> void:
	var main_scene = get_tree().get_current_scene()
	if main_scene:
		var label = main_scene.get_node_or_null("score")
		if label and label is Label:
			label.text = "Current Score: %d" % score

# ✅ Called when a planet is launched
func increment_planet_count(planet_type: String) -> void:
	match planet_type:
		"mercury":
			mercury_number += 1
			print(mercury_number)
		"mars":
			mars_number += 1
			print("mars current number" + str(mars_number))
		"venus":
			venus_number += 1
			print("venus current number" + str(venus_number))
		"earth":
			earth_number += 1
			print("earth current number"+str(earth_number))
		"neptune":
			neptune_number += 1
			print("neptune current number" + str(neptune_number))
		"uranus":
			uranus_number += 1
			print("uranus current number" + str(uranus_number))
		"saturn":
			saturn_number += 1
			print("saturn current number" + str(saturn_number))
		"jupiter":
			jupiter_number += 1
			print("jupiter current number" + str(jupiter_number))
		_:
			print("Unknown planet type: ", planet_type)
