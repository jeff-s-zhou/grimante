
extends Area2D

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	connect("mouse_enter", self, "test_method")
	
func test_method():
	print("FUCK THIS FUCKING SHIT")


