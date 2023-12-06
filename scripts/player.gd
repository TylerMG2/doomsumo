extends CharacterBody2D

# Constants for movement
const SPEED = 300.0
const ACCELERATION = 6000.0
const AIR_CONTROL = 0.1
const JUMP_VELOCITY = -600.0
const RUN_VELOCITY = 250.0
const CHARGE_CONTROL = 0.5
const PUNCH_VELOCITY = 1000.0
const BASE_CHARGE = 0.05
const MAX_PUNCH_DURATION = 0.5

# Special move properties
const LAUNCH_VELOCITY = 1000.0

# Punch variables
var punch_charge = BASE_CHARGE
var facing = 1

# Cooldown timers
@onready var launch_cooldown_timer = $launch_cooldown
@onready var punch_cooldown_timer = $punch_cooldown
@onready var punch_timer = $punch_timer

# Get gravity
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Ability vars
var can_launch = true
var is_launching = false
var can_punch = true
var is_punching = false
var is_charging = false

func _physics_process(delta):
	
	# Apply gravity
	if not is_on_floor():
		
		# If we are not punching
		if not is_punching:
			velocity.y += gravity * delta
	elif is_launching:
		velocity.x = 0
		is_launching = false
	
	# Check for jumping
	if Input.is_action_just_pressed("jump"):
		
		# Cancel punching
		is_punching = false
		
		# Launch player
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
	
	# Left and right movement
	var direction = Input.get_axis("move_left", "move_right")
	if not is_launching and not is_punching:
		
		# Calculate the velocity we are aiming to hit
		var target_velocity = direction * RUN_VELOCITY
		
		# If we are in the air
		var control = 1
		if not is_on_floor():
			control = AIR_CONTROL
		
		# If we are charging a punch
		if is_charging:
			target_velocity *= CHARGE_CONTROL
		
		# If the direction is not 0
		if direction != 0:
			facing = direction
			
		# Move towards target
		var acceleration_rate = ACCELERATION * control
		if velocity.x < target_velocity:
			velocity.x = min(velocity.x + acceleration_rate * delta, target_velocity)
		elif velocity.x > target_velocity:
			velocity.x = max(velocity.x - acceleration_rate * delta, target_velocity)
	
	# Launch ability
	if Input.is_action_just_pressed("launch"):
		
		if can_launch and not is_launching:
			perform_launch()
		else:
			is_launching = false
	
	## Punch ability
	if can_punch:
		
		# Prime
		if Input.is_action_just_pressed("punch"):
			is_launching = false
			is_charging = true
		
		# Charge
		if Input.is_action_pressed("punch"):
			punch_charge = min(punch_charge + delta/2, MAX_PUNCH_DURATION)
			
		# Release
		if Input.is_action_just_released("punch") and is_charging:
			punch_timer.start(punch_charge)
			punch_charge = BASE_CHARGE
			is_punching = true
			is_charging = false
			can_punch = false
			
			# Move in the last known direction
			velocity.x = facing * PUNCH_VELOCITY
			velocity.y = 0
	
	move_and_slide()

# Launch functionality
func perform_launch():
	
	# Update some vars
	is_launching = true
	is_punching = false
	can_launch = false
	
	# Start cooldown 
	launch_cooldown_timer.start()
	
	# Calculate launch direction
	var x_dir = Input.get_axis("move_left", "move_right")
	var y_dir = max(Input.get_action_strength("move_up")*2, 0.6) # Default y dir should be somewhat up
	var launch_dir = Vector2(x_dir, -y_dir).normalized()
	
	# Update velocity
	var launch_velocity = launch_dir * LAUNCH_VELOCITY
	velocity.y = launch_velocity.y
	velocity.x += launch_velocity.x

func _on_launch_cooldown_timeout():
	can_launch = true

func _on_punch_cooldown_timeout():
	can_punch = true

func _on_punch_timer_timeout():
	is_punching = false
	punch_cooldown_timer.start()



