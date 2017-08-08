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

	var text = ["This is the Sandbox, where you can practice new characters and concepts.",
	"In order to unlock the Assassin, you must overcome a Trial.",
	"If you need to review the Tutorial, press the Left Red Arrow.",
	"When you're ready, press the Green Right Arrow to attempt the Trial."
	]
	
	add_player_start_rule(tutorial, 1, text)

	return tutorial