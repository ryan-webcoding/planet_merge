extends Node

@export var auth_manager: Node  # Drag AuthManager node in editor

var base_url := "https://smfydzhwujaqricxrlqi.supabase.co"
var anon_key := "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtZnlkemh3dWphcXJpY3hybHFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4MDkyOTQsImV4cCI6MjA2NjM4NTI5NH0.1uY6FqPtzYha-pzIQR0BmUEo--9MtjMAG28eIvOcDig"

func submit_score_if_higher(score: int) -> void:
	var url = base_url + "/rest/v1/rpc/update_score_if_higher"
	var body = {
		"p_gamer_name": auth_manager.email,
		"p_new_score": score
	}
	var headers = [
		"Content-Type: application/json",
		"apikey: " + anon_key,
		"Authorization: Bearer " + auth_manager.access_token
	]
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_score_submit_response)
	http.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))

func _on_score_submit_response(result: int, code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("📡 Score submit result code:", code)
	print("📦 Score submit response:", body.get_string_from_utf8())


func request_name_change(new_name: String) -> void:
	var url = base_url + "/rest/v1/rpc/change_gamer_name"
	var body = {
		"old_name": auth_manager.email,
		"new_name": new_name
	}
	var headers = [
		"Content-Type: application/json",
		"apikey: " + anon_key,
		"Authorization: Bearer " + auth_manager.access_token
	]
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_name_change_response)
	http.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))

func _on_name_change_response(result: int, code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var response := body.get_string_from_utf8()
	print("📡 Name change result code:", code)
	print("📦 Name change response:", response)

	if code == 200:
		print("✅ Name change succeeded.")
		auth_manager.email = JSON.parse_string(response)["new_name"] if JSON.parse_string(response).has("new_name") else auth_manager.email
	else:
		print("❌ Name change failed. Possibly duplicate.")


func change_player_name(new_name: String, callback: Callable) -> void:
	var url = base_url + "/rest/v1/rpc/change_gamer_name"
	var body = {
		"old_name": auth_manager.email,
		"new_name": new_name
	}
	var headers = [
		"Content-Type: application/json",
		"apikey: " + anon_key,
		"Authorization: Bearer " + auth_manager.access_token
	]

	var http := HTTPRequest.new()
	add_child(http)

	http.request_completed.connect(func(result, code, headers, body):
		var response: String = body.get_string_from_utf8()

		print("📡 Name change result code:", code)
		print("📦 Name change response:", response)

		var json = JSON.parse_string(response)

		if typeof(json) != TYPE_DICTIONARY or not json.has("status"):
			callback.call("error")
			return

		match json["status"]:
			"duplicate":
				callback.call("duplicate")
			"success":
				auth_manager.email = new_name
				callback.call("success")
			_:
				callback.call("error")
	)

	http.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
