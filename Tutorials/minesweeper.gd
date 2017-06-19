extends "res://Tutorials/tutorial.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func get():
	var tutorial = TutorialPrototype.instance()
	var text = ["From now on, you will be able to select the 5th Hero for each level from the roster of Unlocked Heroes."]
	add_player_start_rule(tutorial, 0, text)
	return tutorial
