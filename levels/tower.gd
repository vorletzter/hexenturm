extends Node

var level_backgrounds = [
	{"name": "Unsere Kirche", "image": "res://res/backgrounds/kirche.png"},
	{"name": "Schild am Ortseingang", "image": "res://res/backgrounds/ortseingang.jpg"},
	{"name": "Mehrzweckhalle", "image": "res://res/backgrounds/mzh.png"},
	{"name": "Fußballplatz FCO", "image": "res://res/backgrounds/fco.jpg"},
	{"name": "Unsere Kita", "image": "res://res/backgrounds/kita.png"},
	{"name": "Unsere Feuerwehr", "image": "res://res/backgrounds/feuerwehr.jpg"},
	{"name": "Unser Dorfladen", "image": "res://res/backgrounds/dorfladen.jpg"},
	{"name": "Das Kloppmans", "image": "res://res/backgrounds/kloppmans.jpg"},
	{"name": "unsere Bücherrei", "image": "res://res/backgrounds/buecherei.jpg"},
	{"name": "Unser Bushäuschen", "image": "res://res/backgrounds/bushaus.jpg"},
	{"name": "Das Haus Abendfrieden", "image": "res://res/backgrounds/abendfrieden.jpg"},
	{"name": "Unsere Arztpraxis", "image": "res://res/backgrounds/arzt.jpg"},
	{"name": "unser Bahnhof", "image": "res://res/backgrounds/bahnhof.jpg"},
	{"name": "Unser Friedof", "image": "res://res/backgrounds/friedhof.png"},
	{"name": "Unsere alte Schule", "image": "res://res/backgrounds/alteschule.png"},
	{"name": "Unser Briefkasten", "image": "res://res/backgrounds/briefkasten.jpg"},
]

var platform = preload("res://levels/level_items/platforms/Platform.tscn")
var total_item_pool_weight : float 
var item_pool = [
	{"roll_weight": 10, "acc_weight": 0, "item": preload("res://levels/level_items/items/coin.tscn"), "name": "Coin"},
	{"roll_weight": 4, "acc_weight": 0, "item": preload("res://levels/level_items/items/heart.tscn"), "name": "Herz"},
	#{"roll_weight": 2, "acc_weight": 0, "item": preload("res://levels/level_items/items/speed_boost.tscn", "name": "SpeedBoost")},
	{"roll_weight": 4, "acc_weight": 0, "item": preload("res://levels/level_items/items/jump_boost.tscn"), "name": "JumpBoost"},
	{"roll_weight": 2, "acc_weight": 0, "item": preload("res://levels/level_items/items/coinrain/coinrain.tscn"), "name": "CoinRain"},
	{"roll_weight": 10, "acc_weight": 0, "item": null, "name": "Dud"} # the dud
	]
	
var total_plaform_pool_weight : float 
var plaform_pool = [
	{"roll_weight": 1, "acc_weight": 0, "item": preload("res://levels/level_items/platforms/Platform.tscn")},
	{"roll_weight": 0, "acc_weight": 0, "item": preload("res://levels/level_items/platforms/Platform_moving.tscn")},
	{"roll_weight": 0, "acc_weight": 0, "item": preload("res://levels/level_items/platforms/Platform_breakable.tscn")},
	]

var downforce = Vector2(0,2)

# Set to the native rendering resolution
var projectResolution = Vector2(ProjectSettings.get_setting("display/window/size/width"),ProjectSettings.get_setting("display/window/size/height"))

#var platforms_pool: Array
var max_platforms_in_pool = 12
var platforms_distance = 50
var platform_spawn_pos = 0
var screen_height = 640

onready var player = $"../Player"

			
func _ready() -> void:
	randomize()
	Events.connect("difficulty_changed", self, "_on_difficulty_changed")
	Events.connect("level_changed", self, "_on_level_changed")
	Global.difficulty = 0
	_on_difficulty_changed(Global.difficulty)
	init_item_generator()
	init_platform_generator()
	
	platform_spawn_pos = screen_height - (platforms_distance*max_platforms_in_pool)
	for n in max_platforms_in_pool:
		new_platform(platform_spawn_pos + (platforms_distance*n))
		
	## preload backgrounds
	for i in level_backgrounds:
		var texture = load(i["image"])
		i["texture"] = texture
	_on_level_changed(0)
	
	if Achievements.highscore > 2000:
		$Hilfe_ctrl.queue_free()
		$hilfe_items.queue_free()
		$hilfe_hexe.queue_free()
		$hilfe_spass.queue_free()
	
func _on_level_changed(level: int) -> void:
	#print (level)
	
	#todo preload all textures to avoid stuttering	
	if level >= level_backgrounds.size():
		print ("no more textures :/")
		return
	var texture = level_backgrounds[level]["texture"]
	Global.ui.push_lvlname(level_backgrounds[level]["name"])
	if level % 2 == 1: #od
		$bg2.texture = texture
		var scaleWidth = projectResolution.x / $bg2.texture.get_size().x
		var scaleHeight = projectResolution.y / $bg2.texture.get_size().y
		$bg2.set_scale(Vector2(scaleWidth, scaleHeight))
		$AnimationPlayer.play("fade1in")
	else: # even
		$bg1.texture = texture
		var scaleWidth = projectResolution.x / $bg1.texture.get_size().x
		var scaleHeight = projectResolution.y / $bg1.texture.get_size().y
		$bg1.set_scale(Vector2(scaleWidth, scaleHeight))
		$AnimationPlayer.play("fade1in")
		$AnimationPlayer.play_backwards("fade1in")
	pass

