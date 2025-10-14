extends Control

@onready var bagContainer = $NinePatchRect
@onready var itemsInContainer = $NinePatchRect/MarginContainer/slotitem

var items = []

func get_items(itemData):
	items.append(itemData)
	print("Item received in bag: ", itemData)
	refresh_ui()

func refresh_ui():
	var allItemSlots = itemsInContainer.get_children()
	print("Number of slots: ", allItemSlots.size())
	print("Number of items: ", items.size())
	
	for i in len(items):
		if i < allItemSlots.size():
			var itemData = items[i]
			if itemData.has("icon") and itemData["icon"] != null:
				allItemSlots[i].texture = itemData["icon"]
				print("Setting slot ", i, " with item: ", itemData["name"])
			else:
				print("Item ", itemData["name"], " has no valid icon")

func _on_texture_button_pressed():
	bagContainer.visible = !bagContainer.visible
	print("Bag visibility toggled: ", bagContainer.visible)
	if bagContainer.visible:
		print("Bag is now visible, showing ", items.size(), " items")
