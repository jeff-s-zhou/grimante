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
	var text = ["The Frost Knight inspires allies to {Defend}.", 
	"Unlike other Inspirations, {Defend} is triggered whenever the Frost Knight moves.",
	"The next Hero that acts receives a {Shield}."]
	add_player_start_rule(tutorial, 1, text)

	return tutorial