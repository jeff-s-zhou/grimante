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
	
	var fa_text1 = "The Cavalier has arrived! Let's see what it can do."
	var fa_text2 = "The Cavalier can move any number of tiles in all six directions."
	add_forced_action(tutorial, 1, Vector2(3, 7), fa_text1, Vector2(0, 4), fa_text2)
	
	var text = ["The Cavalier can run through enemies with its Indirect Attack: Trample.", \
	"Trample deals 2 damage to each enemy."]
	fa_text1 = "Now let's clean up some enemies."
	fa_text2 = ""
	add_forced_action(tutorial, 2, Vector2(0, 4), fa_text1, Vector2(0, 0), fa_text2, text)
	
	text = ["The Cavalier can use its Direct Attack, Charge, on an enemy when there is nothing blocking its path.", \
	"Charge deals 1 damage for each tile travelled to the first enemy it hits, and the enemy behind it."]
	fa_text1 = "Now let's use the Cavalier's Direct Attack, Charge."
	fa_text2 = ""
	add_forced_action(tutorial, 3, Vector2(0, 0), fa_text1, Vector2(5, 5), fa_text2, text)

	text = ["Can you clear the board before the enemies reach the bottom?"]
	add_player_start_rule(tutorial, 4, text)
	
	return tutorial