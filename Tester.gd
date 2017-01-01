extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal test_signal1

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	print("starting")
	signal_emitter_func()
	yield(self, "test_signal1")
	get_node("Timer").set_wait_time(5.0)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	print("reached right before end")
	yield(self, "test_signal1")
	print("reached end")

func signal_emitter_func():
	get_node("Timer 2").set_wait_time(1.0)
	get_node("Timer 2").start()
	yield(get_node("Timer 2"), "timeout")
	emit_signal("test_signal1")
	emit_signal("test_signal1")