
extends Node

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var test_vector1 = Vector2(2, 1)
	print(test_vector1.normalized())
	print(test_vector1.get_aspect())
	


