extends "res://Tutorials/tutorial.gd"


func get():
	var tutorial = TutorialPrototype.instance()
	var text = ["Yellow enemies have abilities that {affect other enemies}."]
	add_player_start_rule(tutorial, 1, text)
	return tutorial
	
