extends ProgressBar

func _ready() -> void:
	Events.connect("health_changed", self, "_on_health_changed")
	
func _on_health_changed(lifes):
	value = lifes
