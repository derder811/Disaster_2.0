extends CharacterBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
var dialog_box_scene: PackedScene = preload("res://Scenes/dialog_box.tscn")
var store_quest_activated: bool = false

func _ready():
	if interaction_area != null:
		interaction_area.action_name = "talk to cashier"
		interaction_area.interact = Callable(self, "_on_interact")
		print("Cashier NPC interaction configured")
	else:
		print("ERROR: InteractionArea not found on Cashier NPC")

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
	var lines: Array[String] = [
		"Hello... Welcome to the store.",
		"Yes we accept Gcash payment"
	]
	# Prefer bottom DialogBox UI for conversation
	var box = _get_dialog_box()
	if box != null and box.has_method("show_dialog"):
		# Connect both finished and closed to show StoreQuest UI
		if box.has_signal("dialog_finished"):
			box.dialog_finished.connect(_on_cashier_dialog_finished)
		if box.has_signal("dialog_closed"):
			box.dialog_closed.connect(_on_cashier_dialog_finished)
		box.show_dialog("CASHIER", lines)
		# Safety fallback: ensure StoreQuest shows even if signals don’t fire
		var safety_timer := Timer.new()
		safety_timer.one_shot = true
		safety_timer.wait_time = 8.0
		safety_timer.timeout.connect(func():
			if not store_quest_activated:
				print("Cashier NPC: safety timer; showing StoreQuest UI")
				_on_cashier_dialog_finished()
		)
		add_child(safety_timer)
		safety_timer.start()
	else:
		# Fallback: use bubble dialog above cashier, then show StoreQuest UI after a short delay
		var pos = global_position + Vector2(0, -120)
		DialogManager.start_dialog(pos, lines)
		var t := Timer.new()
		t.one_shot = true
		t.wait_time = 4.0
		t.timeout.connect(_on_cashier_dialog_finished)
		add_child(t)
		t.start()

func _on_cashier_dialog_finished() -> void:
	if store_quest_activated:
		return
	store_quest_activated = true
	print("Cashier NPC: conversation finished, showing StoreQuest UI")
	_show_store_quest_ui()

func _show_store_quest_ui() -> void:
	var store_quest = get_tree().current_scene.find_child("StoreQuest", true, false)
	if store_quest:
		if store_quest.has_method("start_quest"):
			store_quest.start_quest()
			print("Cashier NPC: StoreQuest started")
		elif store_quest.has_method("show_quest_ui"):
			store_quest.show_quest_ui()
			print("Cashier NPC: StoreQuest UI shown (fallback)")
		else:
			print("Cashier NPC: StoreQuest found but no start_quest/show_quest_ui methods")
	else:
		print("Cashier NPC: StoreQuest node not found in current scene")