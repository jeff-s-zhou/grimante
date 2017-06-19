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
	var text = [" Now, when you kill enemies, you build up Star Power!",
	"For every {7} enemies killed, you gain 1 Star.",
	"Use a Star to reactivate an exhausted Hero."]
	add_player_start_rule(tutorial, 0, text)

	return tutorial