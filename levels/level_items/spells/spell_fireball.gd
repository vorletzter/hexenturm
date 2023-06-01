extends RigidBody2D

export var lifetime = 3.0
var v_grav : Vector2

enum Pulse {UP, DOWN}
var _state = Pulse.UP

var pulse_mod = 0.05

func _physics_process(delta: float) -> void:
	lifetime -= delta
	if lifetime < 0:
		queue_free()
		
	$Light2D.energy += pulse_mod
	if $Light2D.energy < 0.5:
		pulse_mod = 0.05
		
	if $Light2D.energy > 1.5:		
		pulse_mod = -0.05

func set_me_up():
	apply_impulse(Vector2(), Vector2(rand_range(-200,200),rand_range(0,100)))
	add_to_group("virtual_gravity")
