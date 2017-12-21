extends "res://UI/TransitionHelper.gd"


# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func initialize():
	.initialize()
	get_node("BackButton").connect("pressed", get_parent(), "back_from_settings")
	var settings = get_node("/root/State").settings
	
	
