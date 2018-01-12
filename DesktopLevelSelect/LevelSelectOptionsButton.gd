extends "res://UI/QUickOptions/QuickButton.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _input_event(viewport, event, shape_idx):
	if get_node("/root/InputHandler").is_select(event):
		get_parent().get_parent().go_to_settings() #because this is gonna be inside a TransitionHelper too