class_name Player # used for type casting in gdscript
extends KinematicBody2D

# An enum allows us to keep track of valid states.
enum States {
	FALLING, 
	JUMPING, 
	ON_GROUND,
	IN_AIR,
	DEAD}
	
var _state : int = States.FALLING

onready var player = Global.player

export var jump_height := 100.0 #setget jump_height_set
export var jump_time_to_peak := 1.0
export var jump_time_to_descent := 0.8
onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
var move_to_pos = Vector2.ZERO

export var speed := 5
var velocity := Vector2.ZERO

func get_lowest_reachable_platform() -> Node:
	var platforms = get_tree().get_nodes_in_group("platforms")
	var retVal 
	var reachable_height = position.x+jump_height
	for pltf in platforms:
		if pltf.position.y < reachable_height:
			if retVal != null:
				if retVal.position.x < pltf.position.x:
					retVal = pltf
			else:
				retVal = pltf
			# we need to sort stuff...
	return retVal
	
func find_closest_or_furthest(node: Object, group_name: String, get_closest:= true) -> Object:
	var target_group = get_tree().get_nodes_in_group(group_name)
	var distance_away = node.global_position.distance_to(target_group[0].global_position)
	var return_node = target_group[0]
	for index in target_group.size():
		var distance = node.global_position.distance_to(target_group[index].global_position)
		if get_closest == true && distance < distance_away:
			distance_away = distance
			return_node = target_group[index]
		elif get_closest == false && distance > distance_away:
			distance_away = distance
			return_node = target_group[index]
	return return_node

func jump_height_set(new_jump_height) -> void:
	jump_height = new_jump_height
	jump_time_to_peak += 0.02
	jump_time_to_descent += 0.02
	jump_velocity = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
	jump_gravity = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
	fall_gravity = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity
		
func _ready() -> void:
	# Initialize the state machine, passing a reference of the player to the states,
	# that way they can move and react accordingly
	change_state(States.FALLING)
	#Global.add_player(self)
				
func _physics_process(delta: float) -> void:
	var direction := 0
	if position.y > 650: # we left the screen
		pass
		# ToDO
		# move the fox up, if he is off screen
	
	# Simple state mashine
	if _state == States.ON_GROUND:
		
		var move_to_node = find_closest_or_furthest(self, "platforms")
		move_to_node.modulate = Color(100,10,10,100)
		move_to_pos = move_to_node.position 
		move_to_pos.x += 15
		print (move_to_pos)
		change_state(States.JUMPING)
		pass	
		#change_state(States.JUMPING)
				
	if _state == States.JUMPING:
		change_state(States.IN_AIR)
		
	if _state == States.IN_AIR:
		if velocity.y >= 0:
			change_state(States.FALLING)
			
	if _state == States.FALLING:
		if is_on_floor():
			change_state(States.ON_GROUND)
	
	if _state == States.DEAD: 
		# we just fall down without controll or collisions
		velocity.y += get_gravity() * delta * 4
		velocity = move_and_slide(Vector2(0,velocity.y), Vector2.UP)
		return
		
		#return # so that we don't process any movement stuff
		# Doodlejump style or something else?
	if move_to_pos.x < position.x:
		direction = -1
	if move_to_pos.x > position.x:
		direction = 1
			
	# Calculating horizontal velocity.
	velocity.x += direction * speed
	velocity.y += get_gravity() * delta
	#_velocity.y += jump_impulse * delta
	velocity = move_and_slide(velocity, Vector2.UP)
						
func change_state(new_state: int) -> void:
	var previous_state := _state
	_state = new_state
	match _state:
		States.JUMPING:
			velocity.y = jump_velocity
			$AnimatedSprite.play("jumping_start")
		States.ON_GROUND:
			$AnimatedSprite.play("idle")
		States.FALLING:
			$AnimatedSprite.play("jumping_start")
		States.IN_AIR:
			$AnimatedSprite.play("jumping_middle")
			pass
		States.DEAD:
			$AnimatedSprite.play("dead")
			# we fall of screen
			$World_CollisionShape.set_deferred("disabled", true)
			pass
			#print("FALLING (PEAK): " + str(position.y))

func _on_HitBox_body_entered(body: Node) -> void:
	if body.is_in_group('spell'):
		pass
