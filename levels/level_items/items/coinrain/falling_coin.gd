extends ItemBase
class_name FallingCoin
const TYPE = "falling_coin"
const UI_STRING = "Münze"

export var coins_fall_speed := 80
export var alive_time := 10.0

func _on_Coin_body_entered(body: Node) -> void:
	if body == Global.player:
		collected()
		get_parent().coin_collected()

func _physics_process(delta: float) -> void:
		position.y = position.y+delta*coins_fall_speed
		alive_time -= delta
		if alive_time < 0:
			queue_free()
