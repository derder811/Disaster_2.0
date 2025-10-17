extends Area2D

@onready var interaction_area = $InteractionArea

func _ready():
	print("Store Entrance: Setting up interaction area")
	
	# Connect the area entered signal for player detection
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Set up interaction area if it exists
	if interaction_area:
		interaction_area.interact = Callable(self, "_on_interact")
		interaction_area.action_name = "Go Inside"
		print("Store Entrance: Ready for E key interaction!")
	else:
		print("Warning: InteractionArea not found in Store Entrance")

func _on_body_entered(body):
	print("Store Entrance: Body entered - ", body.name)
	if body.is_in_group("Player2"):
		print("Store Entrance: Player detected, registering interaction")
		if interaction_area:
			InteractionManager.register_area(interaction_area)

func _on_body_exited(body):
	print("Store Entrance: Body exited - ", body.name)
	if body.is_in_group("Player2"):
		print("Store Entrance: Player left, unregistering interaction")
		if interaction_area:
			InteractionManager.unregister_area(interaction_area)

func _on_interact():
	print("Store Entrance: E key interaction triggered!")
	
	# Get overlapping bodies to check if player is still in range
	var overlapping_bodies = get_overlapping_bodies()
	if overlapping_bodies.size() > 0:
		var player = null
		for body in overlapping_bodies:
			if body.is_in_group("Player2"):
				player = body
				break
		
		if player:
			print("Store Entrance: Player confirmed, transitioning to inside_the_store scene")
			# Transition to the inside store scene
			get_tree().change_scene_to_file("res://inside_the_store.tscn")
		else:
			print("Store Entrance: No player found in overlapping bodies")
	else:
		print("Store Entrance: No overlapping bodies found")