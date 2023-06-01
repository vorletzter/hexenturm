extends ProgressBar


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	value = Global.player.speed
