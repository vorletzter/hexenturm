extends Node2D

func _on_Hexenturm_tree_entered() -> void:
	Events.emit_signal("new_game")
