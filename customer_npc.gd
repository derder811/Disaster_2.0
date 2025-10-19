extends CharacterBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
var dialog_box_scene: PackedScene = preload("res://Scenes/dialog_box.tscn")

func _ready():
	if interaction_area != null:
		interaction_area.action_name = "talk to customer"
		interaction_area.interact = Callable(self, "_on_interact")
		print("Customer NPC interaction configured")
	else:
		print("ERROR: InteractionArea not found on Customer NPC")

func _get_dialog_box() -> Node:
	# Try to find an existing DialogSystem
	var existing = get_tree().get_first_node_in_group("dialog_system")
	if existing != null and is_instance_valid(existing):
		return existing
	# Otherwise instantiate one
	var inst = dialog_box_scene.instantiate()
	get_tree().root.add_child(inst)
	return inst

func _on_interact() -> void:
	print("Customer NPC: player interacted")
	var lines: Array[String] = [
		"Okay, this section's stacked.",
		"What am I even in the mood for?"
	]
	# Prefer bottom DialogBox UI for conversation
	var box = _get_dialog_box()
	if box != null and box.has_method("show_dialog"):
		box.show_dialog("CUSTOMER", lines)
	else:
		# Fallback: use bubble dialog above customer
		var pos = global_position + Vector2(0, -120)
		DialogManager.start_dialog(pos, lines)