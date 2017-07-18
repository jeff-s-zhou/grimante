
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
	
	var text = ["Clear the board of enemies to win."]
	add_player_start_rule(tutorial, 1, text)
	
	#TURN 1
	var text = ["Each Hero piece can move once per turn."]
	
	var fa_text = "The Berserker can freely move up to 2 tiles away."
	
	add_forced_action(tutorial, 1, Vector2(4, 7), Vector2(4, 5), text, true, fa_text)
	
	fa_text = "The Cavalier can move {any number of tiles} in all 6 hex directions."
	
	text = ["When you have moved all of your Heroes, your turn ends."]
	add_forced_action(tutorial, 1, Vector2(2, 6), Vector2(0, 4), text, true, fa_text)
	
	text = ["Enemies {move down} 1 tile each turn.", \
	"If an Enemy {exits} from the bottom of the board, you {lose}."]
	add_enemy_end_rule(tutorial, 1, text)
	
	#TURN 2
	text = ["You have attacked an Enemy.", 
	"The Berserker's Direct Attack deals {4} damage to an Enemy's Power."]
	add_forced_action(tutorial, 2, Vector2(4, 5), Vector2(4, 3), text)
	
	text = ["The Cavalier's Charge deals {3 + 1 damage for each tile travelled} to the first Enemy it hits.",
	"If an Enemy's Power reaches {0}, it is killed."]
	add_forced_action(tutorial, 2, Vector2(0, 4), Vector2(0, 1), text)
	
	#TURN 3
	text = ["When the Berserker kills an Enemy, he moves to its tile.",
	"Clear the board of remaining enemies to win."]
	add_forced_action(tutorial, 3, Vector2(4, 5), Vector2(4, 4), text)
	
	return tutorial

