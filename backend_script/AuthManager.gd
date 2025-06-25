extends Node

var email := ""
var password := ""
var access_token := ""
var base_url := "https://smfydzhwujaqricxrlqi.supabase.co"
var anon_key := "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtZnlkemh3dWphcXJpY3hybHFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4MDkyOTQsImV4cCI6MjA2NjM4NTI5NH0.1uY6FqPtzYha-pzIQR0BmUEo--9MtjMAG28eIvOcDig"  # keep as-is

signal auth_success

func _ready():
	login_or_signup()

func login_or_signup():
	var saved = load_creds()
	if saved:
		email = saved[0]
		password = saved[1]
		login()
	else:
		email = "anon_godot_%d@hotmail.com" % randi()
		password = "pass_%d" % randi()
		save_creds(email, password)
		signup()

func signup():
	var url = base_url + "/auth/v1/signup"
	var body = {
		"email": email,
		"password": password
	}
	send_request(url, body, Callable(self, "_on_auth_response").bind("signup"))

func login():
	var url = base_url + "/auth/v1/token?grant_type=password"
	var body = {
		"email": email,
		"password": password
	}
	send_request(url, body, Callable(self, "_on_auth_response").bind("login"))

func _on_auth_response(result, response_code, headers, body, source):
	var json_string = body.get_string_from_utf8()
	var data = JSON.parse_string(json_string)

	if data.has("access_token"):
		access_token = data["access_token"]
		print("Auth success from %s" % source)
		auth_success.emit()
	else:
		print("Auth failed (%s): %s" % [source, json_string])

		if source == "signup":
			login()  # try login if signup failed
		elif source == "login":
			print("Both signup and login failed. Regenerating credentials.")
			clear_creds()
			login_or_signup()  # try again with new email/password

func send_request(url: String, body: Dictionary, callback: Callable):
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(callback)
	var json = JSON.stringify(body)
	var headers = [
		"Content-Type: application/json",
		"apikey: " + anon_key
	]
	http.request(url, headers, HTTPClient.METHOD_POST, json)

func save_creds(email, password):
	var f = FileAccess.open("user://anon_user.txt", FileAccess.WRITE)
	f.store_line(email)
	f.store_line(password)
	f.close()

func load_creds():
	if FileAccess.file_exists("user://anon_user.txt"):
		var f = FileAccess.open("user://anon_user.txt", FileAccess.READ)
		return [f.get_line(), f.get_line()]
	return null

func clear_creds():
	if FileAccess.file_exists("user://anon_user.txt"):
		var dir := DirAccess.open("user://")
		dir.remove("anon_user.txt")
