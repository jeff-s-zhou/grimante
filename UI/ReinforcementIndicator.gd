extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func display(type):
	get_node("Sprite").play(type)
	get_node("Sprite 2").play(type)