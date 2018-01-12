extends "res://Tutorials/tutorial.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"


func get():
	var tutorial = TutorialPrototype.instance()
	
	var text = ["Hint: Some Heroes are better at dealing with certain enemies than others."]
	add_player_start_rule(tutorial, 0, text)

	
	return tutorial