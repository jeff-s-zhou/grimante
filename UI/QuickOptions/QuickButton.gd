extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	connect("mouse_enter", self, "hover")
	connect("mouse_exit", self, "unhover")
	get_node("Sprite").set_opacity(0.5)


func hover():
	get_node("Sprite").set_opacity(1)

func unhover():
	get_node("Sprite").set_opacity(0.5)