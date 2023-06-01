class_name Fox # used for type casting in gdscript
extends KinematicBody2D

# An enum allows us to keep track of valid states.
enum States {
	FALLING, 
	JUMPING, 
	ON_GROUND,
	IN_AIR,
	DEAD}
	
var _state : int = States.FALLING

export var max_lifes := 4
var lifes := 1

export var max_jump_height := 361.0
export var jump_height := 160.0 #setget jump_height_set
export var jump_time_to_peak := 1.0
export var jump_time_to_descent := 0.8
onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

export var speed := 400
var velocity := Vector2.ZERO

# Position where player touched / clicked or draged to
var screen_press_pos := Vector2.ZERO
# The Margin of distance where touched_position and player postion might differ to avoid jitery movement
export var move_touch_margin := 10


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
	Events.connect("item_collected", self, "_item_collected")
	Events.emit_signal("health_changed", lifes)
	change_state(States.FALLING)
	Global.add_player(self)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		screen_press_pos = event.position
	
	if event is InputEventScreenTouch:
		screen_press_pos = event.position
	
	if event.is_pressed() == false:
		return
		screen_press_pos = Vector2.ZERO
			
func _physics_process(delta: float) -> void:
		
	if position.y > 650: # we left the screen
		Analytics.post(Analytics.verbs.DIED, "fell down", str(Achievements.platforms_climbed))
		Events.emit_signal("died")
		change_state(States.DEAD)
		get_tree().change_scene("res://screens/GameOverScreen.tscn")
	
	# keyboard input
	var input_direction_x: float = (
		Input.get_action_strength("move_right")
		- Input.get_action_strength("move_left")
	)
	
	# Screen swipe / press
	if screen_press_pos != Vector2.ZERO:
		var dif_x = screen_press_pos.x - position.x
		if dif_x < -move_touch_margin:
			input_direction_x = -1.0
		if dif_x > move_touch_margin:
			input_direction_x = 1.0
	
	# Simple state mashine
	if _state == States.ON_GROUND:
		if Input.is_action_just_pressed("jump"):
			change_state(States.JUMPING)
		change_state(States.JUMPING)
				
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
			
	# Calculating horizontal velocity.
	velocity.x = input_direction_x * speed
	velocity.y += get_gravity() * delta
	#_velocity.y += jump_impulse * delta
	velocity = move_and_slide(velocity, Vector2.UP)

func _item_collected(item):
	match item.TYPE:
		"heart":
			if lifes < max_lifes:
				lifes += 1
				Events.emit_signal("health_changed", lifes)
			else:
				Global.adjust_difficulty(1)
		"jump_boost":
			pass
		"speed_boost":
			pass
		"coin":
			pass
		"coin_rain":
			pass
		"falling_coin":
			pass
						
func change_state(new_state: int) -> void:
	var previous_state := _state
	_state = new_state
	match _state:
		States.JUMPING:
			velocity.y = jump_velocity
			$AnimatedSprite.play("jumping")
		States.ON_GROUND:
			$AnimatedSprite.play("idle")
		States.FALLING:
			$AnimatedSprite.play("falling")
		States.IN_AIR:
			pass
		States.DEAD:
			$AnimatedSprite.play("dead")
			# we fall of screen
			$World_CollisionShape.set_deferred("disabled", true)
			pass
			#print("FALLING (PEAK): " + str(position.y))

func _on_HitBox_body_entered(body: Node) -> void:
	if body.is_in_group('spell'):
		lifes -= 1
		body.queue_free()
		$AnimationPlayer.play("hit")
		Events.emit_signal("health_changed", lifes)
		Global.adjust_difficulty(-1)
		if lifes < 1:
			Events.emit_signal("died")
			change_state(States.DEAD)
			Analytics.post(Analytics.verbs.DIED, str(body.name), str(Achievements.platforms_climbed))
			#get_tree().change_scene("res://screens/StartScreen.tscn")
	pass # Replace with function body.
