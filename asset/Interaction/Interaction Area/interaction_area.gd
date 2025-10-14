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
	print("InteractionArea: Body entered - ", body.name, " (groups: ", body.get_groups(), ")")
	
	if body.is_in_group("Player2"):
		print("InteractionArea: Player2 detected, registering with InteractionManager")
		InteractionManager.register_area(self)
	else:
		print("InteractionArea: Body is not in Player2 group")

func _on_body_exited(body):
	print("InteractionArea: Body exited - ", body.name)
	
	if body.is_in_group("Player2"):
		print("InteractionArea: Player2 left, unregistering from InteractionManager")
		InteractionManager.unregister_area(self)
