extends StaticBody2D

@onready var interaction_area = $InteractionArea
@onready var sprite = $Sprite2D

const lines: Array[String] = [
	"Good, my emergency bag's here. I'll start packing the essentials in case we need to leave later.",
	"Prepare a Go Bag with water, food, medicine, flashlight, batteries, and important documents for quick evacuation."
]

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
	interaction_area.action_name = "examine go bag"

func _on_interact():
	# Safety check for overlapping bodies
	var overlapping_bodies = interaction_area.get_overlapping_bodies()
	if overlapping_bodies.size() > 0:
		sprite.flip_h = overlapping_bodies[0].global_position.x < global_position.x
		# Use the new DialogManager autoload with asset type for safety tips
		var dialog_position = global_position + Vector2(0, -50)  # Position dialog above go bag
		DialogManager.start_dialog(dialog_position, lines, "go_bag")		
		# Complete the quest objective for go bag interaction
		var quest_node = get_node("../Quest")
		if quest_node and quest_node.has_method("on_go_bag_interaction"):
			quest_node.on_go_bag_interaction()
			print("Go Bag: Quest objective completed!")
