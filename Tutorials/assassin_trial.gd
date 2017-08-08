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

	var text = ["This is the Assassin's Trial. Clear the board in 1 turn."]
	
	add_player_start_rule(tutorial, 1, text)

	return tutorial