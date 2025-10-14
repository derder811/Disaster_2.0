extends StaticBody2D

@onready var interaction_area = $InteractionArea
@onready var sprite = $AnimatedSprite2D

const lines: Array[String] = [
	"It's raining hard... I should check the television to see if there's a typhoon warning.",
	"Stay away from windows during a typhoon. Strong winds can shatter glass or blow debris inside, so it's safest to stay in the inner part of the house."
]

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
	interaction_area.action_name = "examine window"

func _on_interact():
	# Safety check for overlapping bodies
	var overlapping_bodies = interaction_area.get_overlapping_bodies()
	if overlapping_bodies.size() > 0:
		sprite.flip_h = overlapping_bodies[0].global_position.x < global_position.x
		
		# Use the new DialogManager autoload with asset type for safety tips
		var dialog_position = global_position + Vector2(0, -50)  # Position dialog above window
		DialogManager.start_dialog(dialog_position, lines, "window")
		
		# Complete the quest objective for window interaction
		var quest_node = get_node("../Quest")
		if quest_node and quest_node.has_method("on_window_interaction"):
			quest_node.on_window_interaction()
			print("Window: Quest objective completed!")
		
		print("Window: Safety tip shown!")
