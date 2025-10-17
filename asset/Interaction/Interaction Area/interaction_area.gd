class_name InteractionArea
extends Area2D

@export var action_name: String = "interact"

var interact: Callable = func():
	pass

func _ready():
	print("InteractionArea ready: ", action_name)
	print("Collision layer: ", collision_layer)
	print("Collision mask: ", collision_mask)
	
	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	print("Signals connected for InteractionArea: ", action_name)

func _on_body_entered(body):
	print("InteractionArea: Body entered - ", body.name, " | Groups: ", body.get_groups())
	
	# Check if body has collision_layer property (CharacterBody2D, RigidBody2D, etc.)
	var collision_info = "No collision_layer"
	if body.has_method("get") and "collision_layer" in body:
		collision_info = str(body.collision_layer)
	elif body is CharacterBody2D or body is RigidBody2D or body is StaticBody2D:
		collision_info = str(body.collision_layer)
	
	print("InteractionArea: Body collision_layer: ", collision_info)
	print("InteractionArea: My collision_mask: ", collision_mask)
	print("InteractionArea: Checking if body is in Player2 group: ", body.is_in_group("Player2"))
	
	if body.is_in_group("Player2"):
		print("InteractionArea: Player2 detected! Registering with InteractionManager")
		InteractionManager.register_area(self)
	else:
		print("InteractionArea: Body not in Player2 group, ignoring")

func _on_body_exited(body):
	print("InteractionArea: Body exited - ", body.name, " | Groups: ", body.get_groups())
	if body.is_in_group("Player2"):
		print("InteractionArea: Player2 exited! Unregistering from InteractionManager")
		InteractionManager.unregister_area(self)
	else:
		print("InteractionArea: Non-Player2 body exited, ignoring")
