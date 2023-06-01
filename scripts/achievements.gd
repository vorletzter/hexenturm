extends Node

## Achievements
# - play x days in a row
# - collect x coins
# - collect x items
# - collect all coins in coin rain ( x times)
# - reach level x
# - reach height x

## Rewards
# - New Skins
# - Have a cat!
# - Increase Luck
# - New Items (Coin Magnet, Witch-Freeze)
# - Modify Starting Stats (Lifes)
# - Modify World (longer platforms, less anti platforms)
# - New Game Mode (Hyper mode)

var item_stats := {
	"coin": 0, 
	"coin_rain": 0, 
	"heart": 0,
	"jump_boost": 0,
	"speed_boost" : 0,
	"falling_coin": 0,
	"score": 0,
	"platforms_climbed": 0
	 }
	
var platforms_climbed = 0
var highscore = 0
var score = 0
var difficulty = 0 
var level := 0

onready var l = Logger.new("global.gd")

func _ready():
	Events.connect("new_game", self, "_new_game_started")
	Events.connect("add_score", self, "_add_score")
	Events.connect("item_collected", self, "_item_collected")
	Events.connect("died", self, "_died")

func _new_game_started() -> void:
	print ("game started")
	for key in item_stats.keys():
		item_stats[key] = 0
	score = 0
	platforms_climbed = 0
	difficulty = 0

	
func _died() -> void:
	for key in item_stats.keys():
		prints(key, " -> ", item_stats[key])
	
func _item_collected(item) -> void:
	match item.TYPE:
		"heart":
			item_stats["heart"] +=1
		"jump_boost":
			item_stats["jump_boost"] +=1
		"speed_boost":
			item_stats["jump_boost"] +=1
		"coin":
			item_stats["coin"] +=1
		"coin_rain":
			item_stats["coin_rain"] +=1
		"falling_coin":
			item_stats["falling_coin"] +=1
			
func add_climbed_platform(num):
	platforms_climbed += num
	var _new_level : int = platforms_climbed / 50
	#print ("Platforms: " + str(platforms_climbed) + " | Level: " + str(_new_level))
	if _new_level != level:
		level = _new_level
		Events.emit_signal("level_changed", level)
		difficulty += 1
		#Events.emit_signal("new_level", level)
		Global.adjust_difficulty(1)
	score += num
	if score > highscore:
		highscore = score
		
func add_score(num):
	score += num
