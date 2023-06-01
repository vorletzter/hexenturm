extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var row_scene = preload("res://screens/scoreboard/row.tscn")
onready var score_box = $VBoxContainer/PanelContainer/ScrollContainer/ScoreBox

var current_page := 1
var max_page := 0


# Called when the node enters the scene tree for the first time.
func _ready():
	get_highscore()
	$VBoxContainer/HBoxContainer/Previous.disabled = true
	$VBoxContainer/HBoxContainer/Next.disabled = true
	#WebProfile._get_data(WebProfile.HIGHSCORE_URL, "_on_HTTPRequest_request_completed22")
	
func _on_Button_pressed():
	get_tree().change_scene("res://screens/StartScreen.tscn")
	
	
func get_highscore():
	$PopupDialog.popup()
	var result = yield(WebProfile.get_highscore(current_page), "completed")
	var json = JSON.parse(result[3].get_string_from_utf8())
	if json.error == OK:
		max_page = json.result["count"] / 25 # fails if < 25 results??
		#max_page = json.result["count"]
		if json.error == OK:
			var data_received = json.result
			if data_received.has('results'):
				$VBoxContainer/HBoxContainer/Previous.disabled = true
				$VBoxContainer/HBoxContainer/Next.disabled = true
				if data_received['next']:
					$VBoxContainer/HBoxContainer/Next.disabled = false
				if data_received['previous']:
					$VBoxContainer/HBoxContainer/Previous.disabled = false
				for i in data_received['results']:
					var row = row_scene.instance()
					row.setName(i['profile_name'])
					row.setScore(i['score'])
					score_box.add_child(row)
	$PopupDialog.hide()


func _on_Next_pressed() -> void:
	for n in score_box.get_children():
		score_box.remove_child(n)
		n.queue_free()
	current_page += 1
	get_highscore()


func _on_Previous_pressed() -> void:
	for n in score_box.get_children():
		score_box.remove_child(n)
		n.queue_free()
	current_page -= 1
	get_highscore()
