extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("Grid").set_pos(Vector2(300, 200))
	get_node("Grid").reset_deployable_indicators()
	
