extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func set(title, text):
	get_node("Panel/Label").set_text(title)
	get_node("Panel/Text").set_bbcode(text)