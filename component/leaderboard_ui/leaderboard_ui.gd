extends Control

@export var auth_manager: Node  # Drag AuthManager node in editor

@onready var http := $HTTPRequest
@onready var fetch_timer := $FetchTimer
@onready var entries_container := $leaderboard_panel/MarginContainer/ScrollContainer/EntriesContainer
@onready var font := preload("res://font/Silkscreen-Regular.ttf")
@onready var side_button := $sideButton
@onready var user_info := $userInfoContainer/MarginContainer/ScrollContainer/userInfo

var is_panel_open := true  # Default state

# Images for side button toggle
@onready var texture_open := preload("res://img/component_img/side_button/button_close.png")
@onready var texture_close := preload("res://img/component_img/side_button/button_open.png")

func _ready():
	add_child(http)
	http.request_completed.connect(_on_request_completed)
	fetch_timer.timeout.connect(fetch_leaderboard)
	fetch_timer.timeout.connect(fetch_current_user_row)
	fetch_timer.start()

	fetch_leaderboard()

	if auth_manager != null and auth_manager.access_token != "":
		fetch_current_user_row()
	elif auth_manager != null:
		auth_manager.auth_success.connect(_on_auth_ready)
	else:
		print("🚨 auth_manager not assigned!")

	if auth_manager.has_signal("auth_success"):
		auth_manager.auth_success.connect(_on_auth_ready)
	if auth_manager.has_method("connect_name_change_callback"):
		auth_manager.connect("name_changed", _on_user_name_changed)

	side_button.texture_normal = texture_open
	side_button.pressed.connect(_on_side_button_pressed)

func _on_auth_ready():
	fetch_current_user_row()

func _on_side_button_pressed():
	is_panel_open = !is_panel_open

	if is_panel_open:
		position.x += 190
		side_button.texture_normal = texture_open
	else:
		position.x -= 190
		side_button.texture_normal = texture_close

func fetch_leaderboard():
	var url = "https://smfydzhwujaqricxrlqi.supabase.co/rest/v1/leaderboard?limit=100&order=score.desc"
	var headers = [
		"apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtZnlkemh3dWphcXJpY3hybHFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4MDkyOTQsImV4cCI6MjA2NjM4NTI5NH0.1uY6FqPtzYha-pzIQR0BmUEo--9MtjMAG28eIvOcDig",
		"Authorization: Bearer " + auth_manager.access_token
	]

	var result = http.request(url, headers, HTTPClient.METHOD_GET)
	if result != OK:
		print("❌ Failed to start leaderboard request")

func _on_request_completed(result, response_code, headers, body):
	if response_code != 200:
		print("❌ Leaderboard fetch failed:", response_code)
		return

	var data = JSON.parse_string(body.get_string_from_utf8())
	if typeof(data) == TYPE_ARRAY:
		for child in entries_container.get_children():
			child.queue_free()
		for i in data.size():
			var entry = data[i]
			var label := Label.new()
			var settings := LabelSettings.new()
			settings.font = font
			settings.font_color = Color.BLACK
			label.label_settings = settings

			var name = entry.get("gamer_name", "Unknown")
			var score = int(entry.get("score", 0))
			label.text = "%d %s %d" % [i + 1, name, score]
			entries_container.add_child(label)

	else:
		print("⚠️ Unexpected leaderboard format")

func fetch_current_user_row():
	if auth_manager == null or auth_manager.email == "":
		return

	var url = "https://smfydzhwujaqricxrlqi.supabase.co/rest/v1/leaderboard?gamer_name=eq.%s" % auth_manager.email
	var headers = [
		"apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtZnlkemh3dWphcXJpY3hybHFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4MDkyOTQsImV4cCI6MjA2NjM4NTI5NH0.1uY6FqPtzYha-pzIQR0BmUEo--9MtjMAG28eIvOcDig",
		"Authorization: Bearer " + auth_manager.access_token
	]

	var http_user := HTTPRequest.new()
	add_child(http_user)
	http_user.request_completed.connect(_on_user_info_fetched)
	http_user.request(url, headers, HTTPClient.METHOD_GET)

func _on_user_info_fetched(result, code, headers, body):
	if code != 200:
		print("❌ User row fetch failed:", code)
		user_info.text = "❌ Load failed"
		return

	var data = JSON.parse_string(body.get_string_from_utf8())
	if typeof(data) == TYPE_ARRAY and data.size() > 0:
		var user = data[0]
		var name = user.get("gamer_name", "Unknown")
		var score = int(user.get("score", 0))
		user_info.text = "%s %d" % [name, score]

		var settings := LabelSettings.new()
		settings.font = font
		settings.font_color = Color.BLACK
		user_info.label_settings = settings
	else:
		user_info.text = "No data found"

func _on_user_name_changed():
	fetch_current_user_row()
