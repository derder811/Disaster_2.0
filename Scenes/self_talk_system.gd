extends Node2D
class_name SelfTalkSystem

# Self-talk messages for different scenarios
var self_talk_messages = {
	"game_start": [
		"It's early in the morning. Heavy rain pours outside as strong winds shake the trees. A typhoon is approaching, and you're the only one left at home. Your goal is to stay safe and prepare for the storm by gathering important items and taking the right precautions. Learn what to do before and during a typhoon through each interaction inside the house."
 
	] as Array[String],
	"timer_based": [
		"It's raining hard... gonna check the window.",
		"It's really pouring out there... I hope the roof holds up.",
		"I know I kept some supplies somewhere...",
		"Feels a bit eerie being alone during a storm like this.",
		"I can hear the rain hitting the walls... I need to stay focused and finished preparing."
	] as Array[String],
	"item_pickup": {
		"flashlight": "Good thing the flashlight still works. This will help if the power's out for long.",
		"battery": "Extra batteries—perfect. I'll save these for the flashlight.",
		"documents": "These documents are important... Gonna keep them on my bag",
		"canned_food": "Good thing there are still some canned foods left.",
		"water_bottle": "I'll keep these bottled waters ready... the tap might get contaminated later.",
		"medkit": "Good.. Everything's here — bandages, alcohol, medicine.",
		"medicine_2": "Good thing I still have some antibiotics left... just in case anyone gets an infection after the storm.",
		"medicine_3": "Painkillers and cold meds, these might come in handy if anyone feels sick.",
		"mobile_phone": "Signal's weak... I'll keep my phone on me, just in case of any emergency or updates.",
		"powerbank": "This power bank will be useful to keep my phone charged during emergencies.",
		"go_bag": "Gonna find some food, water, and medicine… anything essential before things get worse.",
		"candle": "I'll use this if the power goes out... but maybe a flashlight is safer. I don't want to cause a fire."
	}
}

var has_shown_startup_message = false
var timer_self_talk_active = false
@onready var player = get_parent()

func _ready():
	# Add this node to a group so it can be found by the interaction manager
	add_to_group("self_talk_system")
	
	# Wait a moment for the scene to fully load, then show startup message
	await get_tree().create_timer(1.0).timeout
	show_startup_message()
	
	# Start the timer-based self talk after startup
	await get_tree().create_timer(2.0).timeout
	start_timer_self_talk()

func start_timer_self_talk():
	timer_self_talk_active = true
	_timer_self_talk_loop()

func stop_timer_self_talk():
	timer_self_talk_active = false

func _timer_self_talk_loop():
	while timer_self_talk_active:
		await get_tree().create_timer(30.0).timeout  # Wait 30 seconds
		
		if timer_self_talk_active and player and is_instance_valid(player):
			# Check if there's no active dialog before showing timer-based self talk
			if not DialogManager.is_dialog_active:
				show_timer_self_talk()

func show_timer_self_talk():
	# Get a random timer-based self-talk message
	var messages = self_talk_messages["timer_based"]
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
	# Always show the first message "It's raining hard... gonna check the window." as the first automatic talk
	var first_message = "It's raining hard... gonna check the window."
	
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
		
		DialogManager.start_dialog(dialog_position, [first_message])

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

# Function to trigger item pickup self-talk
func trigger_item_pickup_self_talk(item_name: String):
	if "item_pickup" in self_talk_messages and item_name in self_talk_messages["item_pickup"]:
		var message = self_talk_messages["item_pickup"][item_name]
		
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
			
			DialogManager.start_dialog(dialog_position, [message])
