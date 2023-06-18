extends CanvasLayer

var row_scene = preload("res://screens/scoreboard/row.tscn")
onready var score_box = $VBoxContainer/PanelContainer/TabContainer/Weltweit/ScoreBox
onready var player_score_box = $"VBoxContainer/PanelContainer/TabContainer/Deine Punkte/ScoreBox"


onready var bar_weltweit: VScrollBar = $VBoxContainer/PanelContainer/TabContainer/Weltweit.get_v_scrollbar()
var highscore_has_more_pages = true
var highscore_page := 1

onready var bar_player: VScrollBar = $"VBoxContainer/PanelContainer/TabContainer/Deine Punkte".get_v_scrollbar()
var player_has_more_pages = true
var player_page := 1

# Called when the node enters the scene tree for the first time.
func _ready():
	get_highscore()
	get_player_score()
	
	bar_weltweit.connect("changed", self, "_weltweit_changed")
	bar_player.connect("changed", self, "_player_changed")
	#WebProfile._get_data(WebProfile.HIGHSCORE_URL, "_on_HTTPRequest_request_completed22")
	
func _player_changed() -> void:
	if player_has_more_pages:
		yield(get_tree(), "idle_frame")
		var percent_scrolled = 0
		if bar_player.value != 0:
			percent_scrolled = (bar_player.value + bar_player.get_page()) / bar_player.max_value

		if percent_scrolled > 0.8:
			player_page += 1
			get_player_score()
			
func _weltweit_changed() -> void:
	if highscore_has_more_pages:
		yield(get_tree(), "idle_frame")
		var percent_scrolled = 0
		if bar_weltweit.value != 0:
			percent_scrolled = (bar_weltweit.value + bar_weltweit.get_page()) / bar_weltweit.max_value

		if percent_scrolled > 0.8:
			highscore_page += 1
			get_highscore()
	
func _on_Button_pressed():
	get_tree().change_scene("res://screens/StartScreen.tscn")
	
func get_player_score():
	$PopupDialog.popup()
	player_has_more_pages = false
	var result = yield(WebProfile.get_player_scores(player_page), "completed")
	var json = JSON.parse(result[3].get_string_from_utf8())
	if json.error == OK:
		#max_page = json.result["count"] / 25 # fails if < 25 results??
		#max_page = json.result["count"]
		if json.error == OK:
			var data_received = json.result
			if data_received.has('results'):
				if data_received['next']:
					player_has_more_pages = true
				for i in data_received['results']:
					var row = row_scene.instance()
					row.setName(WebProfile.PROFILE_NAME)
					row.setScore(i['score'])
					player_score_box.add_child(row)
	$PopupDialog.hide()
	
func get_highscore():
	highscore_has_more_pages = false
	$PopupDialog.popup()
	var result = yield(WebProfile.get_highscore(highscore_page), "completed")
	var json = JSON.parse(result[3].get_string_from_utf8())
	if json.error == OK:
		if json.error == OK:
			var data_received = json.result
			if data_received.has('results'):
				if data_received['next']:
					highscore_has_more_pages = true
				for i in data_received['results']:
					var row = row_scene.instance()
					row.setName(i['profile_name'])
					row.setScore(i['score'])
					score_box.add_child(row)
	$PopupDialog.hide()
