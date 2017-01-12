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
	

func set(title, text):
	get_node("Panel/Label").set_text(title.to_upper())
	get_node("Panel/Text").set_bbcode(text)
	#show()
	var text_node = get_node("Panel/Text")
	var height = text_node.get_v_scroll().get_max()
	print(height)
	text_node.set_size(Vector2(text_node.get_size().width, height))
	print(Vector2(text_node.get_size().width, text_node.get_v_scroll().get_max()))
	#text_node.set_size(Vector2(text_node.get_size().width, text_node.get_v_scroll().get_max()))
#	get_node("Timer").set_wait_time(0.8)
#	get_node("Timer").start()
#	yield(get_node("Timer"), "timeout")
	print(text_node.get_size())
	#hide()

func resize():
	var text_node = get_node("Panel/Text")
	
	get_node("Panel").set_size(text_node.get_size() + Vector2(15, 15))