extends Node2D

# Get player from group "Player"
@onready var player = get_tree().get_first_node_in_group("Player2")

# Store label reference
@onready var label = $Label

# Constants
const BASE_TEXT = "Press (E) to  "

# Variables
var active_areas: Array = []
var can_interact = true

func _ready():
	print("=== InteractionManager _ready() ===")
	print("InteractionManager ready. Player found: ", player != null)
	if player and is_instance_valid(player):
		print("Player position: ", player.global_position)
		print("Player groups: ", player.get_groups())
		print("Player collision_layer: ", player.collision_layer)
		print("Player collision_mask: ", player.collision_mask)
	else:
		print("ERROR: Player not found in Player2 group!")
	print("Label reference: ", label != null)
	if label and is_instance_valid(label):
		print("Label initial position: ", label.global_position)
		print("Label initial visibility: ", label.visible)
	print("=== End InteractionManager _ready() ===")

# Functions
func register_area(area: InteractionArea):
	print("=== InteractionManager: REGISTERING AREA ===")
	print("Area name: ", area.action_name)
	if area and is_instance_valid(area):
		print("Area position: ", area.global_position)
	print("Current active areas count: ", active_areas.size())
	active_areas.append(area)
	print("New active areas count: ", active_areas.size())
	print("=== End register area ===")

func unregister_area(area: InteractionArea):
	print("=== InteractionManager: UNREGISTERING AREA ===")
	print("Area name: ", area.action_name)
	print("Current active areas count: ", active_areas.size())
	var index = active_areas.find(area)
	if index != -1:
		active_areas.remove_at(index)
		print("Area removed. New count: ", active_areas.size())
	else:
		print("ERROR: Area not found in active_areas!")
	print("=== End unregister area ===")

func sort_by_distance_to_player(a, b):
	if not player or not is_instance_valid(player) or not a or not is_instance_valid(a) or not b or not is_instance_valid(b):
		return false
	var distance_a = player.global_position.distance_to(a.global_position)
	var distance_b = player.global_position.distance_to(b.global_position)
	return distance_a < distance_b

func _process(delta):
	if active_areas.size() > 0 and can_interact:
		# Sort by distance
		active_areas.sort_custom(sort_by_distance_to_player)
		
		# Show the interaction prompt for the closest area
		var closest_area = active_areas[0]
		if closest_area and is_instance_valid(closest_area):
			label.text = BASE_TEXT + closest_area.action_name
			label.visible = true
			
			# Position label near the interactable object instead of above the player
			if closest_area and is_instance_valid(closest_area):
				label.global_position = closest_area.global_position + Vector2(0, -40)
		
		# Only print occasionally to avoid spam
		if Engine.get_process_frames() % 60 == 0:  # Every 60 frames (1 second at 60fps)
			if closest_area and is_instance_valid(closest_area):
				print("InteractionManager: Showing prompt for - ", closest_area.action_name, " at ", closest_area.global_position)
	else:
		# Hide label
		if label.visible:
			print("InteractionManager: Hiding label (active_areas: ", active_areas.size(), ", can_interact: ", can_interact, ")")
		label.visible = false

func _input(event):
	# Check if E key is pressed
	if event.is_action_pressed("interact") or (event is InputEventKey and event.pressed and event.keycode == KEY_E):
		if active_areas.size() > 0:
			print("InteractionManager: E key pressed, calling interact on: ", active_areas[0].action_name)
			can_interact = false
			label.visible = false
			await active_areas[0].interact.call()
			can_interact = true
			
			# Show automatic self-talk message after interaction
			_show_post_interaction_self_talk()

# Function to show self-talk messages after interactions
func _show_post_interaction_self_talk():
	# Wait a moment for any existing dialogs to finish
	await get_tree().create_timer(2.0).timeout
	
	# Try to find the self-talk system in the player
	var self_talk_system = null
	if player:
		self_talk_system = player.get_node_or_null("SelfTalkSystem")
	
	if not self_talk_system:
		# Try to find it by group
		var self_talk_nodes = get_tree().get_nodes_in_group("self_talk_system")
		if self_talk_nodes.size() > 0:
			self_talk_system = self_talk_nodes[0]
	
	if self_talk_system and self_talk_system.has_method("show_post_interaction_self_talk"):
		self_talk_system.show_post_interaction_self_talk()
	else:
		# Fallback: show a simple self-talk message directly
		_show_fallback_self_talk()

func _show_fallback_self_talk():
	var self_talk_messages = [
		"That was informative! I should remember these safety tips.",
		"Good to know! This could be really useful in an emergency.",
		"I'm learning so much about disaster preparedness.",
		"These safety measures could save lives in a real disaster.",
		"I should share this knowledge with my family and friends."
	]
	
	var random_message = self_talk_messages[randi() % self_talk_messages.size()]
	
	if player and is_instance_valid(player):
		# Get the player's sprite position for accurate text positioning
		var sprite = player.get_node("Sprite2D")
		var sprite_position = player.global_position
		if sprite:
			sprite_position = player.global_position + sprite.position
		
		# Position the text above the player's head (sprite top)
		var dialog_position = sprite_position + Vector2(0, -80)
		DialogManager.start_dialog(dialog_position, [random_message])
