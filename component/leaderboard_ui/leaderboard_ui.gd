extends Panel

@onready var http := $HTTPRequest
@onready var fetch_timer := $FetchTimer
@onready var entries_container := $ScrollContainer/EntriesContainer
@onready var font := preload("res://font/Silkscreen-Regular.ttf")
@onready var side_button := $sideButton

var is_panel_open := true  # Default state

# Images for side button toggle
@onready var texture_open := preload("res://img/component_img/side_button/button_close.png")
@onready var texture_close := preload("res://img/component_img/side_button/button_open.png")

func _ready():
	add_child(http)
	http.request_completed.connect(_on_request_completed)
	fetch_timer.timeout.connect(fetch_leaderboard)
	fetch_leaderboard()

	# Setup side button texture and toggle handler
	side_button.texture_normal = texture_open
	side_button.pressed.connect(_on_side_button_pressed)

func _on_side_button_pressed():
	is_panel_open = !is_panel_open

	# Shift panel position and update button texture
	if is_panel_open:
		position.x += 170
		side_button.texture_normal = texture_open
	else:
		position.x -= 170
		side_button.texture_normal = texture_close

func fetch_leaderboard():
	var url = "https://smfydzhwujaqricxrlqi.supabase.co/rest/v1/leaderboard?limit=5&order=score.desc"
	var headers = [
		"apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtZnlkemh3dWphcXJpY3hybHFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4MDkyOTQsImV4cCI6MjA2NjM4NTI5NH0.1uY6FqPtzYha-pzIQR0BmUEo--9MtjMAG28eIvOcDig",
		"Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtZnlkemh3dWphcXJpY3hybHFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4MDkyOTQsImV4cCI6MjA2NjM4NTI5NH0.1uY6FqPtzYha-pzIQR0BmUEo--9MtjMAG28eIvOcDig"
	]

	var result = http.request(url, headers, HTTPClient.METHOD_GET)
	if result != OK:
		print("❌ Failed to start HTTP request")

func _on_request_completed(result, response_code, headers, body):
	if response_code != 200:
		print("❌ Request failed:", response_code)
		return

	var data = JSON.parse_string(body.get_string_from_utf8())
	print("📦 Fetched data from Supabase:", data)

	if typeof(data) == TYPE_ARRAY:
		for child in entries_container.get_children():
			child.queue_free()
		for entry in data:
			var label := Label.new()

			var settings := LabelSettings.new()
			settings.font = font
			settings.font_color = Color.BLACK  # 🖤 Set font color to black
			label.label_settings = settings


			var name = entry.get("gamer_name", "Unknown")
			var score = int(entry.get("score", 0))
			label.text = "%s %d" % [name, score]
			entries_container.add_child(label)
	else:
		print("⚠️ Unexpected response format")
