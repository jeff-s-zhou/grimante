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
	var text = ["This is the Deployment Phase.", 
	"Choose which Heroes to use and rearrange your Heroes on the highlighted tiles before the level starts.",
	"Press DEPLOY when finished."]
	add_player_start_rule(tutorial, 0, text)
	return tutorial