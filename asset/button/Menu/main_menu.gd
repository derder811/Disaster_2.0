extends Control

# Animation variables
var original_scales = {}
var is_transitioning = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Store original button scales
	original_scales["Play Button"] = $"Play Button".scale
	original_scales["Options Button"] = $"Options Button".scale
	original_scales["Exit Button"] = $"Exit Button".scale
	
	# Connect button signals to their respective functions
	$"Play Button".pressed.connect(_on_play_button_pressed)
	$"Options Button".pressed.connect(_on_options_button_pressed)
	$"Exit Button".pressed.connect(_on_exit_button_pressed)
	
	# Connect hover signals for animations
	$"Play Button".mouse_entered.connect(_on_button_hover.bind("Play Button"))
	$"Play Button".mouse_exited.connect(_on_button_unhover.bind("Play Button"))
	$"Options Button".mouse_entered.connect(_on_button_hover.bind("Options Button"))
	$"Options Button".mouse_exited.connect(_on_button_unhover.bind("Options Button"))
	$"Exit Button".mouse_entered.connect(_on_button_hover.bind("Exit Button"))
	$"Exit Button".mouse_exited.connect(_on_button_unhover.bind("Exit Button"))
	
	# Fade in animation for the menu
	_fade_in_menu()

# Fade in animation when menu appears
func _fade_in_menu():
	modulate.a = 0.0
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 1.0, 0.8)

# Button hover animation
func _on_button_hover(button_name: String):
	if is_transitioning:
		return
	var button = get_node(button_name)
	var hover_tween = create_tween()
	hover_tween.tween_property(button, "scale", original_scales[button_name] * 1.1, 0.2)

# Button unhover animation
func _on_button_unhover(button_name: String):
	if is_transitioning:
		return
	var button = get_node(button_name)
	var unhover_tween = create_tween()
	unhover_tween.tween_property(button, "scale", original_scales[button_name], 0.2)

# Button click animation
func _animate_button_click(button_name: String, callback: Callable):
	if is_transitioning:
		return
	is_transitioning = true
	var button = get_node(button_name)
	
	# Click animation: scale down then up
	var click_tween = create_tween()
	click_tween.tween_property(button, "scale", original_scales[button_name] * 0.9, 0.1)
	click_tween.tween_property(button, "scale", original_scales[button_name] * 1.05, 0.1)
	click_tween.tween_property(button, "scale", original_scales[button_name], 0.1)
	
	# Wait for animation to complete then execute callback
	await click_tween.finished
	callback.call()

# Scene transition animation
func _transition_to_scene(scene_path: String):
	# Fade out animation
	var transition_tween = create_tween()
	transition_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await transition_tween.finished
	
	# Change scene
	get_tree().change_scene_to_file(scene_path)

# Function called when Play button is pressed
func _on_play_button_pressed():
	print("Play button pressed - Loading game selection scene")
	_animate_button_click("Play Button", func(): _transition_to_scene("res://GAME SELECTION.tscn"))

# Function called when Options button is pressed
func _on_options_button_pressed():
	print("Options button pressed")
	_animate_button_click("Options Button", func(): _transition_to_scene("res://option.tscn"))

# Function called when Exit button is pressed
func _on_exit_button_pressed():
	print("Exit button pressed - Quitting game")
	_animate_button_click("Exit Button", func(): get_tree().quit())
