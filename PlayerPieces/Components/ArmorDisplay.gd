extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func set_armor(value):
	var value_str = str(value)
	get_node("AnimatedSprite").set_animation(value_str)