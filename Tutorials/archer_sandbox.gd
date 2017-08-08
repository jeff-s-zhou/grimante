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
	
	var text = ["The Archer has joined your cause."]
	
	add_player_start_rule(tutorial, 1, text)
	
	text = ["Remember that you can press Tab over a Hero to read a full summary of their abilities.",
	"From here on out, you can also press the ? on the bottom right to read about the most recent action taken."]
	
	add_forced_action(tutorial, 1, Vector2(4, 7), Vector2(4, 2), text)

	return tutorial
