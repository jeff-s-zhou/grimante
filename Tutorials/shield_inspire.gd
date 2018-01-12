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
	var text = ["Note: {Heroes cannot inspire themselves if they act twice in a row.}"]
	add_player_start_rule(tutorial, 1, text)

	return tutorial