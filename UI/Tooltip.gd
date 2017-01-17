extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal done_resizing

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
	#yield(get_tree(), "idle_frame")
	

func set_info(title, text, modifier_descriptions):
	get_node("Panel/Label").set_text(title.to_upper())
	if modifier_descriptions.keys() != []:
		for key in modifier_descriptions.keys():
			var modifier_description = "\n\n" + key + ": " + modifier_descriptions[key]
			print(modifier_description)
			print(text)
			text += modifier_description
	
	get_node("Panel/Text").set_bbcode(text)
	yield(get_tree(), "idle_frame") #WHY THE FUCK DO I NEED THIS HERE WHAT THE FUUUUUUUCK
	var text_node = get_node("Panel/Text")
	yield(get_tree(), "idle_frame")
	var height = text_node.get_v_scroll().get_max()
	yield(get_tree(), "idle_frame")
	text_node.set_size(Vector2(text_node.get_size().width, height))
	yield(get_tree(), "idle_frame")
	get_node("Panel").set_size(text_node.get_size() + Vector2(15, 45))