#extends Area2D
extends ItemBase
class_name JumpBoost

const TYPE = "jump_boost"
const UI_STRING = "Sprungtrank"

func _on_jump_boost_body_entered(body: Node) -> void:
	if body == Global.player:
		collected()
