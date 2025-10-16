extends StaticBody2D

@onready var interaction_area = $InteractionArea
@onready var sprite = $Sprite2D

const lines: Array[String] = [
	"It's raining nonstop... I'll check the news to see if there's a typhoon signal in our area.",	
]

func _ready():
	print("TV: Setting up interaction area")
	# Check if sprite node exists
	if sprite == null:
		print("Warning: Sprite2D node not found in TV! Looking for alternative sprite node...")
		# Try to find sprite with different possible names
		sprite = get_node_or_null("Sprite")
		if sprite == null:
			print("Error: No sprite node found in TV!")
	
	interaction_area.interact = Callable(self, "_on_interact")
	interaction_area.action_name = "watch TV"
	print("TV: Ready for E key interaction!")

func _on_interact():
	print("TV: E key interaction triggered!")
	# Safety check for overlapping bodies
	var overlapping_bodies = interaction_area.get_overlapping_bodies()
	if overlapping_bodies.size() > 0:
		# Check if sprite exists before accessing flip_h property
		if sprite != null:
			sprite.flip_h = overlapping_bodies[0].global_position.x < global_position.x
		
		# Use the new DialogManager autoload with asset type for safety tips
		var dialog_position = global_position + Vector2(0, -50)  # Position dialog above TV
		DialogManager.start_dialog(dialog_position, lines, "tv")
		
		# Show SimpleDialog safety tips after text box finishes (delay for text box to complete)
		await get_tree().create_timer(5.0).timeout  # Wait for text box to finish
		SimpleDialogManager.show_safety_tips("tv", global_position)
		
		# Trigger self-talk after interaction
		await get_tree().create_timer(2.0).timeout
		var self_talk_nodes = get_tree().get_nodes_in_group("self_talk_system")
		if self_talk_nodes.size() > 0:
			var self_talk_system = self_talk_nodes[0]
			if self_talk_system.has_method("trigger_custom_self_talk"):
				self_talk_system.trigger_custom_self_talk("The storm's getting worse… I should cut the power off.")
		
		# Complete the quest objective for TV interaction
		var quest_node = get_node("../Quest")
		if quest_node and quest_node.has_method("on_tv_interaction"):
			quest_node.on_tv_interaction()
			print("TV: Quest objective completed!")
		
		print("TV: Weather safety tip shown!")
	else:
		print("TV: No overlapping bodies found!")
