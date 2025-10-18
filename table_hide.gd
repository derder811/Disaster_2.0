extends Area2D

signal player_hidden(table_name: String)
signal player_unhidden(table_name: String)

@onready var interaction_area: InteractionArea = $InteractionArea
var is_player_hidden: bool = false

func _ready():
	# Allow EarthquakeQuest to find all tables easily
	add_to_group("table_hide")
	if interaction_area:
		interaction_area.action_name = "hide under table"
		interaction_area.interact = Callable(self, "_on_interact")
		print("TableHide: InteractionArea configured for hiding")
	else:
		print("TableHide: ERROR - InteractionArea not found on table")

func _on_interact():
	var player = get_tree().get_first_node_in_group("Player2")
	if not player:
		print("TableHide: ERROR - Player2 not found in scene")
		return
	
	if not is_player_hidden:
		_hide_player(player)
	else:
		_unhide_player(player)

func _hide_player(player: Node):
	# Move player near/under the table for clarity
	if player and player.has_method("set_global_position"):
		player.global_position = global_position + Vector2(0, 0)
	
	# Hide visuals and stop movement
	if "visible" in player:
		player.visible = false
	if player.has_method("set_physics_process"):
		player.set_physics_process(false)
	
	# Update interaction prompt and state
	is_player_hidden = true
	if interaction_area:
		interaction_area.action_name = "come out"
	print("TableHide: Player is now hidden under the table")
	
	# Notify quests
	emit_signal("player_hidden", name)
	
	# Optional self-talk
	var self_talk_nodes = get_tree().get_nodes_in_group("self_talk_system")
	if self_talk_nodes.size() > 0:
		var self_talk_system = self_talk_nodes[0]
		if self_talk_system.has_method("trigger_custom_self_talk"):
			self_talk_system.trigger_custom_self_talk("I'm covered under the table.")

func _unhide_player(player: Node):
	# Show visuals and resume movement
	if "visible" in player:
		player.visible = true
	if player.has_method("set_physics_process"):
		player.set_physics_process(true)
	
	# Update interaction prompt and state
	is_player_hidden = false
	if interaction_area:
		interaction_area.action_name = "hide under table"
	print("TableHide: Player has come out from under the table")
	
	# Notify quests
	emit_signal("player_unhidden", name)
	
	# Optional self-talk
	var self_talk_nodes = get_tree().get_nodes_in_group("self_talk_system")
	if self_talk_nodes.size() > 0:
		var self_talk_system = self_talk_nodes[0]
		if self_talk_system.has_method("trigger_custom_self_talk"):
			self_talk_system.trigger_custom_self_talk("It’s safe, I’ll come out now.")