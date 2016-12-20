
extends Node

# member variables here, example:
# var a=2
# var b="textvar"

signal animation_done

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("AnimationQueue").enqueue(self, "test_function", 3, 4)
	
	
func test_function(number, number2):
	print("handling number in test_function")
	print(number)
	print(number2)
	emit_signal("animation_done")

