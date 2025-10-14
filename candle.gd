extends StaticBody2D

@onready var interaction_area = $InteractionArea
@onready var sprite = $Sprite2D

const lines: Array[String] = [
	"I'll use this if the power goes out... but maybe a flashlight is safer. I don't want to cause a fire.",
	"Avoid using candles during a typhoon. Use a flashlight or battery-powered lamp to prevent fire accidents."
]

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
	interaction_area.action_name = "examine candle"

func _on_interact():
	# Safety check for overlapping bodies
	var overlapping_bodies = interaction_area.get_overlapping_bodies()
	if overlapping_bodies.size() > 0:
		sprite.flip_h = overlapping_bodies[0].global_position.x < global_position.x
		
		# Use the new DialogManager autoload with asset type for safety tips
		var dialog_position = global_position + Vector2(0, -50)  # Position dialog above candle
		DialogManager.start_dialog(dialog_position, lines, "candle")
		
		# Complete the quest objective for candle interaction
		var quest_node = get_node("../Quest")
		if quest_node and quest_node.has_method("on_candle_interaction"):
			quest_node.on_candle_interaction()
			print("Candle: Quest objective completed!")
		
		print("Candle: Fire safety tip shown!")
