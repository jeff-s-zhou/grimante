extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal test_signal1

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var dict1 = {"a": true, "b": true, "c": true}
	var dict2 = {"a": true, "d": true}
	print(dict1 + dict2)