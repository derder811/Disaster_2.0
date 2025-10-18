extends Area2D

func _ready():
	# Configure the existing InteractionArea child
	var interaction_area = $InteractionArea
	if interaction_area:
		interaction_area.action_name = "examine slurpee"
		interaction_area.interact = Callable(self, "_on_interact")
		print("Slurpee interaction area configured")
	else:
		print("ERROR: InteractionArea not found in slurpee")

func _on_interact():
	print("DEBUG: _on_interact called in slurpee.gd")
	print("Slurpee machine interacted with!")
	# Earthquake sequence: shake camera, self-talk, then trigger new quest
	_trigger_camera_shake(1.5, 12.0)
	
	# Trigger self-talk for earthquake safety guidance
	var player = get_tree().get_first_node_in_group("Player2")
	print("DEBUG: Found player: ", player != null)
	if player and player.has_method("trigger_item_self_talk"):
		player.trigger_item_self_talk("slurpee")
	else:
		print("DEBUG: Player not found or missing trigger_item_self_talk")
	
	# Trigger the EarthquakeQuest UI and logic
	_trigger_earthquake_quest()
	
	# Update StoreQuest objective (still complete the store quest step)
	var store_quest = get_tree().current_scene.find_child("StoreQuest", true, false)
	if store_quest and store_quest.has_method("on_slurpee_interaction"):
		store_quest.on_slurpee_interaction()

# Simple camera shake using Camera2D offset jitter
func _trigger_camera_shake(duration_sec := 1.5, magnitude := 10.0) -> void:
	# Defer to avoid blocking the interaction flow
	call_deferred("_do_camera_shake", duration_sec, magnitude)

func _do_camera_shake(duration_sec: float, magnitude: float) -> void:
	var camera = get_viewport().get_camera_2d()
	if camera == null:
		print("Camera2D not found; skipping shake")
		return
	var original_offset: Vector2 = camera.offset
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var elapsed := 0.0
	while elapsed < duration_sec:
		camera.offset = Vector2(rng.randf_range(-magnitude, magnitude), rng.randf_range(-magnitude, magnitude))
		await get_tree().create_timer(0.02).timeout
		elapsed += 0.02
	camera.offset = original_offset

func _trigger_earthquake_quest():
	# Avoid duplicating the quest if already present
	var existing = get_tree().current_scene.find_child("EarthquakeQuest", true, false)
	if existing:
		print("EarthquakeQuest already active")
		return
	var quest_res: PackedScene = load("res://earthquake_quest.tscn")
	if quest_res:
		var quest_instance = quest_res.instantiate()
		get_tree().current_scene.add_child(quest_instance)
		print("EarthquakeQuest instantiated")
	else:
		print("ERROR: earthquake_quest.tscn not found")
