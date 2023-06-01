extends ProgressBar


func _ready() -> void:
	max_value = Achievements.highscore
	pass
	
func _physics_process(delta: float) -> void:
	value = Achievements.score
