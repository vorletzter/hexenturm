extends WindowDialog

func _on_FristTimeDialog_about_to_show() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
			
	#$VBoxContainer/NameContainer/PlayerName.text = WebProfile.PROFILE_NAME
	$VBoxContainer/PlayerName.text = "Kirmesfan_"+str(rng.randi_range(1000,9000))
	$VBoxContainer/PlayerName.grab_focus()

func _on_SaveFTSettingsButton_pressed() -> void:
	Analytics.post(Analytics.verbs.CLICKED, "_on_SaveFTSettingsButton_pressed")
	WebProfile.set_name($VBoxContainer/PlayerName.text)
	Global.save_settings_to_disk()
	hide()
