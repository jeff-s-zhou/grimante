extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func initialize(level_schematic):
	get_node("Label").set_text(str(level_schematic.id) + " " + str(level_schematic.name))