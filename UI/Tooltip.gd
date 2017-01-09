extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
	#yield(get_tree(), "idle_frame")
	

func set(title, text):
	get_node("Panel/Label").set_text(title.to_upper())
	get_node("Panel/Text").set_bbcode(text)
	var text_node = get_node("Panel/Text")
	text_node.set_size(Vector2(text_node.get_size().width, text_node.get_v_scroll().get_max()))
	get_node("Panel").set_size(text_node.get_size())