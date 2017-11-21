extends "res://Tutorials/tutorial.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func get_trial1_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["You can now use Stars.",
	"You receive {1} Star on the last turn of a level.",
	"Use a Star on a Hero who has already acted to let them act again.",
	]
	add_player_start_rule(tutorial, 1, text)
	return tutorial

	
func get_trial2_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["For every {7} enemies killed, you gain {1} Star.",
	]
	add_hint(tutorial, 1, text)
	return tutorial
	
func get_trial3_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["You can use a Star on any empty tile adjacent to another Hero to revive dead Heroes.",
	"The Berserker died at the start of this level. Revive it to beat the Trial.",
	]
	add_hint(tutorial, 1, text)
	return tutorial
	
	
func get_trial4_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["The Archer died at the start of this level. Revive it to beat the Trial.",
	"Hint: Think carefully about the positioning of your living Heroes before you revive."]
	add_hint(tutorial, 1, text)
	return tutorial
	