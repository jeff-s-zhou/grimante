extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)


func _input_event(viewport, event, shape_idx):
	get_parent().input_event(event)
	