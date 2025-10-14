extends Node

@onready var dialog_scene = preload("res://SimpleDialog.tscn")
var current_dialog = null

# Safety tips for different items
var safety_tips = {
	"phone": "Keep your phone charged and have a backup power source. Store emergency contacts and download offline maps.",
	"battery": "Always keep extra batteries for flashlights and radios. Check expiration dates regularly.",
	"powerbank": "Keep power banks fully charged as backup power sources for essential devices during outages.",
	"flashlight": "Keep a working flashlight ready at all times. Check batteries regularly. Avoid using candles during storms.",
	"documents": "Store important documents like IDs and certificates in waterproof containers or bags.",
	"water_bottle": "Store clean bottled water for drinking. You need at least 1 gallon per person per day for 3 days.",
	"canned_food": "Stock up on non-perishable food like canned goods that don't need cooking. Include a manual can opener.",
	"medicine_2": "Keep a well-stocked first aid kit and essential medications. Check expiration dates regularly.",
	"medicine_3": "Store prescription medications in waterproof containers. Keep a list of all medications and dosages.",
	"first_aid_kit": "Maintain a complete first aid kit with bandages, antiseptics, and basic medical supplies.",
	"go_bag": "Prepare an emergency bag with water, food, medicine, flashlight, batteries, and important documents.",
	"candle": "Avoid using candles during storms - use battery-powered lights instead to prevent fire hazards."
}

func show_item_dialog(item_name: String, position: Vector2):
	print("SimpleDialogManager.show_item_dialog called for: ", item_name)
	
	# Close existing dialog if any
	if current_dialog:
		current_dialog.queue_free()
		current_dialog = null
	
	# Get safety tip for this item
	var tip = safety_tips.get(item_name, "No safety information available for this item.")
	var dialog_text = "Item picked up: " + item_name.capitalize() + "\n\nSafety Tip: " + tip
	
	# Create and show dialog
	current_dialog = dialog_scene.instantiate()
	get_tree().root.add_child(current_dialog)
	current_dialog.show_dialog(dialog_text, position)
	
	print("Dialog created and shown")

func hide_current_dialog():
	if current_dialog:
		current_dialog.hide_dialog()
		current_dialog.queue_free()
		current_dialog = null