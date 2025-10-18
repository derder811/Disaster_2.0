extends Node2D
class_name Player3SelfTalkSystem

# Self-talk messages for Player 3 in the store
var self_talk_messages = {
	"store_entry": [
		"Alright, I'm in the store now. Let me look around and see what I can find.",

	] as Array[String],
	"after_item_interact": {
		"snacks": "Ooh, snacks! Always hard to choose... do I go salty or sweet?",
		"fridge": "Hmm... beverages.",
		"slurpee": "Slurpee! Looks good... but it's way too cold for this right now. Maybe later.",
		"ice_cream_fridge": "Ice cream won't last long without power, but maybe there are other frozen goods.",
		"meat_fridge": "Frozen meat could be useful if I can cook it before the power goes out completely.",
		"hotdog_siopao": "Hotdog or siopao? Man, tough choice. Maybe HotPao?.",
		"food_section": "Let's see what they've got here... canned stuff, quick bites. Pretty standard."
	},
	"movement_comments": [
		"Let me check over here...",
		"What's in this section?",
		"I should look around more carefully.",
		"Maybe there's something useful here.",
		"I need to cover all areas of the store."
	] as Array[String]
}

# Cooldown tracking to prevent spam across all self-talk types
var last_self_talk_ms: int = 0
var movement_comment_cooldown_ms: int = 10000  # 10 seconds
var movement_min_velocity: float = 10.0         # Require player to be moving
# Global cooldown applied to ALL self-talk types (movement, interaction, custom)
var global_self_talk_cooldown_ms: int = 10000   # 10 seconds
# Interaction queue and dedupe to serialize messages triggered by item interactions
var interaction_queue: Array[String] = []
var interaction_processing: bool = false
var _last_item_type: String = ""
var _last_item_type_time_ms: int = 0
var interaction_dedupe_window_ms: int = 1500

var has_shown_entry_message = false
var is_currently_interacting = false
var pending_interaction_self_talk = ""
var interaction_self_talk_timer: Timer

@onready var player = get_parent()

# Unified check to prevent any overlapping dialogs (DialogManager or SimpleDialogManager)
func _is_any_dialog_active() -> bool:
	# Check DialogManager
	if DialogManager and DialogManager.is_dialog_active:
		return true
	# Check SimpleDialogManager
	if SimpleDialogManager and SimpleDialogManager.current_dialog and is_instance_valid(SimpleDialogManager.current_dialog):
		# Visible or actively showing
		if SimpleDialogManager.current_dialog.visible:
			return true
		# SimpleDialog exposes an is_showing flag
		if SimpleDialogManager.current_dialog.is_showing:
			return true
	return false

func _ready():
	# Add this node to a group so it can be found
	add_to_group("player3_self_talk_system")
	
	# Create timer for delayed interaction self-talk
	interaction_self_talk_timer = Timer.new()
	interaction_self_talk_timer.one_shot = true
	interaction_self_talk_timer.timeout.connect(_show_pending_interaction_self_talk)
	add_child(interaction_self_talk_timer)
	
	# Wait a moment for the scene to fully load, then show entry message
	await get_tree().create_timer(2.0).timeout
	show_store_entry_message()

func show_store_entry_message():
	if has_shown_entry_message:
		return
	
	has_shown_entry_message = true
	
	# Show a random entry message
	var messages = self_talk_messages["store_entry"]
	var random_message = messages[randi() % messages.size()]
	
	# Avoid overlapping or spamming; respect global cooldown
	if not _can_show_now():
		# Queue entry message when blocked
		interaction_queue.push_back(random_message)
		is_currently_interacting = true
		_ensure_interaction_processing()
	else:
		_show_dialog_above_player(random_message)

func trigger_after_item_interact_talk(item_type: String):
	# Ensure message only enqueues if player is truly interacting with the asset
	if not _is_interacting_with_item(item_type):
		print("DEBUG: Skipping after_interact talk; not actively interacting with ", item_type)
		return
	
	# Check if we have the after_item_interact category
	if not self_talk_messages.has("after_item_interact"):
		return
	var after_item_interact = self_talk_messages["after_item_interact"]
	if not after_item_interact.has(item_type):
		return
	
	# Dedupe rapid repeated triggers for same item type
	var now_ms: int = Time.get_ticks_msec()
	if item_type == _last_item_type and (now_ms - _last_item_type_time_ms) < interaction_dedupe_window_ms:
		return
	_last_item_type = item_type
	_last_item_type_time_ms = now_ms
	
	var message: String = after_item_interact[item_type]
	interaction_queue.push_back(message)
	is_currently_interacting = true
	_ensure_interaction_processing()

func _wait_for_dialog_and_show_self_talk():
	# Wait until no active dialog AND global cooldown is ready
	while _is_any_dialog_active() or not _cooldown_ready():
		await get_tree().create_timer(0.25).timeout
	
	# Add a small delay to prevent overlap
	await get_tree().create_timer(0.75).timeout
	
	# Show the self-talk if we still have a pending message
	if pending_interaction_self_talk != "":
		_show_dialog_above_player(pending_interaction_self_talk)
		pending_interaction_self_talk = ""
	
	# Reset interaction state after a delay
	await get_tree().create_timer(3.0).timeout
	is_currently_interacting = false

func _cooldown_ready() -> bool:
	return Time.get_ticks_msec() - last_self_talk_ms >= global_self_talk_cooldown_ms

func _can_show_now() -> bool:
	return (not _is_any_dialog_active()) and _cooldown_ready()

