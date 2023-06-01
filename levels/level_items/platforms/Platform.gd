extends KinematicBody2D
		
func add_item(item: Node) -> void:
	if item:
		$ItemSpace.add_child(item)
