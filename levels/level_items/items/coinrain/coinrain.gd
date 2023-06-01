#extends Area2D
extends ItemBase
const TYPE = "coin_rain"
const UI_STRING = "Münzenregen"

onready var spawnerSzene = preload("res://levels/level_items/items/coinrain/CoinSpawner.tscn")

func _on_Coinrain_body_entered(body: Node) -> void:
	if body == Global.player:
		var spawner = spawnerSzene.instance()
		get_tree().get_current_scene().add_child(spawner)
		collected()
