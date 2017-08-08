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
	var text = ["Clear the board within the {turn limit} displayed at the top of the screen, or else you lose!"]
	add_player_start_rule(tutorial, 1, text)
	
	var text = ["Special Enemies with abilities have appeared!", 
	"Press Tab over Enemies to read what their abilities do."]
	add_enemy_end_rule(tutorial, 1, text)

	return tutorial