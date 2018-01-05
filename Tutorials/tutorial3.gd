
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
	
	#TURN 1
	var text = ["You've learned how to use {Direct Attacks}. However, that's not all Heroes can do."]
	add_player_start_rule(tutorial, 1, text)
	
	text = ["The Cavalier can damage multiple Enemies with his {Indirect Attack}: Trample.",
	"Trample deals {2} damage to each Enemy in the Cavalier's path."]
	add_forced_action(tutorial, 1, Vector2(2, 6), Vector2(2, 2), text)
	
	text = ["When the Berserker moves to an empty tile, he uses his Indirect Attack, Ground Slam.", 
	"Ground Slam deals {2} damage to Enemies adjacent to the destination."]
	add_forced_action(tutorial, 1, Vector2(4, 7), Vector2(4, 5), text)

	
	#TURN 2
	text = ["Remember that the Cavalier's {Direct Attack}, Charge, can only be used when there's a clear path to an Enemy."]
	add_player_start_rule(tutorial, 2, text)
	
	text = ["The Cavalier is now in danger of being KOed, but the Berserker has one more trick up his sleeve."]
	add_forced_action(tutorial, 2, Vector2(2, 2), Vector2(6, 6), text)
	
	text = ["The Berserker's Indirect Attack also {Stuns} enemies.", \
	"The Stun Effect prevents enemies from moving their next turn.", 
	]
	add_forced_action(tutorial, 2, Vector2(4, 5), Vector2(4, 3), text)
	

	#TURN 3
	text = ["Look for orange highlighted tiles to let you know when you can Indirect Attack.",
	"Press D or right click to deselect a Hero, or click somewhere it can't move.",
	"Clear the board this turn."]
	add_player_start_rule(tutorial, 3, text)
	return tutorial

