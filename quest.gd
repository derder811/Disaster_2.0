extends Node

# Quest objectives tracking
var objectives = {
	"interact_efan": false,
	"interact_bucket": false,
	"interact_frying_pan": false
}

# References to UI elements
@onready var objective_checkboxes = []
@onready var objective_labels = []
@onready var quest_box: Control
var original_position: Vector2
var is_quest_box_visible: bool = false

func _ready():
	# Get references to the objective checkboxes and labels in the quest UI
	var objectives_container = get_node("Quest UI/Quest Text Box/Objectives")
	quest_box = get_node("Quest UI/Quest Text Box")
	
	# Store original position and hide quest box initially
	if quest_box:
		original_position = quest_box.position
		hide_quest_box()
	
	if objectives_container:
		print("Quest: Found objectives container with ", objectives_container.get_child_count(), " children")
		for child in objectives_container.get_children():
			if child is HBoxContainer:
				print("Quest: Processing HBoxContainer with ", child.get_child_count(), " children")
				# Find checkbox and label in each HBoxContainer
				for subchild in child.get_children():
					if subchild is CheckBox:
						objective_checkboxes.append(subchild)
						print("Quest: Found checkbox: ", subchild.name)
					elif subchild is Label:
						objective_labels.append(subchild)
						print("Quest: Found label: ", subchild.name)
	
	print("Quest: Total checkboxes found: ", objective_checkboxes.size())
	print("Quest: Total labels found: ", objective_labels.size())
	
	# Set initial objective text
	update_quest_ui()
	
	# Connect to global signals for interactions
	# We'll use a custom signal system for quest completion
	if not has_signal("objective_completed"):
		add_user_signal("objective_completed", [{"name": "objective_name", "type": TYPE_STRING}])

func update_quest_ui():
	# Update the quest UI based on current objectives with 2-word puzzle messages
	var objective_data = [
		{"text": "Fan Safety", "completed": objectives["interact_efan"]},
		{"text": "Water Ready", "completed": objectives["interact_bucket"]},
		{"text": "Fire Prevention", "completed": objectives["interact_frying_pan"]}
	]
	
	print("Quest: Updating UI with ", objective_checkboxes.size(), " checkboxes and ", objective_labels.size(), " labels")
	
	# Update checkboxes and labels with current objective status
	for i in range(min(objective_checkboxes.size(), objective_data.size())):
		if objective_checkboxes[i] and objective_labels[i]:
			print("Quest: Updating checkbox ", i, " - completed: ", objective_data[i]["completed"])
			
			# Update checkbox state
			objective_checkboxes[i].button_pressed = objective_data[i]["completed"]
			
			# Update label text and color
			if objective_data[i]["completed"]:
				objective_labels[i].modulate = Color.GREEN
				# Add strikethrough effect by changing the text appearance
				objective_labels[i].text = "✓ " + objective_data[i]["text"]
				print("Quest: Set label ", i, " to completed state with text: ", objective_labels[i].text)
			else:
				objective_labels[i].modulate = Color.WHITE
				objective_labels[i].text = objective_data[i]["text"]
				print("Quest: Set label ", i, " to pending state with text: ", objective_labels[i].text)
		else:
			print("Quest: Warning - checkbox or label ", i, " is null")

func animate_objective_completion(objective_index: int):
	"""Animate the completion of an objective with smooth transitions"""
	if objective_index >= 0 and objective_index < objective_checkboxes.size():
		var checkbox = objective_checkboxes[objective_index]
		var label = objective_labels[objective_index]
		
		if checkbox and label:
			# Create a tween for smooth animations
			var tween = create_tween()
			tween.set_parallel(true)  # Allow multiple animations to run simultaneously
			
			# 1. Checkbox scaling animation
			checkbox.scale = Vector2(0.8, 0.8)
			tween.tween_property(checkbox, "scale", Vector2(1.2, 1.2), 0.2)
			tween.tween_property(checkbox, "scale", Vector2(1.0, 1.0), 0.2).set_delay(0.2)
			
			# 2. Label color transition animation
			label.modulate = Color.WHITE
			tween.tween_property(label, "modulate", Color.GREEN, 0.4)
			
			# 3. Quest box highlight animation
			if quest_box:
				var original_modulate = quest_box.modulate
				tween.tween_property(quest_box, "modulate", Color(1.2, 1.2, 1.0, 1.0), 0.3)
				tween.tween_property(quest_box, "modulate", original_modulate, 0.3).set_delay(0.3)
			
			# 4. Add a subtle shake effect to the quest box
			animate_quest_box_shake()

