extends KinematicBody2D

# GENERAL CONSTANTS
const FLOOR_NORMAL = Vector2.UP
const SNAP_DIRECTION = Vector2.DOWN
const SNAP_LENGTH = 32
const LIMIT_SPEED_Y = 1200

# ANYA VARIABLES
const dash_speed = 1200.0
const dash_duration = 0.3
onready var dash = $Dash

# CUSTOM VARIABLES
export(float) var move_speed = 500.0
export(float) var DASH = 2000.0
export(float) var jump_strength = 1100.0
export(float) var maximun_jumps = 2
export(float) var double_jump_strength = 900.0
export(float) var gravity = 2500.0

var _jumps_made = 0
var _dashes_made = 0
var canDash = true
var dashing = false
var dashDirection = Vector2.ZERO

var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var snap_vector = SNAP_DIRECTION * SNAP_LENGTH

#func dash():
#	if Input.is_action_just_pressed("dash") and canDash:
#		velocity = direction * 2000
#		canDash = false
#		dashing = true
#		yield(get_tree().create_timer(1), "timeout")
#		dashing = false
#		canDash = true
		




# MOVEMENT
func _physics_process(delta: float) -> void:
	var _horizontal_direction = (
		Input.get_action_strength("right")
		- Input.get_action_strength("left")
	)
	
	if Input.is_action_just_pressed("dash") && dash.can_dash && !dash.is_dashing():
		dash.start_dash(dash_duration)
		velocity.y = -DASH * 1/4
		
	if not Input.is_action_pressed("right"):
		dashing = false
	if not Input.is_action_pressed("left"):
		dashing = false
		
		
	var speed = dash_speed if dash.is_dashing() else move_speed
	
	velocity.x = _horizontal_direction * speed
	velocity.y += gravity * delta
	velocity.y = move_and_slide_with_snap(velocity, snap_vector,
			FLOOR_NORMAL, true).y
			
	
	# JUMP VARIABLES
	var is_falling = velocity.y > 0.0 and not is_on_floor()
	var is_jumping = Input.is_action_just_pressed("up") and is_on_floor()
	var is_double_jumping = Input.is_action_just_pressed("up") and is_falling
	var is_jump_cancelled = Input.is_action_just_released("up") and velocity.y < 0.0
	
	# DASH VARIABLES
#	var is_air_dashing = Input.is_action_just_pressed("dash") and not is_on_floor()
#	var speed = DASH if Input.is_action_just_pressed("dash") else speed
	
	# GROUND VARIABLES
	var is_idling = is_on_floor() and is_zero_approx(velocity.x)
	var is_running = is_on_floor() and not is_zero_approx(velocity.x)
	
	# JUMPING
	if is_jumping:
		_jumps_made += 1
		velocity.y = -jump_strength
		if is_on_floor():
			snap_vector = Vector2.ZERO
			velocity.y = -jump_strength
	elif is_double_jumping:
		_jumps_made += 1
		if _jumps_made <= maximun_jumps:
			velocity.y = -double_jump_strength
	elif is_jump_cancelled:
		velocity.y = 0.0
	elif is_idling or is_running:
		_jumps_made = 0
		
	# ANIMATIONS
	
	if is_idling:
		$Sprite.play("Idle")
	if Input.is_action_pressed("ui_right"):
		$Sprite.flip_h = false
	elif Input.is_action_pressed("ui_left"):
		$Sprite.flip_h = true
		
	if is_running:
		$Sprite.play("Run")
	elif Input.is_action_pressed("ui_left"):
		$Sprite.flip_h = true
	if not is_on_floor():
		$Sprite.play("Jump")
	elif Input.is_action_pressed("ui_left"):
		$Sprite.flip_h = true
		
	#if velocity.y > 0.0:
		#$Sprite.play("Fall")
		
		
	if Input.is_action_pressed("dash") and canDash and not is_on_floor():
		$Sprite.play("Dash")
	elif Input.is_action_pressed("ui_left"):
		$Sprite.flip_h = true
		
	
	#DASHING
#	if is_air_dashing:
#		_dashes_made += 1
#		if Input.is_action_pressed("dash") and Input.is_action_pressed("left") and canDash:
#			velocity.x = velocity.x * -DASH
#			velocity.y = -DASH * 1/2
#			canDash = false
#			dashing = true
#			yield(get_tree().create_timer(1), "timeout")
#			dashing = false
#			canDash = true
#		if Input.is_action_pressed("dash") and Input.is_action_pressed("right") and canDash:
#			velocity.x = velocity.x * DASH
#			velocity.y = -DASH * 1/2
#			canDash = false
#			dashing = true
#			yield(get_tree().create_timer(1), "timeout")
#			dashing = false
#			canDash = true
#		if _dashes_made <= maximun_dashes:
#			is_air_dashing = false
#		elif is_idling or is_running:
#			_dashes_made = 0
	
	
	
	if is_on_floor() and snap_vector == Vector2.ZERO:
		reset_snap()
		
func reset_snap():
	snap_vector = SNAP_DIRECTION * SNAP_LENGTH

	
	velocity = move_and_slide_with_snap(velocity, FLOOR_NORMAL)
	
	



