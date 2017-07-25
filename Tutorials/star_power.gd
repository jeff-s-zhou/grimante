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
	var text = ["You now have access to Stars.",
	"Use a Star on a dead Hero's grave to resurrect him/her.",
	"Use a Star on an exhausted Hero to reactivate him/her.",
	"For every {7} enemies killed, you gain {1} Star.",
	"For this tutorial, we've given you {1} Star to start. Clear this level this turn."]
	add_player_start_rule(tutorial, 1, text)

	return tutorial