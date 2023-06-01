extends Position2D

onready var label = $Label
onready var tween = $Tween
var text: String = ""

var velocity = Vector2(0,0)

func _ready() -> void:
	label.text = text
	#randomize()
	#var side_movement = randf_range(0.2, 0.3)
	velocity = Vector2(0.0, -0.8)
	
	tween.interpolate_property(self, 'scale', scale, Vector2(1.5,1.5), 0.6, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'scale', Vector2(1,1), Vector2(0.1,0.1), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.6)
	tween.start()
	pass

func _on_Tween_tween_all_completed() -> void:
	self.queue_free()

func _process(delta: float) -> void:
	position += velocity
