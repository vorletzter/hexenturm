extends KinematicBody2D

export var Speed = 200
var spell_projectile = preload("res://levels/level_items/spell_projectile.tscn")
export var spell_projectile_speed = 20
export var fire_intervall = 60
var fire_timeout = 0

onready var path_follow = get_parent()
export var _speed = 20

func _physics_process(delta):
	path_follow.set_offset(path_follow.get_offset() * _speed * delta)
	fire_timeout += 1
	if fire_timeout > fire_intervall:
		fire_spell()
		fire_timeout = 0
	
func fire_spell():
	var projectile = spell_projectile.instance()
	projectile.position = $SpellEmitter.get_global_position()
	projectile.apply_impulse(Vector2(), Vector2(spell_projectile_speed,0).rotated(rotation))
	get_tree().get_root().add_child(projectile)
