extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _input_event(viewport, event, shape_idx):
	if get_node("/root/InputHandler").is_select(event):
		get_node("/root/Combat").restart()
	