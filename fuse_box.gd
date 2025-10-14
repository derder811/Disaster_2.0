extends StaticBody2D

@onready var interaction_area = $InteractionArea
@onready var sprite = $Sprite2D

const lines: Array[String] = [
	"The rain's starting to get heavier... I have to cut the power to avoid short circuits or getting electrocuted if the water rises, especially when the thunder strikes.",
	"During a typhoon, turn off the main power switch if flooding begins or there's frequent lightning. This helps prevent electrical shocks and fire hazards. Stay dry and use a flashlight instead of touching any wet electrical parts."
]

func _ready():
	print("Fuse Box: Setting up interaction area")
	# Check if sprite node exists
	if sprite == null:
		print("Warning: Sprite2D node not found! Looking for alternative sprite node...")
		# Try to find sprite with different possible names
		sprite = get_node_or_null("Sprite")
		if sprite == null:
			print("Error: No sprite node found in fuse box!")
	
	interaction_area.interact = Callable(self, "_on_interact")
	interaction_area.action_name = "check fuse box"
	print("Fuse Box: Ready for E key interaction!")

func _on_interact():
	print("Fuse Box: E key interaction triggered!")
	# Safety check for overlapping bodies
	var overlapping_bodies = interaction_area.get_overlapping_bodies()
	if overlapping_bodies.size() > 0:
		# Check if sprite exists before accessing flip_h property
		if sprite != null:
			sprite.flip_h = overlapping_bodies[0].global_position.x < global_position.x
		
		# Use the new DialogManager autoload with asset type for safety tips
		var dialog_position = global_position + Vector2(0, -50)  # Position dialog above fuse box
		DialogManager.start_dialog(dialog_position, lines, "fuse_box")
		
		# Complete the quest objective for fuse box interaction
		var quest_node = get_node("../Quest")
		if quest_node and quest_node.has_method("on_fusebox_interaction"):
			quest_node.on_fusebox_interaction()
			print("Fuse Box: Quest objective completed!")
		
		print("Fuse Box: Power safety tip shown!")
	else:
		print("Fuse Box: No overlapping bodies found!")
