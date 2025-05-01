extends CharacterBody2D

@export var speed := 100  # Movement speed
@onready var sprite := $AnimatedSprite2D  # Reference to the AnimatedSprite2D
@export var attack_speed := 3.0  # Slow down attack speed by adjusting the FPS (float)

# Direction vector for movement
var direction = Vector2.ZERO
var last_direction = "down"  # Default last direction is down
var is_attacking = false  # Track whether the player is currently attacking

func _physics_process(delta):
	# Get input for movement
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	# Normalize the direction for consistent movement speed in all directions
	velocity = direction.normalized() * speed
	move_and_slide()

	# Update animation based on movement
	update_animation()

	# Check for attack input
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		perform_attack()

# Function to update animations based on movement direction
func update_animation():
	# Handle idle state
	if direction == Vector2.ZERO:
		# If idle, play the correct idle animation based on last direction
		if last_direction == "left":
			sprite.play("idle_left")
		elif last_direction == "right":
			sprite.play("idle_right")
		elif last_direction == "up":
			sprite.play("idle_up")
		else:
			sprite.play("idle_down")
		sprite.flip_h = false  # Always face right when idle

	else:
		# If there is horizontal movement (left/right)
		if abs(direction.x) > abs(direction.y):
			if direction.x < 0:
				sprite.play("walk_left")  # Play walk_left animation when moving left
				last_direction = "left"
			else:
				sprite.play("walk_right")  # Play walk_right animation when moving right
				last_direction = "right"
		# If vertical movement (up/down)
		elif direction.y < 0:
			sprite.play("walk_up")
			last_direction = "up"
		else:
			sprite.play("walk_down")
			last_direction = "down"
		
		sprite.flip_h = false  # Always face right when moving

# Function to perform attack in the correct direction
func perform_attack() -> void:
	# Set the attack speed (FPS) to be slower
	sprite.speed = float(attack_speed)  # Slow down the attack animation (ensure it's a float)
	
	# Ensure attack animation plays only in the correct direction
	if direction.x < 0:
		sprite.play("attack_left")  # Attack animation facing left
		sprite.flip_h = false  # Face right when attacking left
	elif direction.x > 0:
		sprite.play("attack_right")  # Attack animation facing right
		sprite.flip_h = false  # Face right when attacking right
	elif direction.y < 0:
		sprite.play("attack_up")  # Attack animation facing up
	else:
		sprite.play("attack_down")  # Attack animation facing down
	
	# Wait for the attack animation to finish using `await`
	await sprite.animation_finished  # Wait for the attack animation to finish
	
	# Once the attack is finished, return to idle animation
	is_attacking = false
	return_to_idle()

# Function to return to idle animation after attack
func return_to_idle():
	if last_direction == "left":
		sprite.play("idle_left")
	elif last_direction == "right":
		sprite.play("idle_right")
	elif last_direction == "up":
		sprite.play("idle_up")
	else:
		sprite.play("idle_down")
	sprite.flip_h = false  # Always face right when idle
