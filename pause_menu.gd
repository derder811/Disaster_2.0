extends Control

# Variables
var is_paused = false
var original_scales = {}

# UI References
@onready var resume_button = $CanvasLayer/PopupPanel/MenuContainer/ResumeButton
@onready var settings_button = $CanvasLayer/PopupPanel/MenuContainer/SettingsButton

func _ready():
	# Store original button scales
	original_scales["ResumeButton"] = resume_button.scale
	original_scales["SettingsButton"] = settings_button.scale
	
	# Connect button signals
	resume_button.pressed.connect(_on_resume_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	
	# Connect hover animations
	resume_button.mouse_entered.connect(_on_button_hover.bind("ResumeButton"))
	resume_button.mouse_exited.connect(_on_button_unhover.bind("ResumeButton"))
	settings_button.mouse_entered.connect(_on_button_hover.bind("SettingsButton"))
	settings_button.mouse_exited.connect(_on_button_unhover.bind("SettingsButton"))
	
	# Initially hide the pause menu
	visible = false

func _input(event):
	if event.is_action_pressed("pause_game") or (event is InputEventKey and event.keycode == KEY_ESCAPE):
		if is_paused:
			resume_game()
		else:
			pause_game()

func pause_game():
	is_paused = true
	get_tree().paused = true
	visible = true
	_fade_in_menu()

func resume_game():
	is_paused = false
	get_tree().paused = false
	_fade_out_menu()

func _fade_in_menu():
	modulate.a = 0.0
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 1.0, 0.3)

func _fade_out_menu():
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await fade_tween.finished
	visible = false

func _on_button_hover(button_name: String):
	var button = get_node("CanvasLayer/PopupPanel/MenuContainer/" + button_name)
	var hover_tween = create_tween()
	hover_tween.tween_property(button, "scale", original_scales[button_name] * 1.1, 0.2)

func _on_button_unhover(button_name: String):
	var button = get_node("CanvasLayer/PopupPanel/MenuContainer/" + button_name)
	var unhover_tween = create_tween()
	unhover_tween.tween_property(button, "scale", original_scales[button_name], 0.2)

func _animate_button_click(button_name: String, callback: Callable):
	var button = get_node("CanvasLayer/PopupPanel/MenuContainer/" + button_name)
	
	# Click animation: scale down then up
	var click_tween = create_tween()
	click_tween.tween_property(button, "scale", original_scales[button_name] * 0.9, 0.1)
	click_tween.tween_property(button, "scale", original_scales[button_name] * 1.05, 0.1)
	click_tween.tween_property(button, "scale", original_scales[button_name], 0.1)
	
	# Wait for animation to complete then execute callback
	await click_tween.finished
	callback.call()

func _on_resume_button_pressed():
	_animate_button_click("ResumeButton", func(): resume_game())

func _on_settings_button_pressed():
	_animate_button_click("SettingsButton", func(): _open_settings())

func _open_settings():
	# Hide the pause menu before showing settings
	_fade_out_menu()
	# Get the GameSettings node from the main scene
	var game_settings = get_node("../GameSettings")
	if game_settings:
		game_settings.show_settings()
	else:
		print("GameSettings node not found!")
