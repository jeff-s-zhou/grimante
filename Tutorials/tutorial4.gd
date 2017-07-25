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
	
	add_forced_action(tutorial, 2, Vector2(3, 6), Vector2(3, 1))
	add_forced_action(tutorial, 2, Vector2(3, 7), Vector2(3, 6))
	
	var text = ["These are {Reinforcement Hexes}.", 
	"An Enemy will appear on a {Reinforcement Hex} at the start of the following turn."]
	add_player_start_rule(tutorial, 2, text, Vector2(4, 5))
	
	add_forced_action(tutorial, 3, Vector2(3, 1), Vector2(0, 1))
	add_forced_action(tutorial, 3, Vector2(3, 6), Vector2(4, 6))
	
	text = ["The top of the screen shows when the next Wave of Reinforcements is going to arrive."]
	add_player_start_rule(tutorial, 3, text)
	
	text = ["If a Hero blocks a Reinforcement, it is killed."]
	add_enemy_start_rule(tutorial, 3, text, Vector2(0, 1))
	
	text = ["If an Enemy blocks a Reinforcement, it absorbs the Reinforcement."]
	add_enemy_start_rule(tutorial, 4, text, Vector2(2, 4))
	
	
	
	#An Enemy standing on top of a Reinforcement Hex is a special case.
	
	return tutorial