extends CharacterBody2D

# Player 3 Movement Configuration for Store Scene
@export var max_speed: float = 200.0
@export var acceleration: float = 1600.0
@export var friction: float = 1300.0

# Animation
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var sprite: Sprite2D = $Sprite2D

# Input Actions - Player 3 WASD movement
const MOVE_LEFT = "ui_left"         # A key / Left Arrow
const MOVE_RIGHT = "ui_right"       # D key / Right Arrow  
const MOVE_UP = "ui_up"             # W key / Up Arrow
const MOVE_DOWN = "ui_down"         # S key / Down Arrow

# Alternative WASD inputs (if custom input map is set)
const WASD_LEFT = "move_left_p3"    # A key for Player 3
const WASD_RIGHT = "move_right_p3"  # D key for Player 3
const WASD_UP = "move_up_p3"        # W key for Player 3
const WASD_DOWN = "move_down_p3"    # S key for Player 3

func _ready():
	# Add player to Player3 group
	add_to_group("Player3")
	print("Player 3 initialized in store scene")
	# Connect to physics process for smooth movement
	set_physics_process(true)

func _physics_process(delta):
	handle_movement(delta)
	move_and_slide()

func handle_movement(delta):
	# Get input vector
	var input_vector = Vector2.ZERO
	
	# Check for WASD movement input (using ui_ actions as fallback)
	if Input.is_action_pressed(MOVE_LEFT) or Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed(MOVE_RIGHT) or Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	if Input.is_action_pressed(MOVE_UP) or Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
	if Input.is_action_pressed(MOVE_DOWN) or Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	
	# Also check for custom WASD inputs if they exist
	if Input.is_action_pressed("move_left") or (InputMap.has_action(WASD_LEFT) and Input.is_action_pressed(WASD_LEFT)):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right") or (InputMap.has_action(WASD_RIGHT) and Input.is_action_pressed(WASD_RIGHT)):
		input_vector.x += 1
	if Input.is_action_pressed("move_up") or (InputMap.has_action(WASD_UP) and Input.is_action_pressed(WASD_UP)):
		input_vector.y -= 1
	if Input.is_action_pressed("move_down") or (InputMap.has_action(WASD_DOWN) and Input.is_action_pressed(WASD_DOWN)):
		input_vector.y += 1
	
	# Normalize for consistent diagonal movement
	input_vector = input_vector.normalized()
	
	# Update animation direction based on movement
	if animation_tree and input_vector != Vector2.ZERO:
		# Try different parameter paths that might exist
		if animation_tree.has_method("set"):
			# Try common animation tree parameter names
			var param_paths = [
				"parameters/Walk/blend_position",
				"parameters/walk/blend_position", 
				"parameters/movement/blend_position",
				"parameters/idle_walk/blend_position"
			]
			
			for path in param_paths:
				if animation_tree.get(path) != null:
					animation_tree.set(path, input_vector)
					break
	
	# Apply movement with smooth acceleration/deceleration
	if input_vector != Vector2.ZERO:
		# Accelerate towards target velocity
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
	else:
		# Apply friction when no input
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

# Debug function to print current position
func _input(event):
	if event.is_action_pressed("ui_accept"):  # Space or Enter key
		print("Player 3 position: ", global_position)