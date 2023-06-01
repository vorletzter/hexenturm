extends Node2D

var floating_text = preload("res://screens/ui/floatingText.tscn")
onready var item_destination := $item_destination
onready var text_emitter = $Text_Emitter

func _ready() -> void:
	Global.ui = self
	Events.connect("item_collected", self, "_item_collected")
	pass

func _item_collected(item) -> void:
	show_text(item.UI_STRING)
	pass

func show_text(string: String) -> void:
	var text = floating_text.instance()
	text.text = string
	text_emitter.add_child(text)
	pass

func _on_Hexenturm_tree_exiting() -> void:
	pass # Replace with function body.

func _on_Overlay_tree_exiting() -> void:
	Global.ui = null
	pass # Replace with function body.