func animate_quest_box_shake():
	"""Add a subtle shake animation to the quest box when objective is completed"""
	if quest_box:
		var original_position = quest_box.position
		var tween = create_tween()
		
		# Small shake animation
		tween.tween_property(quest_box, "position", original_position + Vector2(3, 0), 0.05)
		tween.tween_property(quest_box, "position", original_position + Vector2(-3, 0), 0.05)
		tween.tween_property(quest_box, "position", original_position + Vector2(2, 0), 0.05)
		tween.tween_property(quest_box, "position", original_position + Vector2(-2, 0), 0.05)
		tween.tween_property(quest_box, "position", original_position, 0.05)

func complete_objective(objective_name: String):
	if objectives.has(objective_name) and not objectives[objective_name]:
		objectives[objective_name] = true
		print("Quest: Objective completed - ", objective_name)
		
		# Find the index of the completed objective for animation
		var objective_index = -1
		match objective_name:
			"interact_efan":
				objective_index = 0
			"interact_bucket":
				objective_index = 1
			"interact_frying_pan":
				objective_index = 2
		
		# Update UI first
		update_quest_ui()
		
		# Then animate the completion
		if objective_index >= 0:
			animate_objective_completion(objective_index)
		
		# Check if all objectives are complete
		if all_objectives_complete():
			print("Quest: All objectives completed!")
			animate_quest_completion()

func animate_quest_completion():
	"""Special animation when all objectives are completed"""
	if quest_box:
		var tween = create_tween()
		tween.set_parallel(true)
		
		# Pulse animation for the entire quest box
		tween.tween_property(quest_box, "scale", Vector2(1.1, 1.1), 0.3)
		tween.tween_property(quest_box, "scale", Vector2(1.0, 1.0), 0.3).set_delay(0.3)
		
		# Golden glow effect
		tween.tween_property(quest_box, "modulate", Color(1.5, 1.3, 0.8, 1.0), 0.5)
		tween.tween_property(quest_box, "modulate", Color.WHITE, 0.5).set_delay(0.5)

func all_objectives_complete() -> bool:
	for objective in objectives.values():
		if not objective:
			return false
	return true

# Function to be called when player interacts with e_fan
func on_efan_interaction():
	complete_objective("interact_efan")

# Function to be called when player interacts with water bucket
func on_bucket_interaction():
	complete_objective("interact_bucket")

# Function to be called when player interacts with frying pan
func on_frying_pan_interaction():
	complete_objective("interact_frying_pan")

# Function to be called when player interacts with bed
func on_bed_interaction():
	show_quest_box_with_animation()

func toggle_quest_box_visibility():
	"""Toggle quest box visibility - show if hidden, hide if shown"""
	if is_quest_box_visible:
		hide_quest_box()
	else:
		show_quest_box_with_animation()

func hide_quest_box():
	"""Hide the quest box completely"""
	if quest_box:
		quest_box.visible = false
		quest_box.modulate.a = 0.0
		quest_box.scale = Vector2(0.8, 0.8)
		is_quest_box_visible = false

func show_quest_box_with_animation():
	"""Show quest box with pop animation"""
	if quest_box and not is_quest_box_visible:
		is_quest_box_visible = true
		quest_box.visible = true
		
		# Start with small scale and transparent
		quest_box.scale = Vector2(0.3, 0.3)
		quest_box.modulate.a = 0.0
		
		# Create pop animation
		var tween = create_tween()
		tween.set_parallel(true)
		
		# Scale animation with bounce effect
		tween.tween_property(quest_box, "scale", Vector2(1.1, 1.1), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(quest_box, "scale", Vector2(1.0, 1.0), 0.2).set_delay(0.3)
		
		# Fade in animation
		tween.tween_property(quest_box, "modulate:a", 1.0, 0.4)
		
		# Position animation (slide in from side)
		var start_position = original_position + Vector2(-100, 0)
		quest_box.position = start_position
		tween.tween_property(quest_box, "position", original_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

# Global function that can be called from anywhere
func _notification(what):
	if what == NOTIFICATION_READY:
		# Make this quest system globally accessible
		if not Engine.has_singleton("QuestManager"):
			Engine.register_singleton("QuestManager", self)
