extends WindowDialog

func _on_SettingsDialog_about_to_show():
	$VBoxContainer/NameContainer/PlayerName.text = WebProfile.PROFILE_NAME
	#$VBoxContainer/VBoxContainer/SendAnalytics.pressed = WebProfile.analytics_enabled
	$VBoxContainer/UploadScoreContainer/UploadScore.pressed = WebProfile.upload_score_enabled
	$VBoxContainer/HBoxContainer/UUID.text = WebProfile.PROFILE_UUID
	if !WebProfile.PROFILE_IS_VALID:
		$ProfileError.popup()
	#$CommunicationError.visible = !WebProfile.PROFILE_IS_VALID
	call_deferred("$../FristTimeDialog/VBoxContainer/PlayerName.grab_focus()")
	$VBoxContainer/NameContainer/PlayerName.grab_focus()

func _on_UploadScore_toggled(button_pressed: bool) -> void:
	WebProfile.set_upload_score(button_pressed)
	Analytics.post(Analytics.verbs.SELECTED, "_on_UploadScore_toggled", str(button_pressed))

func _on_SendAnalytics_toggled(button_pressed: bool) -> void:
	Analytics.post(Analytics.verbs.SELECTED, "_on_SendAnalytics_toggled", str(button_pressed))
	WebProfile.set_analytics(button_pressed)
	if button_pressed == true: # We need to resend analytics data, because it was stil disabled previously
		Analytics.post(Analytics.verbs.SELECTED, "_on_SendAnalytics_toggled", str(button_pressed))
	
func _on_SaveSettingsButton_pressed():
	Analytics.post(Analytics.verbs.CLICKED, "_on_SaveSettingsButton_pressed")
	WebProfile.set_name($VBoxContainer/NameContainer/PlayerName.text)
	Global.save_settings_to_disk()
	hide()



