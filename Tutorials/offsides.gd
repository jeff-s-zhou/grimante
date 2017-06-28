extends "res://Tutorials/tutorial.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func get():
	var tutorial = TutorialPrototype.instance()
	
	var text = ["A Piece cannot be pushed if there's {another Piece behind it}."]
	add_player_start_rule(tutorial, 1, text)
	
	var fa_text1 = "Block the Enemies."
	
	add_forced_action(tutorial, 1, Vector2(4, 7), fa_text1, Vector2(3, 7), fa_text1)
	
	add_forced_action(tutorial, 1, Vector2(2, 6), fa_text1, Vector2(3, 6), fa_text1)
	
	text = ["Placing the Archer behind the Cavalier blocks the Enemies from advancing.", 
	"Be careful however, as powerful Enemies can still kill weaker Heroes."]
	add_enemy_end_rule(tutorial, 1, text)
	
	text = ["If an Enemy reinforcement is behind {all} Heroes, the reinforcement is {stopped}."]
	add_player_start_rule(tutorial, 2, text)
	
	fa_text1 = "Move your units up to stop reinforcements."
	
	add_forced_action(tutorial, 2, Vector2(3, 6), fa_text1, Vector2(3, 1), fa_text1)
	
	add_forced_action(tutorial, 2, Vector2(3, 7), fa_text1, Vector2(3, 6), fa_text1)
	
	return tutorial