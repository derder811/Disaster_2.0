extends StaticBody2D

@onready var interaction_area = $InteractionArea
@onready var sprite = $Sprite2D

const lines: Array[String] = [
	"This is a frying pan - essential for cooking!"
]

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
	interaction_area.action_name = "examine frying pan"

func _on_interact():
	# Safety check for overlapping bodies
	var overlapping_bodies = interaction_area.get_overlapping_bodies()
	if overlapping_bodies.size() > 0:
		sprite.flip_h = overlapping_bodies[0].global_position.x < global_position.x
		
		# Use the new DialogManager autoload with asset type for safety tips
		var dialog_position = global_position + Vector2(0, -50)  # Position dialog above frying pan
		DialogManager.start_dialog(dialog_position, lines, "frying_pan")
		
		# Complete the quest objective for frying pan interaction
		var quest_node = get_node("../Quest")
		if quest_node and quest_node.has_method("on_frying_pan_interaction"):
			quest_node.on_frying_pan_interaction()
			print("Frying Pan: Quest objective completed!")
