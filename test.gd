
extends Node

# member variables here, example:
# var a=2
# var b="textvar"

signal animation_done

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("AnimationQueue").enqueue(self, "test_function", false)
	
	
func test_function():
	print("handling number in test_function")
	print(3)
#	get_node("Timer").set_wait_time(0.2)
#	get_node("Timer").start()
#	yield(get_node("Timer"), "timeout")
	emit_signal("animation_done")

