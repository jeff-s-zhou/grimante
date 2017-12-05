extends "res://Tutorials/tutorial.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"


func get():
	var tutorial = TutorialPrototype.instance()
	
	var text = ["These are {Traps}.", 
	"If a Hero steps on a Trap, it is damaged. If an enemy steps on a trap, its HP is {doubled}.",
	"Traps stay on the board until they are triggered.",
	"Like Enemies, Traps can be summoned and have a corresponding {purple} Reinforcement Hex."]
	add_player_start_rule(tutorial, 1, text, Vector2(3, 5))

	
	
	
	#An Enemy standing on top of a Reinforcement Hex is a special case.
	
	return tutorial