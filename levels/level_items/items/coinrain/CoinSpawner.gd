extends Position2D

#onready var coin_spawner = $CoinSpawner
onready var move_tween = $Move
onready var timer = $Timer
onready var aliveTimer = $AliveTimer
onready var spawner = $Spawner
export var spawn_interval_sec := 0.2
export var coins_spawned := 0
var max_coins_to_spawn  := 40
export var spawner_speed := 1
var coins_collected := 0

var coinNode = preload("res://levels/level_items/items/coinrain/falling_coin.tscn")

func _ready() -> void:
	#coin_spawner.global_position = Vector2(20, 20)
	move_tween.interpolate_property(spawner, "position", Vector2(100,20), Vector2(200,20),spawner_speed, Tween.TRANS_LINEAR,Tween.EASE_IN,0)
	move_tween.interpolate_property(spawner, "position", Vector2(200,20), Vector2(100,20),spawner_speed, Tween.TRANS_LINEAR,Tween.EASE_IN,spawner_speed)
	move_tween.connect("tween_completed", self, "_on_tween_completed")
	move_tween.start()
	timer.set_wait_time( spawn_interval_sec )
	timer.connect("timeout", self, "_spawn_coin")
	timer.set_one_shot(false)
	timer.start()
	aliveTimer.set_wait_time(10)
	aliveTimer.connect("timeout", self, "_kill")
	aliveTimer.start()
	
func _spawn_coin() -> void:
	coins_spawned += 1
	if coins_spawned <= max_coins_to_spawn:
		var new_coin = coinNode.instance()
		#var tween = Tween.new()
		#tween.interpolate_property(new_coin, "global_position", global_position, Global.ui.item_destination.position, 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		#tween.start()
		#new_coin.add_child(tween)
		new_coin.add_to_group("virtual_gravity")
		new_coin.position = spawner.position
		add_child(new_coin)
		#get_tree().get_current_scene().add_child(new_coin)
		#add_child(new_coin)
	else:
		pass
		#queue_free()

func _process(delta: float) -> void:
	if get_child_count() == 4 && coins_spawned != 0:
		queue_free()
	
func coin_collected() -> void:
	coins_collected += 1
	if coins_collected == max_coins_to_spawn:
		# Alle Münzen eines Regens eingesammelt
		pass
		#Global.ui_show_text("Alle Münzen eingesammelt!!!")
		#print ("Alle Münzen eingesammelt")
	pass
