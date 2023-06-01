extends KinematicBody2D

#onready var tween_values = [position.x, position.x+100]
var tween_values
var speed : float

func _ready() -> void:	
	randomize()
	tween_values = [rand_range(50,100), rand_range(200,250)]
	speed = rand_range(2, 2.3)
	#$Tween.start()
	_start_tween()
	pass
		
func add_item(item: Node) -> void:
	if item:
		$ItemSpace.add_child(item)

func _start_tween():
	#tween.interpolate_property(self, 'scale', scale, Vector2(1.5,1.5), 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.interpolate_property(self, 'position:x', tween_values[0], tween_values[1], speed, Tween.TRANS_QUAD, Tween.EASE_OUT)    
	$Tween.start()
func _on_Tween_tween_completed(object: Object, key: NodePath) -> void:
	tween_values.invert()
	_start_tween()
	pass # Replace with function body.
