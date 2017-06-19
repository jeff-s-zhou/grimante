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
	
	var text = [" Here, both Heroes have already moved and are {exhausted}.", 
	"Observe what happens when the Enemies try to move down.",
	"Press the End Turn button when you're ready."]
	add_player_start_rule(tutorial, 1, text)
	
	text = ["When an Enemy moves down onto a tile occupied by a Hero, 1 of 2 things occur:", 
	"1. If the Enemy's Power is {greater than or equal} to the Hero's Armor, the Hero is {killed}.",
	"2. Otherwise the Hero is {pushed down 1 tile}.",
	"Note: If the Hero is pushed off the map, it is {killed}."]
	
	add_enemy_end_rule(tutorial, 1, text)
	
	text = ["The Berserker is killed, but he's not out yet!"]
	
	add_player_start_rule(tutorial, 2, text)
	
	text = ["If a Hero moves adjacent to a {Grave}, the dead Hero is resurrected.",
	"However, if the Grave tile is {occupied} by another piece, the Hero will not resurrect.",
	"If all Heroes are killed, you lose."]
	
	var fa_text1 = "Move the Cavalier here."
	var fa_text2 = ""
	add_forced_action(tutorial, 2, Vector2(4, 7), fa_text1, Vector2(1, 4), fa_text2, text)
	
	text = ["Each Hero can move once per turn.", 
	"{Right Click} or press {Escape} to {deselect} a Hero."]
	add_player_start_rule(tutorial, 3, text)

	
	return tutorial