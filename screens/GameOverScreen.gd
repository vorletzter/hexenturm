extends ColorRect

onready var score = $MarginContainer/VBoxContainer/Punkte/HBoxContainer/Label
onready var ebenen = $MarginContainer/VBoxContainer/Punkte/HBoxContainer2/Label

func _ready() -> void:
	score.text = str(Achievements.highscore)
	ebenen.text = str(Achievements.platforms_climbed)
	$MarginContainer/VBoxContainer/VBoxContainer2/Coins/Label2.text = str(Achievements.item_stats["coin"])
	$MarginContainer/VBoxContainer/VBoxContainer2/Herzen/Label2.text = str(Achievements.item_stats["heart"])
	$MarginContainer/VBoxContainer/VBoxContainer2/JumpBoost/Label2.text = str(Achievements.item_stats["jump_boost"])
	$MarginContainer/VBoxContainer/VBoxContainer2/CoinRain/Label2.text = str(Achievements.item_stats["coin_rain"])
	var text = "( " +  str(Achievements.item_stats["falling_coin"]) + " )"
	$MarginContainer/VBoxContainer/VBoxContainer2/CoinRain/Label3.text = text
	#$HighscoreDialog/VBoxContainer/VBoxContainer2/SessionHS.text = str(Achievements.score)
	WebProfile.submit_score(Achievements.score, Achievements.platforms_climbed, Achievements.item_stats)
	#score.text = Profile.score


func _on_Again_pressed() -> void:
	Analytics.post(Analytics.verbs.CLICKED, "_on_Highscore_Again_pressed")
	get_tree().change_scene("res://Hexenturm.tscn")
	pass # Replace with function body.


func _on_StartScreen_pressed() -> void:
	Analytics.post(Analytics.verbs.CLICKED, "_on_Highscore_StartScreen_pressed")
	get_tree().change_scene("res://screens/StartScreen.tscn")
	pass # Replace with function body.
