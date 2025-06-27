extends Control

@export var leaderboard: Node  # drag in Leaderboard node in editor

@onready var name_input := $NameInput
@onready var save_button := $SaveButton
@onready var name_status := $NameStatus

func _ready():
	name_status.visible = false  # Start hidden

	if leaderboard == null or leaderboard.auth_manager == null:
		print("🚨 leaderboard or auth_manager not set!")
		return

	save_button.pressed.connect(_on_save_pressed)

	if leaderboard.auth_manager.email != "":
		name_input.text = leaderboard.auth_manager.email
		print("✅ Email loaded immediately:", leaderboard.auth_manager.email)
	else:
		leaderboard.auth_manager.auth_success.connect(_on_auth_ready)

func _on_auth_ready():
	name_input.text = leaderboard.auth_manager.email
	print("✅ Email loaded after auth:", leaderboard.auth_manager.email)

func _on_save_pressed():
	var new_name: String = name_input.text.strip_edges()
	if new_name == "":
		_show_status("Name cannot be empty")
		return

	for i in new_name.length():
		var code := new_name.unicode_at(i)
		if not ((code >= 65 and code <= 90) or (code >= 97 and code <= 122)):
			_show_status("Only A-Z and a-z letters allowed, no spaces or symbols")
			return
	
	leaderboard.change_player_name(new_name, _on_name_change_response)

func _on_name_change_response(response: String):
	print("🔎 Received in callback:", response)

	match response:
		"duplicate":
			_show_status("❌ Name already taken. Try another.")
		"success":
			_show_status("✅ Name updated!")
			leaderboard.auth_manager.email = name_input.text
			leaderboard.auth_manager.emit_signal("name_changed")
		_:
			_show_status("⚠️ Unknown response: %s" % response)

func _show_status(text: String):
	name_status.text = text
	name_status.visible = true
	await get_tree().create_timer(1.0).timeout
	name_status.visible = false
