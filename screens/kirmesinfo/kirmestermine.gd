extends MarginContainer


func _ready() -> void:
	pass


func _on_Button_pressed() -> void:
	Analytics.post(Analytics.verbs.CLICKED, "_in_Termine_on_Menue_pressed")
	get_tree().change_scene("res://screens/StartScreen.tscn")
