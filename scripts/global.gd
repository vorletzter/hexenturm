extends Node

var player = null
var ui = null

var first_start = true
var difficulty = 0

onready var l = Logger.new("global.gd")

func _ready():
	#Events.connect("died", self, "_died")
	Events.connect("new_game", self, "on_new_game")
	
func _on_new_game() -> void:
	print ("game started")
	difficulty = 0
	
func adjust_difficulty(value):
	if value < 0 && difficulty < 4: # we never fall under 3 for Difficulty
		print ("Difficulty floor reached")
		return
	difficulty += value
	print ("New Difficulty: " + str(difficulty))
	Events.emit_signal("difficulty_changed", difficulty)
	
func add_player(new_player):
	player = new_player
		
func save_settings_to_disk():
	var config = ConfigFile.new()
	#config.set_value("Game", "player_name", player_name)
	#config.set_value("Game", "id", PROFILE_UUID)
	#config.set_value("Game", "uuid", PROFILE_UUID)
	#config.set_value("Game", "highscore", highscore)
	config.save("user://config.cfg")

func read_settings_from_disk():
	var player_name
	var config = ConfigFile.new()
	var err = config.load("user://config.cfg")
	if err != OK:
		return false
	if config.has_section("Game") == false:
		return false
	for i in config.get_sections():
		player_name = config.get_value(i, "player_name")
		if player_name != null:
			l.log("Found player_name: "+player_name, l.levels.INFO)
		else:
			player_name = "Kirmesfan"
	return true
