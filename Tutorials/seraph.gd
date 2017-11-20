extends "res://Tutorials/tutorial.gd"


func get():
	var tutorial = TutorialPrototype.instance()
	var text = ["Yellow Enemies have abilities that affect {other Enemies}."]
	add_player_start_rule(tutorial, 1, text)
	return tutorial
	