# Interactions should bypass the global cooldown and only block on active dialogs
func _can_show_interaction_now() -> bool:
	return not _is_any_dialog_active()

func _show_pending_interaction_self_talk():
	if pending_interaction_self_talk != "" and not _is_any_dialog_active():
		_show_dialog_above_player(pending_interaction_self_talk)
		pending_interaction_self_talk = ""
		
		# Reset interaction state after showing the message
		await get_tree().create_timer(3.0).timeout
		is_currently_interacting = false

func trigger_movement_comment():
	# Don't show movement comments during interactions
	if is_currently_interacting:
		return
	
	# Only show if no dialog of any kind is active
	if _is_any_dialog_active():
		return
	
	# Ensure player reference is valid and inside tree
	if player == null or not is_instance_valid(player) or player.is_queued_for_deletion() or not player.is_inside_tree():
		return
	
	# Global cooldown: only allow movement comment if 10s has passed since any self-talk
	var now: int = Time.get_ticks_msec()
	if now - last_self_talk_ms < movement_comment_cooldown_ms:
		return
	
	# Require player to be moving to avoid idle spam
	if player is CharacterBody2D:
		if player.velocity.length() < movement_min_velocity:
			return
	
	var messages = self_talk_messages["movement_comments"]
	var random_message = messages[randi() % messages.size()]
	_show_dialog_above_player(random_message)

func trigger_custom_self_talk(custom_message: String):
	# Don't show custom self-talk during interactions unless it's from the debug system
	if is_currently_interacting and not "debug system" in custom_message:
		return
	# Prevent overlap with any active dialog and apply global cooldown
	if not _can_show_now():
		return
		
	_show_dialog_above_player(custom_message)

func _show_dialog_above_player(message: String):
	"""Show dialog above the player"""
	print("DEBUG: _show_dialog_above_player called with message: ", message)
	var p = player
	if p == null or not is_instance_valid(p) or p.is_queued_for_deletion() or not p.is_inside_tree():
		print("DEBUG: Player invalid or freed; aborting self-talk display")
		return
	
	print("DEBUG: Player found, calculating dialog position")
	var dialog_position: Vector2
	
	# Try to get the player's sprite for more accurate positioning
	var sprite = p.get_node_or_null("Sprite2D")
	if sprite:
		print("DEBUG: Player sprite found, using sprite-based positioning")
		# Calculate position based on sprite's global position
		# and accounting for its texture height
		var sprite_global_pos = p.to_global(sprite.position)
		var texture_height = 0
		if sprite.texture:
			texture_height = sprite.texture.get_height() * sprite.scale.y
		
		# Position text above the sprite's top edge with more spacing to prevent overlap
		dialog_position = Vector2(sprite_global_pos.x, sprite_global_pos.y - texture_height/2 - 80)
	else:
		print("DEBUG: Player sprite not found, using fallback positioning")
		# Fallback: position above player center with more spacing
		dialog_position = p.global_position + Vector2(0, -120)
	
	# Add some randomization to prevent exact overlap
	dialog_position.x += randf_range(-20, 20)
	
	print("DEBUG: Calling DialogManager.start_dialog at position: ", dialog_position)
	DialogManager.start_dialog(dialog_position, [message])
	# Track last self-talk time (for cooldown)
	last_self_talk_ms = Time.get_ticks_msec()
	print("DEBUG: DialogManager.start_dialog call completed")

func _ensure_interaction_processing():
	if interaction_processing:
		return
	interaction_processing = true
	call_deferred("_process_interaction_queue")

func _process_interaction_queue():
	while interaction_queue.size() > 0:
		# Wait until no active dialog; interactions bypass global cooldown
		while not _can_show_interaction_now():
			await get_tree().create_timer(0.25).timeout
		
		var msg: String = interaction_queue.pop_front()
		_show_dialog_above_player(msg)
		# Wait a bit for auto-close and avoid immediate stacking
		await get_tree().create_timer(2.5).timeout
	
	# Clear interaction state when queue drains
	interaction_processing = false
	await get_tree().create_timer(0.5).timeout
	is_currently_interacting = false

# Add mapping to ensure after_interact messages only show when interacting with the asset
var action_name_by_item_type: Dictionary = {
	"snacks": "examine snacks",
	"fridge": "examine fridge",
	"slurpee": "examine slurpee",
	"ice_cream_fridge": "examine ice cream fridge",
	"meat_fridge": "examine meat fridge",
	"hotdog_siopao": "examine hotdog and siopao",
	"food_section": "examine snacks"
}

func _is_interacting_with_item(item_type: String) -> bool:
	# Validate that the current active InteractionArea corresponds to the item_type
	if typeof(InteractionManager) == TYPE_NIL:
		print("DEBUG: InteractionManager not available; gating failed for ", item_type)
		return false
	var expected: String = action_name_by_item_type.get(item_type, "")
	if expected == "":
		# If we don't have a mapping, allow by default (legacy assets may not set an action name)
		return true
	# InteractionManager.active_areas is sorted by closest; index 0 is the area that was interacted
	if not InteractionManager.active_areas or InteractionManager.active_areas.size() == 0:
		return false
	var closest_area = InteractionManager.active_areas[0]
	if not closest_area:
		return false
	# Safely read action_name; returns null if missing, then cast to String
	var current_action: String = str(closest_area.get("action_name"))
	return current_action == expected

# removed duplicate trigger_after_item_interact_talk; consolidated above with active-area gating
