#extends Area2D
extends ItemBase
const TYPE = "speed_boost"
const UI_STRING = "Geschwindigkeit"

func _on_speed_bost_body_entered(body: Node) -> void:
	if body == Global.player:
		collected()
