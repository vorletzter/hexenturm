extends ItemBase
class_name Coin
const TYPE = "coin"
const UI_STRING = "Münze"

func _on_Coin_body_entered(body: Node) -> void:
	if body == Global.player:
		collected()
