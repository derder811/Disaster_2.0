extends StaticBody2D

@onready var interaction_area = $InteractionArea
@onready var sprite = $Sprite2D

const lines: Array[String] = [
	
"This is a comfortable bed - essential for rest!"
	
]

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
	interaction_area.action_name = "examine bed"

func _on_interact():
	# Safety check for overlapping bodies
	var overlapping_bodies = interaction_area.get_overlapping_bodies()
	if overlapping_bodies.size() > 0:
		sprite.flip_h = overlapping_bodies[0].global_position.x < global_position.x
		
		# Show text message without dialog box (no asset_type parameter)
		var dialog_position = global_position + Vector2(0, -50)  # Position text above bed
		DialogManager.start_dialog(dialog_position, lines)
		
		# Show quest box when interacting with bed
		var quest_node = get_node("../Quest")
		if quest_node and quest_node.has_method("on_bed_interaction"):
			quest_node.on_bed_interaction()
			print("Bed: Quest box shown!")
