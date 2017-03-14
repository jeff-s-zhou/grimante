extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal test_signal1

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var attack_ref = funcref(self, "attack")
	print(attack_ref.call_func())
	
func attack():
	return 3