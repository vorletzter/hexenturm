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
	#text_emitter.add_child(text)
	pass

func _on_Hexenturm_tree_exiting() -> void:
	pass # Replace with function body.

func _on_Overlay_tree_exiting() -> void:
	Global.ui = null
	pass # Replace with function body.

func push_lvlname(lvlname: String) -> void:
	$lvlname.text = lvlname
	$lvlname.visible = true
	var tween := Tween.new()
	add_child(tween)
	tween.set_active(true)
	tween.interpolate_property($lvlname, "modulate", Color(1,1,1,0), Color(1,1,1,1), 2)
	yield(tween, "tween_completed")
	tween.queue_free()
	var timer = Timer.new()
	timer.connect("timeout",self,"_on_lvlname_timer_timeout") 
	timer.set_wait_time( 3 )
	timer.one_shot = true
	add_child(timer) #to process
	timer.start() #to start
		
func _on_lvlname_timer_timeout() -> void:
	var tween := Tween.new()
	add_child(tween)
	tween.interpolate_property($lvlname, "modulate", Color(1,1,1,1), Color(1,1,1,0), 2)
	tween.set_active(true)
	yield(tween, "tween_completed")
	tween.queue_free()
	$lvlname.visible = false
	
