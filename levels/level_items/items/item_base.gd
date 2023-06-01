extends Area2D
class_name ItemBase

onready var tween = Tween.new()
export var score_value : int

func _ready() -> void:
	add_child(tween)
	tween.connect("tween_all_completed", self, "_on_tween_all_completed")
	
func collected() -> void:
	Events.emit_signal("item_collected", self)
	Achievements.add_score(score_value)
	tween.interpolate_property(self, "global_position", global_position, Global.ui.item_destination.position, 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	
func _on_tween_all_completed() -> void:
	#Global.ui_show_text(str(score_value))
	queue_free()