func _on_difficulty_changed(difficulty) -> void:
	
	item_pool = [
		{"roll_weight": 10, "acc_weight": 0, "item": preload("res://levels/level_items/items/coin.tscn"), "name": "Coin"},
		{"roll_weight": 1, "acc_weight": 0, "item": preload("res://levels/level_items/items/heart.tscn"), "name": "Heart"},
		#{"roll_weight": 2, "acc_weight": 0, "item": preload("res://levels/level_items/items/speed_boost.tscn"), "name": "SpeedBoost"},
		{"roll_weight": 1, "acc_weight": 0, "item": preload("res://levels/level_items/items/jump_boost.tscn"), "name": "JumpBoost"},
		{"roll_weight": 0.5, "acc_weight": 0, "item": preload("res://levels/level_items/items/coinrain/coinrain.tscn"), "name": "CoinRain"},
		{"roll_weight": 2*(difficulty+1), "acc_weight": 0, "item": null, "name": "Dud"} # the dud
		]
	plaform_pool = [
		{"roll_weight": 30/(difficulty+1), "acc_weight": 0, "item": preload("res://levels/level_items/platforms/Platform.tscn")},
		{"roll_weight": 3*(difficulty+1), "acc_weight": 0, "item": preload("res://levels/level_items/platforms/Platform_moving.tscn")},
		{"roll_weight": 3*(difficulty+1), "acc_weight": 0, "item": preload("res://levels/level_items/platforms/Platform_breakable.tscn")},
		]
	init_platform_generator()
	init_item_generator()
	platform_spawn_pos = screen_height - (platforms_distance*max_platforms_in_pool)
#
# Platform Generator
#	
func init_platform_generator() -> void:
	total_plaform_pool_weight = 0
	for item in plaform_pool:
		total_plaform_pool_weight += item.roll_weight
		item.acc_weight = total_plaform_pool_weight

func roll_platform():
	var roll := rand_range(0, total_plaform_pool_weight)
	for obj_type in plaform_pool:
		if (obj_type.acc_weight > roll):
			return obj_type['item']
	return null
	
#
# Item Generator
#	
func init_item_generator() -> void:
	total_item_pool_weight = 0
	for item in item_pool:
		total_item_pool_weight += item.roll_weight
		item.acc_weight = total_item_pool_weight
		
	for item in item_pool:
		return
		var prob = (item["roll_weight"]/total_item_pool_weight) * 100
		print (str(item["name"]) + " -> " + str(prob) +  "%")

func roll_item():
	randomize()
	var roll := rand_range(0, total_item_pool_weight)
	for obj_type in item_pool:
		if (obj_type.acc_weight > roll):
			return obj_type['item']
	return null

#
# Platform Generator (with items)
#	
func new_platform(pos_y : int = 0):
	#var p_inst = platform.instance()
	var p_inst = roll_platform().instance()
	var roll = roll_item()
	if roll: # if we don't get anything, we rolled the dud
		var item = roll.instance()
		p_inst.add_item(item)
	p_inst.add_to_group("platforms")
	p_inst.add_to_group("virtual_gravity")
	p_inst.position = Vector2(rand_range(64,250), pos_y)
	#platforms_pool.append(p_inst)
	call_deferred("add_child", p_inst)
						
#
# Game Logic
#	
func _physics_process(delta):
			
	if Global.player.position.y < 450:
		var diff = 450 - Global.player.position.y # calculate how much the player is in the upper area
		#var y = lerp(Global.player.position.y, 500, Global.player.position.y/400)
		#print (y)
		downforce.y = lerp(diff, 0, 0.93)
		#downforce.y = player.velocity.y
		
		#downforce = Vector2(0,diff/30)
		#print (str(downforce.y))
		#print (str(diff))
		
	#if get_node("detect_player_in_upper_area").overlaps_body(Global.player):
		#Global.player.position += downforce # player
		Global.player.move_and_collide(downforce)
		# move platforms
		
		#if Global.player.position.x > 400:
			
		# destroy platforms
		for e in get_tree().get_nodes_in_group("virtual_gravity"):
			e.position += downforce
			if e.position.y > screen_height:
				e.queue_free()
				if "platform" in e.name:
					new_platform(platform_spawn_pos)
					
		# move textures
		var background = get_node("background")
		if (background.offset.y > background.texture.get_height()):
			background.offset.y = 0
		background.offset.y += downforce.y/3
		var wall_right = get_node("wall_right/Sprite")
		if (wall_right.offset.y > 64):
			wall_right.offset.y = 0
		wall_right.offset.y += downforce.y
		var wall_left = get_node("wall_left/Sprite")
		if (wall_left.offset.y > 128):
			wall_left.offset.y = 0
		wall_left.offset.y += downforce.y		
