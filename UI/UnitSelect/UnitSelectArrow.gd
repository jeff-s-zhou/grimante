extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	set_process_input(true)
	
func _input_event(viewport, event, shape_idx):
	get_parent().handle_arrow_input(event, get_name())
