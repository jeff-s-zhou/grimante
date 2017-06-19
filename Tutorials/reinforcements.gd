extends "res://Tutorials/tutorial.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"


func get():
	var tutorial = TutorialPrototype.instance()
	
	var text = ["These are {Reinforcement Hexes}.", 
	"An Enemy will appear on a {Reinforcement Hex} at the start of the following turn."]
	add_player_start_rule(tutorial, 1, text, Vector2(5, 4))
	
	text = ["If a Hero {occupies} a Reinforcement Hex, it is {killed} when the Reinforcement appears.", 
	"If an Enemy stands on a Reinforcement Hex, it will absorb the Reinforcement and gains its Power."]
	add_enemy_end_rule(tutorial, 1, text)
	
	var text = ["The top left of the screen shows when the next Wave of Reinforcements is going to arrive."]
	add_player_start_rule(tutorial, 2, text)
	
	var text = ["If you forget what a Piece does, press Tab on it to bring up a summary."]
	add_player_start_rule(tutorial, 3, text)
	
	return tutorial
	