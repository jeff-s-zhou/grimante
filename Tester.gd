extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal test_signal1

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("Timer").connect("timeout", self, "method1", [], CONNECT_ONESHOT)
	get_node("Timer").connect("timeout", self, "method2", [], CONNECT_ONESHOT)
	get_node("Timer").set_wait_time(1.0)
	get_node("Timer").start()
	
func method1():
	print("method1 called")
	
func method2():
	print("method2 called")