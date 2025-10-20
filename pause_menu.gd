extends CanvasLayer

@onready var background := $Background
@onready var popup := $Background/PopupPanel
@onready var menu_container := $Background/PopupPanel/MenuContainer
@onready var resume_button := $Background/PopupPanel/MenuContainer/ResumeButton
@onready var settings_button := $Background/PopupPanel/MenuContainer/SettingsButton
@onready var exit_button := $Background/PopupPanel/MenuContainer/ExitButton

var original_scales := {}
var fade_tween: Tween
var is_paused := false

func _ready() -> void:
	# Start hidden; ensure buttons are not blocking when hidden
	if background:
		background.visible = false
	if menu_container:
		menu_container.visible = false
	# Cache original scales for hover effects
	if resume_button:
		original_scales[resume_button] = resume_button.scale
	if settings_button:
		original_scales[settings_button] = settings_button.scale
	if exit_button:
		original_scales[exit_button] = exit_button.scale
	# Connect BUTTON actions (works for mouse and touch)
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if exit_button:
		exit_button.pressed.connect(_on_exit_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	# Ensure pause menu processes input when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func _handle_hover(pos: Vector2) -> void:
	for b in [resume_button, settings_button, exit_button]:
		if b and b.get_global_rect().has_point(pos):
			b.scale = original_scales.get(b, b.scale) * 1.1
		elif b:
			b.scale = original_scales.get(b, b.scale)

func _handle_tap(pos: Vector2) -> void:
	for b in [resume_button, settings_button, exit_button]:
		if b and b.get_global_rect().has_point(pos):
			b.emit_signal("pressed")
			break

func _show_menu() -> void:
	if background:
		background.visible = true
		background.modulate.a = 0.0
	if menu_container:
		menu_container.visible = true
	if resume_button:
		resume_button.visible = true
	if settings_button:
		settings_button.visible = true
	if exit_button:
		exit_button.visible = true

func _hide_menu() -> void:
	if menu_container:
		menu_container.visible = false
	if background:
		background.visible = false
	if resume_button:
		resume_button.visible = false
	if settings_button:
		settings_button.visible = false
	if exit_button:
		exit_button.visible = false

func _fade_in_menu() -> void:
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()
	fade_tween = create_tween()
	if background:
		fade_tween.tween_property(background, "modulate:a", 1.0, 0.15)
		await fade_tween.finished

func _fade_out_menu() -> void:
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()
	fade_tween = create_tween()
	if background:
		fade_tween.tween_property(background, "modulate:a", 0.0, 0.15)
		await fade_tween.finished

func _input(event: InputEvent) -> void:
	if is_paused:
		if event is InputEventMouseMotion:
			_handle_hover(get_viewport().get_mouse_position())
		elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_handle_tap(event.position)
		elif event is InputEventScreenTouch and event.pressed:
			_handle_tap(event.position)

func _on_resume_pressed() -> void:
	resume_game()

func _on_exit_pressed() -> void:
	_exit_to_main_menu()

func _on_settings_pressed() -> void:
	_open_settings()

func pause_game() -> void:
	# Elevate pause UI and block other overlays by z-order; also disable their mouse capture
	_get_mobile_controls_blocking(true)
	_get_interaction_ui_blocking(true)
	_get_dialog_box_blocking(true)
	get_tree().paused = true
	is_paused = true
	_show_menu()
	_fade_in_menu()

func resume_game() -> void:
	get_tree().paused = false
	is_paused = false
	_fade_out_menu()
	_hide_menu()
	_get_mobile_controls_blocking(false)
	_get_interaction_ui_blocking(false)
	_get_dialog_box_blocking(false)


# --- Overlay management -----------------------------------------------------
func _get_mobile_controls() -> Node:
	var root := get_tree().root
	return root.get_node_or_null("MobileControls")

func _get_interaction_ui() -> Node:
	var root := get_tree().root
	return root.get_node_or_null("InteractionUI")

func _get_dialog_box() -> Node:
	var root := get_tree().root
	return root.get_node_or_null("DialogBox")

func _get_mobile_controls_blocking(block: bool) -> void:
	var mc := _get_mobile_controls()
	if mc:
		var ui_root := mc.get_node_or_null("UIRoot")
		if ui_root:
			ui_root.visible = not block
			ui_root.mouse_filter = Control.MOUSE_FILTER_IGNORE if block else Control.MOUSE_FILTER_STOP
			var interact := ui_root.get_node_or_null("InteractButton")
			if interact:
				interact.mouse_filter = Control.MOUSE_FILTER_IGNORE if block else Control.MOUSE_FILTER_STOP
			var joystick := ui_root.get_node_or_null("Joystick")
			if joystick:
				for c in [joystick, joystick.get_node_or_null("Base"), joystick.get_node_or_null("Knob")]:
					if c:
						c.mouse_filter = Control.MOUSE_FILTER_IGNORE if block else Control.MOUSE_FILTER_STOP

func _get_interaction_ui_blocking(block: bool) -> void:
	var iu := _get_interaction_ui()
	if iu:
		var ui_root := iu.get_node_or_null("UIRoot")
		if ui_root:
			ui_root.mouse_filter = Control.MOUSE_FILTER_IGNORE if block else Control.MOUSE_FILTER_STOP
			ui_root.visible = not block

func _get_dialog_box_blocking(block: bool) -> void:
	var db := _get_dialog_box()
	if db:
		var dlg := db.get_node_or_null("DialogControl")
		if dlg:
			dlg.mouse_filter = Control.MOUSE_FILTER_IGNORE if block else Control.MOUSE_FILTER_STOP
			dlg.visible = not block

# --- Settings opening -------------------------------------------------------
func _open_settings() -> void:
	# Try local scene first, then viewport root
	var gs := get_node_or_null("../GameSettings")
	if not gs:
		gs = get_tree().root.get_node_or_null("GameSettings")
	if gs and gs.has_method("open"):
		gs.open()

func _exit_to_main_menu() -> void:
	get_tree().paused = false
	var candidates := [
		"res://asset/button/Menu/main_menu.tscn",
		"res://GAME SELECTION.tscn",
		"res://game_selection.tscn"
	]
	for path in candidates:
		if ResourceLoader.exists(path):
			get_tree().change_scene_to_file(path)
			return
	# Fallback: quit if no menu scene found
	get_tree().quit()
