extends Node2D
class_name SelfTalkSystem

# Self-talk messages for different scenarios
var self_talk_messages = {
	"game_start": [
		"Alright, I'm ready to learn about disaster preparedness!",
		"Let me explore this house and see what safety measures I can find.",
		"I should check different rooms and interact with objects to learn more."
	] as Array[String],
	"after_interaction": [
		"That was informative! I should remember these safety tips.",
		"Good to know! This could be really useful in an emergency.",
		"I'm learning so much about disaster preparedness.",
		"These safety measures could save lives in a real disaster.",
		"I should share this knowledge with my family and friends."
	] as Array[String]
}

var has_shown_startup_message = false
@onready var player = get_parent()

func _ready():
	# Add this node to a group so it can be found by the interaction manager
	add_to_group("self_talk_system")
	
	# Wait a moment for the scene to fully load, then show startup message
	await get_tree().create_timer(1.0).timeout
	show_startup_message()

func show_startup_message():
	if has_shown_startup_message:
		return
	
	has_shown_startup_message = true
	
	# Find the DialogBox in the scene
	var dialog_box = get_tree().get_first_node_in_group("dialog_system")
	if dialog_box and dialog_box.has_method("show_dialog"):
		dialog_box.show_dialog("WELCOME", self_talk_messages["game_start"])
		# Connect to the dialog finished signal to show follow-up self-talk
		if not dialog_box.dialog_finished.is_connected(_on_startup_dialog_finished):
			dialog_box.dialog_finished.connect(_on_startup_dialog_finished)
	else:
		print("DialogBox not found for startup message")

func _on_startup_dialog_finished():
	# Show a brief self-talk message after the startup dialog
	await get_tree().create_timer(2.0).timeout
	show_self_talk_message()

func show_self_talk_message():
	# Get a random self-talk message
	var messages = self_talk_messages["after_interaction"]
	var random_message = messages[randi() % messages.size()]
	
	if player and is_instance_valid(player):
		# Get the player's sprite for accurate text positioning
		var sprite = player.get_node_or_null("Sprite2D")
		var dialog_position = player.global_position
		
		if sprite:
			# Calculate the top of the sprite by using the sprite's global position
			# and accounting for its texture height
			var sprite_global_pos = player.to_global(sprite.position)
			var texture_height = 0
			if sprite.texture:
				texture_height = sprite.texture.get_height() * sprite.scale.y
			
			# Position text above the sprite's top edge
			dialog_position = Vector2(sprite_global_pos.x, sprite_global_pos.y - texture_height/2 - 50)
		else:
			# Fallback: position above player center
			dialog_position = player.global_position + Vector2(0, -100)
		
		DialogManager.start_dialog(dialog_position, [random_message])

# Function to be called after object interactions
func show_post_interaction_self_talk():
	# Wait a moment after interaction completes
	await get_tree().create_timer(1.5).timeout
	show_self_talk_message()

# Function to trigger custom self-talk with a specific message
func trigger_custom_self_talk(custom_message: String):
	if player and is_instance_valid(player):
		# Get the player's sprite for accurate text positioning
		var sprite = player.get_node_or_null("Sprite2D")
		var dialog_position = player.global_position
		
		if sprite:
			# Calculate the top of the sprite by using the sprite's global position
			# and accounting for its texture height
			var sprite_global_pos = player.to_global(sprite.position)
			var texture_height = 0
			if sprite.texture:
				texture_height = sprite.texture.get_height() * sprite.scale.y
			
			# Position text above the sprite's top edge
			dialog_position = Vector2(sprite_global_pos.x, sprite_global_pos.y - texture_height/2 - 50)
		else:
			# Fallback: position above player center
			dialog_position = player.global_position + Vector2(0, -100)
		
		DialogManager.start_dialog(dialog_position, [custom_message])

# Function to trigger self-talk from external sources
func trigger_self_talk(message_type: String = "after_interaction"):
	if message_type in self_talk_messages:
		var messages = self_talk_messages[message_type]
		var random_message = messages[randi() % messages.size()]
		
		if player and is_instance_valid(player):
			# Get the player's sprite for accurate text positioning
			var sprite = player.get_node_or_null("Sprite2D")
			var dialog_position = player.global_position
			
			if sprite:
				# Calculate the top of the sprite by using the sprite's global position
				# and accounting for its texture height
				var sprite_global_pos = player.to_global(sprite.position)
				var texture_height = 0
				if sprite.texture:
					texture_height = sprite.texture.get_height() * sprite.scale.y
				
				# Position text above the sprite's top edge
				dialog_position = Vector2(sprite_global_pos.x, sprite_global_pos.y - texture_height/2 - 50)
			else:
				# Fallback: position above player center
				dialog_position = player.global_position + Vector2(0, -100)
			
			DialogManager.start_dialog(dialog_position, [random_message])
