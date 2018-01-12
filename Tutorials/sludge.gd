extends "res://Tutorials/tutorial.gd"


func get():
	var tutorial = TutorialPrototype.instance()
	var text = ["Enemies come in different colors.",
	"Green enemies have abilities that only {affect themselves}.",
	"Red enemies have abilities that {harm Heroes}.",
	"Additionally, Reinforcement Hexes {are the same color} as the reinforcement."]
	add_player_start_rule(tutorial, 1, text)
	return tutorial
	
