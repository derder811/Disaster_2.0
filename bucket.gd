extends StaticBody2D

@onready var interaction_area = $InteractionArea
@onready var sprite = $WaterBucket

const lines: Array[String] = [
	"Great... the bucket's full. At least I've got some clean water ready.",
	"Always keep clean water stored in a bucket before a typhoon incase the water supply gets cut off."
]

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
	interaction_area.action_name = "examine water bucket"

func _on_interact():
	# Safety check for overlapping bodies
	var overlapping_bodies = interaction_area.get_overlapping_bodies()
	if overlapping_bodies.size() > 0:
		sprite.flip_h = overlapping_bodies[0].global_position.x < global_position.x
		
		# Use the new DialogManager autoload with asset type for safety tips
		var dialog_position = global_position + Vector2(0, -50)  # Position dialog above water bucket
		DialogManager.start_dialog(dialog_position, lines, "bucket")
		
		# Complete the quest objective for water bucket interaction
		var quest_node = get_node("../Quest")
		if quest_node and quest_node.has_method("on_bucket_interaction"):
			quest_node.on_bucket_interaction()
			print("Water Bucket: Quest objective completed!")
	else:
		# Fallback: use DialogManager directly
		var player_nearby = overlapping_bodies[0] if overlapping_bodies.size() > 0 else null
		if player_nearby:
			var dialog_position = player_nearby.global_position + Vector2(0, -100)
			DialogManager.start_dialog(dialog_position, ["This bucket could be useful for collecting rainwater or storing water.", "Use buckets to collect rainwater for non-drinking purposes like cleaning or flushing toilets."], "bucket")
