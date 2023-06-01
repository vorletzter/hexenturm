extends KinematicBody2D

var is_concrete := true
		
func add_item(item: Node) -> void:
	if item:
		$ItemSpace.add_child(item)
		
func _physics_process(delta: float) -> void:
	pass


func _on_DestroyArea_body_entered(body: Node) -> void:
	if body == Global.player && is_concrete:
		if Global.player._state == Global.player.States.FALLING:
			is_concrete = false
			$CollisionShape2D.queue_free()
			$DestroyArea/Tween.interpolate_property(self, 'modulate:a', self.modulate.a, 0.3, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			$DestroyArea/Tween.start()
			#self.modulate = Color(0,0,0,1)
	pass # Replace with function body.
