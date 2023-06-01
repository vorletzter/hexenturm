extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#ToDo: Upload stat
	# Debuging Viewport Issues...
	#$VBoxContainer/Label3.text = str(get_viewport().size.x) + " - " + str(get_viewport().size.y)
	if Global.first_start:
		Global.first_start = false
		$FristTimeDialog.popup()

func _on_Start_pressed():
	Analytics.post(Analytics.verbs.CLICKED, "_on_Start_pressed")
	get_tree().change_scene("res://Hexenturm.tscn")
	pass # Replace with function body.


func _on_Highscore_pressed():
	Analytics.post(Analytics.verbs.CLICKED, "_on_Highscore_pressed")
	get_tree().change_scene("res://screens/scoreboard/Scoreboard.tscn")
	pass # Replace with function body.


func _on_Hilfe_pressed():
	Analytics.post(Analytics.verbs.CLICKED, "_on_Hilfe_pressed")
	$HelpDialog.popup()
	pass # Replace with function body.


func _on_Datenschutz_pressed():
	Analytics.post(Analytics.verbs.CLICKED, "_on_Datenschutz_pressed")
	$DatenschutzDialog.popup()
	pass # Replace with function body.


func _on_Again_pressed():
	Analytics.post(Analytics.verbs.CLICKED, "_on_Again_pressed")
	get_tree().change_scene("res://Hexenturm.tscn")
	pass # Replace with function body.


func _on_Upload_pressed():
	Analytics.post(Analytics.verbs.CLICKED, "_on_Upload_pressed")
	upload_score()

# Called when the HTTP request is completed.
func _http_request_completed_for_get_highscore(_result, _response_code, _headers, _body):
	print ("Score uploaded successfully")
	$UploadDialog.visible = false

func _on_Einstellungen_pressed():
	Analytics.post(Analytics.verbs.CLICKED, "_on_Einstellungen_pressed")
	$SettingsDialog.popup()
		
func upload_score():
	$UploadDialog.popup()
	var http_request = HTTPRequest.new()
	var HEADERS = ["Content-Type: application/json"]
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed_for_get_highscore")
	var body = to_json({"player_name": Global.player_name, "score": Global.score, "stages": Global.platforms_climbed})
	print ("Uploading Score: "+ str(body))
	var error = http_request.request("https://hexenturm.kircheone.de/score/", HEADERS, true, HTTPClient.METHOD_POST, body)
	#var error = http_request.request(HTTPClient.METHOD_POST, "https://hexenturm.kircheone.de/score/", HEADERS, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _on_Quit_pressed() -> void:
	Analytics.post(Analytics.verbs.CLICKED, "_on_Quit_pressed")
	get_tree().quit()

func _on_Kirmesteam_pressed() -> void:
	Analytics.post(Analytics.verbs.CLICKED, "_on_Kirmesteam_pressed")
	get_tree().change_scene("res://screens/kirmesinfo/Kirmesburschen.tscn")
	pass # Replace with function body.


func _on_Termine_pressed() -> void:
	Analytics.post(Analytics.verbs.CLICKED, "_on_Termine_pressed")
	get_tree().change_scene("res://screens/kirmesinfo/kirmestermine.tscn")
	pass # Replace with function body.
