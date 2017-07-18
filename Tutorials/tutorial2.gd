
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
	add_forced_action(tutorial, 1, Vector2(2, 6), Vector2(2, 4))

	add_forced_action(tutorial, 1, Vector2(4, 7), Vector2(4, 4))
	
	var text = ["Enemies will {shove} Heroes blocking their path, pushing them back 1 tile."]
	add_enemy_end_rule(tutorial, 1, text)
	
	#TURN 2
	add_forced_action(tutorial, 2, Vector2(2, 4), Vector2(0, 2))

	add_forced_action(tutorial, 2, Vector2(4, 6), Vector2(4, 5))
	
	text = ["If a Hero is {shoved} and the Enemy's Power is {greater than} the Hero's Armor, the Hero is {killed}.",
	"If all Heroes are killed, you lose.",
	"Note: A Hero is always killed if it is shoved off the board."]
	add_enemy_end_rule(tutorial, 2, text)

	#TURN 3
	text = ["Clear the board."]
	add_player_start_rule(tutorial, 3, text)
	return tutorial

