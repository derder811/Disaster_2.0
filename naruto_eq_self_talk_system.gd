extends Node2D
class_name NarutoEQSelfTalkSystem

# Self-talk messages for Naruto EQ player
var self_talk_messages = {
	"convenience_store": [
		"Oh hey, a convenience store. Might as well take a look.",
		"Could use a quick break… maybe grab a drink or something."
	] as Array[String],
	"timer_based": [
		"Oh hey, a convenience store. Might as well take a look.",
		"Could use a quick break… maybe grab a drink or something."
	] as Array[String]
}

var has_shown_startup_message = false
var timer_self_talk_active = false
var current_message_index = 0
@onready var player = get_parent()

func _ready():
	print("NarutoEQSelfTalkSystem: _ready() called")
	# Get reference to the player (parent node)
	player = get_parent()
	print("NarutoEQSelfTalkSystem: Player reference set to: ", player)
	
	# Check if DialogManager is available
	if DialogManager:
		print("NarutoEQSelfTalkSystem: DialogManager found successfully")
	else:
		print("NarutoEQSelfTalkSystem: ERROR - DialogManager not found!")
	
	# Show first message after 5 seconds
	await get_tree().create_timer(5.0).timeout
	print("NarutoEQSelfTalkSystem: Showing first message...")
	show_specific_message(0)  # Show first message
	
	# Show second message after 10 more seconds
	await get_tree().create_timer(10.0).timeout
	print("NarutoEQSelfTalkSystem: Showing second message...")
	show_specific_message(1)  # Show second message
	
	# Start regular timer-based self talk after that
	await get_tree().create_timer(2.0).timeout
	print("NarutoEQSelfTalkSystem: Starting timer self talk")
	start_timer_self_talk()

func start_timer_self_talk():
	print("NarutoEQSelfTalkSystem: start_timer_self_talk() called")
	timer_self_talk_active = true
	_timer_self_talk_loop()

func stop_timer_self_talk():
	print("NarutoEQSelfTalkSystem: stop_timer_self_talk() called")
	timer_self_talk_active = false

func _timer_self_talk_loop():
	print("NarutoEQSelfTalkSystem: _timer_self_talk_loop() started")
	while timer_self_talk_active:
		await get_tree().create_timer(10.0).timeout  # Reduced to 10 seconds for testing
		print("NarutoEQSelfTalkSystem: Timer expired, checking conditions...")
		
		if timer_self_talk_active and player and is_instance_valid(player):
			print("NarutoEQSelfTalkSystem: Player valid, checking DialogManager...")
			# Check if there's no active dialog before showing timer-based self talk
			if DialogManager and not DialogManager.is_dialog_active:
				print("NarutoEQSelfTalkSystem: Showing timer self talk")
				show_timer_self_talk()
			else:
				print("NarutoEQSelfTalkSystem: DialogManager busy or not available")

# Function to show a specific message by index
func show_specific_message(message_index: int):
	print("NarutoEQSelfTalkSystem: show_specific_message() called with index: ", message_index)
	
	if not player or not is_instance_valid(player):
		print("NarutoEQSelfTalkSystem: ERROR - Player not found or invalid")
		return
	
	if not DialogManager:
		print("NarutoEQSelfTalkSystem: ERROR - DialogManager not available")
		return
	
	var messages = self_talk_messages["timer_based"]
	if message_index >= messages.size():
		print("NarutoEQSelfTalkSystem: ERROR - Message index out of bounds")
		return
	
	var message = messages[message_index]
	print("NarutoEQSelfTalkSystem: Selected message: ", message)
	
	if player and is_instance_valid(player):
		print("NarutoEQSelfTalkSystem: Player found, calculating position...")
		# Get the player's sprite for accurate text positioning
		var sprite = player.get_node_or_null("Sprite2D")
		var dialog_position = player.global_position
		
		if sprite:
			print("NarutoEQSelfTalkSystem: Sprite found, calculating position above sprite")
			# Calculate the top of the sprite by using the sprite's global position
			# and accounting for its texture height
			var sprite_global_pos = player.to_global(sprite.position)
			var texture_height = 0
			if sprite.texture:
				texture_height = sprite.texture.get_height() * sprite.scale.y
			
			# Position text above the sprite's top edge
			dialog_position = Vector2(sprite_global_pos.x, sprite_global_pos.y - texture_height/2 - 50)
		else:
			print("NarutoEQSelfTalkSystem: No sprite found, using fallback position")
			# Fallback: position above player center
			dialog_position = player.global_position + Vector2(0, -100)
		
		print("NarutoEQSelfTalkSystem: Final dialog position: ", dialog_position)
		print("NarutoEQSelfTalkSystem: Calling DialogManager.start_dialog...")
		DialogManager.start_dialog(dialog_position, [message])
		print("NarutoEQSelfTalkSystem: DialogManager.start_dialog called successfully")

func show_timer_self_talk():
	print("NarutoEQSelfTalkSystem: show_timer_self_talk() called")
	# Get a random timer-based self-talk message
	var messages = self_talk_messages["timer_based"]
	var random_message = messages[randi() % messages.size()]
	print("NarutoEQSelfTalkSystem: Selected message: ", random_message)
	
	if player and is_instance_valid(player):
		print("NarutoEQSelfTalkSystem: Player found, calculating position...")
		# Get the player's sprite for accurate text positioning
		var sprite = player.get_node_or_null("Sprite2D")
		var dialog_position = player.global_position
		
		if sprite:
			print("NarutoEQSelfTalkSystem: Sprite found, calculating position above sprite")
			# Calculate the top of the sprite by using the sprite's global position
			# and accounting for its texture height
			var sprite_global_pos = player.to_global(sprite.position)
			var texture_height = 0
			if sprite.texture:
				texture_height = sprite.texture.get_height() * sprite.scale.y
			
			# Position text above the sprite's top edge
			dialog_position = Vector2(sprite_global_pos.x, sprite_global_pos.y - texture_height/2 - 50)
		else:
			print("NarutoEQSelfTalkSystem: No sprite found, using fallback position")
			# Fallback: position above player center
			dialog_position = player.global_position + Vector2(0, -100)
		
		print("NarutoEQSelfTalkSystem: Final dialog position: ", dialog_position)
		print("NarutoEQSelfTalkSystem: Calling DialogManager.start_dialog...")
		DialogManager.start_dialog(dialog_position, [random_message])
		print("NarutoEQSelfTalkSystem: DialogManager.start_dialog called successfully")

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

# Function to trigger convenience store self-talk
func trigger_convenience_store_self_talk():
	var messages = self_talk_messages["convenience_store"]
	var random_message = messages[randi() % messages.size()]
	trigger_custom_self_talk(random_message)

# Function to trigger self-talk from external sources
func trigger_self_talk(message_type: String = "timer_based"):
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