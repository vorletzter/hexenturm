#extends Area2D
extends ItemBase
const TYPE = "heart"
const UI_STRING = "Leben"

func _on_shield_body_entered(body: Node) -> void:
	if body == Global.player:
		collected()
