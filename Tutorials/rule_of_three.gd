extends "res://Tutorials/tutorial.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"


func get():
	var tutorial = TutorialPrototype.instance()
	var text = ["If you forget what a piece does, press Tab on it to bring up a summary."]
	add_player_start_rule(tutorial, 1, text)
	return tutorial
	