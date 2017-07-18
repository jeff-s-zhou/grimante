extends "res://Tutorials/tutorial.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"


func get():
	var tutorial = TutorialPrototype.instance()
	
	var text = ["A piece cannot be pushed if there's {another piece behind it}."]
	add_player_start_rule(tutorial, 1, text)
	
	add_forced_action(tutorial, 1, Vector2(4, 7), Vector2(3, 7))
	
	add_forced_action(tutorial, 1, Vector2(2, 6), Vector2(3, 6))
	
	text = ["Placing the Archer behind the Cavalier blocks the Enemies from advancing.", 
	"Be careful however, as powerful Enemies can still kill weaker Heroes."]
	add_enemy_end_rule(tutorial, 1, text)
	
	var text = ["These are {Reinforcement Hexes}.", 
	"An Enemy will appear on a {Reinforcement Hex} at the start of the following turn."]
	add_player_start_rule(tutorial, 2, text, Vector2(4, 5))
	
	text = ["If a piece {occupies} a Reinforcement Hex tile, it blocks the Reinforcement until the following turn."]
	add_enemy_end_rule(tutorial, 2, text)
	
	var text = ["The top of the screen shows when the next Wave of Reinforcements is going to arrive.",
	"Clear the board before the Reinforcements arrive."]
	add_player_start_rule(tutorial, 3, text)
	
	return tutorial