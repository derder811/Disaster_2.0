extends CanvasLayer

# Reference to the settings button
@onready var settings_button: TextureButton = get_node_or_null("Settings Button")

# Animation variables
var original_scale: Vector2 = Vector2.ONE
var is_transitioning := false

func _ready():
	# Ensure this overlay processes input even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if not settings_button:
		print("SettingsButton: ERROR -> Child 'Settings Button' not found")
		return
	
	# Store original button scale safely
	original_scale = settings_button.scale
	
	# Connect button signals
	settings_button.pressed.connect(_on_settings_button_pressed)
	settings_button.mouse_entered.connect(_on_button_hover)
	settings_button.mouse_exited.connect(_on_button_unhover)

func _on_settings_button_pressed():
	_animate_button_click(_open_settings)

func _open_settings():
	print("Settings button: Opening GameSettings")
	var game_settings: Control = _find_game_settings()
	if game_settings:
		# Toggle behavior: if already visible, hide and unpause; else show and pause
		if game_settings.visible:
			print("Settings button: GameSettings already visible, hiding instead")
			game_settings.hide_settings()
		else:
			print("Settings button: Showing GameSettings")
			game_settings.show_settings()
	else:
		print("SettingsButton: ERROR -> GameSettings node not found anywhere")

func _find_game_settings() -> Control:
	# First try sibling path
	var gs = get_node_or_null("../GameSettings")
	if gs and gs is Control:
		return gs
	# Fallback: search the scene tree for a node named GameSettings
	var root = get_tree().get_root()
	var found = root.find_child("GameSettings", true, false)
	if found and found is Control:
		return found
	return null

func _on_button_hover():
	if is_transitioning or not settings_button:
		return
	var hover_tween = create_tween()
	hover_tween.tween_property(settings_button, "scale", original_scale * 1.1, 0.1)

func _on_button_unhover():
	if is_transitioning or not settings_button:
		return
	var unhover_tween = create_tween()
	unhover_tween.tween_property(settings_button, "scale", original_scale, 0.1)

func _animate_button_click(callback: Callable):
	if is_transitioning or not settings_button:
		return
	is_transitioning = true
	var click_tween = create_tween()
	click_tween.tween_property(settings_button, "scale", original_scale * 0.9, 0.05)
	click_tween.tween_property(settings_button, "scale", original_scale, 0.05)
	click_tween.tween_callback(func():
		is_transitioning = false
		callback.call()
	)
