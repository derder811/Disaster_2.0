extends CanvasLayer

# Reference to the settings button
@onready var settings_button = $"Settings Button"

# Animation variables
var original_scale: Vector2
var is_transitioning = false

func _ready():
	# Store original button scale
	original_scale = settings_button.scale
	
	# Connect button signals
	settings_button.pressed.connect(_on_settings_button_pressed)
	
	# Connect hover signals for animations
	settings_button.mouse_entered.connect(_on_button_hover)
	settings_button.mouse_exited.connect(_on_button_unhover)

func _on_settings_button_pressed():
	_animate_button_click(_open_settings)

func _open_settings():
	print("Settings button: Opening GameSettings")
	# Get the GameSettings node from the main scene
	var game_settings = get_node("../GameSettings")
	if game_settings:
		# Check if settings are already visible to prevent overlapping
		if game_settings.visible:
			print("Settings button: GameSettings already visible, hiding instead")
			game_settings.visible = false
			get_tree().paused = false
		else:
			print("Settings button: Showing GameSettings")
			game_settings.show_settings()
	else:
		print("GameSettings node not found!")

func _on_button_hover():
	if is_transitioning:
		return
	
	var hover_tween = create_tween()
	hover_tween.tween_property(settings_button, "scale", original_scale * 1.1, 0.1)

func _on_button_unhover():
	if is_transitioning:
		return
	
	var unhover_tween = create_tween()
	unhover_tween.tween_property(settings_button, "scale", original_scale, 0.1)

func _animate_button_click(callback: Callable):
	if is_transitioning:
		return
	
	is_transitioning = true
	
	var click_tween = create_tween()
	click_tween.tween_property(settings_button, "scale", original_scale * 0.9, 0.05)
	click_tween.tween_property(settings_button, "scale", original_scale, 0.05)
	click_tween.tween_callback(func(): 
		is_transitioning = false
		callback.call()
	)
