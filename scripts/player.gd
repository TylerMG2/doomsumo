extends CharacterBody2D

# Constants for movement
const SPEED = 300.0
const ACCELERATION = 50.0
const AIR_CONTROL = 0.1
const JUMP_VELOCITY = -600.0
const RUN_VELOCITY = 250.0

# Special move properties
const LAUNCH_VELOCITY = 1000.0

# Cooldown timers
@onready var launch_cooldown_timer = $launch_cooldown

# Get gravity
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Movement variables
var can_launch = true
var is_launching = false

func _physics_process(delta):
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		is_launching = false
	
	# Check for jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Left and right movement
	var direction = Input.get_axis("move_left", "move_right")
	if not is_launching:
		
		# Calculate the velocity we are aiming to hit
		var target_velocity = direction * RUN_VELOCITY
		
		# If we are in the air
		var control = 1
		if not is_on_floor():
			control = AIR_CONTROL
		
		velocity.x = lerp(velocity.x, target_velocity, ACCELERATION * control * delta)
	
	# Launch ability
	if Input.is_action_just_pressed("launch"):
		
		if can_launch:
			perform_launch()
		else:
			is_launching = false
	
	move_and_slide()

# Launch functionality
func perform_launch():
	
	# Update some vars
	is_launching = true
	can_launch = false
	launch_cooldown_timer.start()
	
	# Calculate launch direction
	var x_dir = Input.get_axis("move_left", "move_right")
	var y_dir = max(Input.get_action_strength("move_up")*2, 0.6)
	var launch_dir = Vector2(x_dir, -y_dir).normalized()
	
	# Update velocity
	var launch_velocity = launch_dir * LAUNCH_VELOCITY
	velocity.y = launch_velocity.y
	velocity.x += launch_velocity.x

func _on_launch_cooldown_timeout():
	can_launch = true
