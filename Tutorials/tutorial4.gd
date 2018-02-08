extends "res://Tutorials/tutorial.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"


func get():
	var tutorial = TutorialPrototype.instance()
	
	var text = ["These are {Reinforcement Hexes}.", 
	"An enemy will appear on a {Reinforcement Hex} at the end of the next {Enemy Phase}."]
	add_player_start_rule(tutorial, 1, text, Vector2(3, 4))
	
	add_forced_action(tutorial, 1, Vector2(4, 7), Vector2(3, 5))
	add_forced_action(tutorial, 1, Vector2(2, 6), Vector2(2, 2))
	
	text = ["The top of the screen shows when the next wave of reinforcements is going to arrive."]
	add_player_start_rule(tutorial, 2, text)
	
	add_forced_action(tutorial, 2, Vector2(4, 7), Vector2(6, 7))
	add_forced_action(tutorial, 2, Vector2(2, 3), Vector2(6, 7))
	
	text = ["Heroes can block reinforcements by standing on Reinforcement Hexes.",
	"Blocking a reinforcement will break the Hero's Shield.",
	"If the Hero is not Shielded, it is {killed}."]
	add_enemy_start_rule(tutorial, 2, text, Vector2(6, 7))
	
	text = ["Have at it."]
	add_player_start_rule(tutorial, 3, text)
	
	text = ["If an enemy blocks a reinforcement, it absorbs the reinforcement's health."]
	add_enemy_start_rule(tutorial, 3, text, Vector2(3, 3))
	
	text = ["Hint: Clearing the board always beats the level, regardless of incoming reinforcements."]
	add_player_start_rule(tutorial, 4, text)
	
	
	
	
	#An Enemy standing on top of a Reinforcement Hex is a special case.
	
	return tutorial